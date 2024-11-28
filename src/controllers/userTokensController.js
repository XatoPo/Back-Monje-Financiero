import { pool } from "../db.js";
import { google } from 'googleapis';
import axios from 'axios';

const scheduler = google.cloudscheduler('v1beta1');  // Google Cloud Scheduler API

// Función para guardar o actualizar el token FCM en la base de datos
export const saveToken = async (req, res) => {
    const { userId, fcmToken } = req.body;

    if (!userId || !fcmToken) {
        return res.status(400).json({ message: 'userId y fcmToken son necesarios' });
    }

    try {
        // Verificar si el token ya existe
        const [existingToken] = await pool.query("SELECT * FROM UserTokens WHERE id = ?", [userId]);

        if (existingToken.length > 0) {
            // Actualizar token si ya existe
            await pool.query("UPDATE UserTokens SET fcm_token = ?, created_at = NOW() WHERE id = ?", [fcmToken, userId]);
            return res.status(200).json({ message: 'Token actualizado correctamente' });
        } else {
            // Insertar token si no existe
            await pool.query("INSERT INTO UserTokens (id, fcm_token, created_at) VALUES (?, ?, NOW())", [userId, fcmToken]);
            return res.status(200).json({ message: 'Token guardado correctamente' });
        }
    } catch (error) {
        console.error("Error al guardar el token FCM:", error);
        return res.status(500).json({ error: error.message });
    }
};

export const sendPushNotification = async (userId, title, body) => {
    const [result] = await pool.query("SELECT fcm_token FROM UserTokens WHERE id = ?", [userId]);

    if (result.length === 0) {
        console.log("Token no encontrado para el usuario:", userId);
        return;
    }

    const fcmToken = result[0].fcm_token;

    const message = {
        to: fcmToken,
        notification: {
            title: title,
            body: body,
        },
        priority: "high",
    };

    const headers = {
        "Authorization": `key=${YOUR_FCM_SERVER_KEY}`,
        "Content-Type": "application/json",
    };

    try {
        const response = await axios.post("https://fcm.googleapis.com/fcm/send", message, { headers });
        console.log("Notificación enviada:", response.data);
    } catch (error) {
        console.error("Error al enviar notificación:", error);
    }
};

// Función para crear o actualizar un trabajo de Cloud Scheduler
const createOrUpdateSchedulerJob = async (userId, notificationFrequency) => {
    const jobName = `send-notification-job-${userId}`;

    // Define el horario de acuerdo a la frecuencia del usuario
    let cronSchedule = '';
    switch (notificationFrequency) {
        case 'Diario':
            cronSchedule = '0 0 * * *';  // A medianoche todos los días
            break;
        case 'Semanal':
            cronSchedule = '0 0 * * 0';  // A medianoche los domingos
            break;
        case 'Mensual':
            cronSchedule = '0 0 1 * *';  // A medianoche el primer día de cada mes
            break;
        default:
            cronSchedule = '0 0 * * *';
    }

    try {
        // Configuración del trabajo de Cloud Scheduler
        const job = {
            httpTarget: {
                uri: `https://api-node-monje-299345047999.us-central1.run.app/user-tokens/send-push-notification`,  // La URL de tu endpoint
                httpMethod: 'POST',
                body: JSON.stringify({ userId, title: "Notificación", body: "Es hora de revisar tu cuenta" }),
                headers: {
                    'Content-Type': 'application/json',
                }
            },
            schedule: cronSchedule,
            timeZone: 'America/Los_Angeles',  // Ajusta a tu zona horaria
        };

        // Eliminar el trabajo anterior si existe
        await scheduler.projects.locations.jobs.delete({
            name: `projects/monje-financiero/locations/us-central1/jobs/${jobName}`,
        }).catch(err => {
            console.log("No hay trabajo anterior, creando nuevo...");
        });

        // Crear el nuevo trabajo
        await scheduler.projects.locations.jobs.create({
            parent: 'projects/monje-financiero/locations/us-central1',
            resource: {
                name: jobName,
                schedule: cronSchedule,
                httpTarget: job.httpTarget,
            }
        });

        console.log(`Trabajo programado creado o actualizado: ${jobName}`);
    } catch (error) {
        console.error('Error al crear o actualizar el trabajo de Cloud Scheduler:', error);
    }
};

export const updateNotificationSettings = async (req, res) => {
    const { userId, notificationFrequency, notificationsEnabled } = req.body;

    if (!userId || notificationFrequency === undefined || notificationsEnabled === undefined) {
        return res.status(400).json({ message: 'userId, notificationFrequency y notificationsEnabled son necesarios' });
    }

    try {
        const [existingSettings] = await pool.query("SELECT * FROM UserSettings WHERE user_id = ?", [userId]);

        if (existingSettings.length > 0) {
            // Actualizar configuración de notificaciones
            await pool.query(
                `UPDATE UserSettings 
                 SET notification_frequency = ?, notifications_enabled = ? 
                 WHERE user_id = ?`,
                [notificationFrequency, notificationsEnabled, userId]
            );
        } else {
            // Insertar configuración de notificaciones
            await pool.query(
                `INSERT INTO UserSettings (user_id, notification_frequency, notifications_enabled) 
                 VALUES (?, ?, ?)`,
                [userId, notificationFrequency, notificationsEnabled]
            );
        }

        // Llamar a la función que crea o actualiza el trabajo de Cloud Scheduler
        if (notificationsEnabled) {
            await createOrUpdateSchedulerJob(userId, notificationFrequency);
        } else {
            // Si el usuario desactiva las notificaciones, eliminar el trabajo de Cloud Scheduler
            const jobName = `send-notification-job-${userId}`;
            try {
                await scheduler.projects.locations.jobs.delete({
                    name: `projects/YOUR_PROJECT_ID/locations/us-central1/jobs/${jobName}`,
                });
                console.log(`Trabajo de notificación eliminado para el usuario ${userId}`);
            } catch (error) {
                console.error(`No se pudo eliminar el trabajo de notificación para el usuario ${userId}:`, error);
            }
        }

        return res.status(200).json({ message: 'Configuración de notificaciones actualizada correctamente' });
    } catch (error) {
        console.error("Error al actualizar la configuración de notificaciones:", error);
        return res.status(500).json({ error: error.message });
    }
};