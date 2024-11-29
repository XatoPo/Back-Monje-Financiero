import { pool } from "../db.js";
import { google } from 'googleapis';
import axios from 'axios';

// Crear el cliente de Cloud Scheduler
const scheduler = google.cloudscheduler('v1beta1');

// Inicializa el cliente de autenticación de Google, usando el archivo de credenciales JSON
const auth = new google.auth.GoogleAuth({
    keyFile: process.env.GOOGLE_APPLICATION_CREDENTIALS,  // Usar la variable de entorno
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
});

// Función para obtener el token de acceso (Access Token)
const getAccessToken = async () => {
    try {
        // Obtén el cliente autenticado
        const authClient = await auth.getClient();

        // Obtiene el token de acceso
        const tokenResponse = await authClient.getAccessToken();

        if (!tokenResponse || !tokenResponse.token) {
            throw new Error('No se pudo obtener el token de acceso');
        }

        console.log("Token de acceso obtenido:", tokenResponse.token);  // Verifica el token
        return tokenResponse.token;
    } catch (error) {
        console.error('Error al obtener el token de acceso:', error);
        throw new Error('Error al obtener el token de acceso');
    }
};

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

// Función para enviar la notificación push
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
        "Authorization": `key=${YOUR_FCM_SERVER_KEY}`, // Asegúrate de reemplazarlo con tu clave de servidor FCM
        "Content-Type": "application/json",
    };

    try {
        const response = await axios.post("https://fcm.googleapis.com/fcm/send", message, { headers });
        console.log("Notificación enviada:", response.data);
        return response.data; // Devuelve la respuesta para seguir con el flujo
    } catch (error) {
        console.error("Error al enviar notificación:", error);
        throw new Error('Error al enviar la notificación');
    }
};

// Función para crear o actualizar un trabajo en Cloud Scheduler
const createOrUpdateSchedulerJob = async (userId, notificationFrequency) => {
    const jobName = `send-notification-job-${userId}`;

    // Define el cronograma (frecuencia) del trabajo
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
            cronSchedule = '0 0 * * *';  // Predeterminado a diario
    }

    try {
        const token = await getAccessToken();  // Obtener el Access Token

        // Intentamos eliminar el trabajo existente si existe
        await scheduler.projects.locations.jobs.delete({
            name: `projects/monje-financiero/locations/us-central1/jobs/${jobName}`,
        }).catch(err => {
            console.log("No se encontró trabajo anterior, creando nuevo...");
        });

        // Creación del nuevo trabajo
        await scheduler.projects.locations.jobs.create({
            parent: 'projects/monje-financiero/locations/us-central1',
            resource: {
                name: jobName,
                schedule: cronSchedule,
                httpTarget: {
                    uri: 'https://api-node-monje-299345047999.us-central1.run.app/user-tokens/send-push-notification',
                    httpMethod: 'POST',
                    body: JSON.stringify({ 
                        userId, 
                        title: "Notificación", 
                        body: "Es hora de revisar tu cuenta"
                    }),
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${token}`,  // Aquí pasa el Access Token
                    },
                },
            },
        });

        console.log(`Trabajo programado creado o actualizado: ${jobName}`);
    } catch (error) {
        console.error('Error al crear o actualizar el trabajo de Cloud Scheduler:', error);
    }
};

export default createOrUpdateSchedulerJob;

// Función para actualizar la configuración de notificaciones
export const updateNotificationSettings = async (req, res) => {
    const { userId, notificationFrequency, notificationsEnabled } = req.body;

    if (!userId || notificationFrequency === undefined || notificationsEnabled === undefined) {
        return res.status(400).json({ message: 'userId, notificationFrequency y notificationsEnabled son necesarios' });
    }

    try {
        // Actualizamos o insertamos la configuración de notificaciones
        const [existingSettings] = await pool.query("SELECT * FROM UserSettings WHERE user_id = ?", [userId]);

        if (existingSettings.length > 0) {
            // Si existen, actualizamos
            await pool.query(
                `UPDATE UserSettings SET notification_frequency = ?, notifications_enabled = ? WHERE user_id = ?`,
                [notificationFrequency, notificationsEnabled, userId]
            );
        } else {
            // Si no existen, insertamos
            await pool.query(
                `INSERT INTO UserSettings (user_id, notification_frequency, notifications_enabled) VALUES (?, ?, ?)`,

                [userId, notificationFrequency, notificationsEnabled]
            );
        }

        // Llamamos a la función que crea o actualiza el trabajo en Cloud Scheduler
        if (notificationsEnabled) {
            // Si las notificaciones están habilitadas, creamos o actualizamos el trabajo de Cloud Scheduler
            await createOrUpdateSchedulerJob(userId, notificationFrequency);
        } else {
            // Si las notificaciones están desactivadas, eliminamos el trabajo de Cloud Scheduler
            await deleteSchedulerJob(userId);
        }

        return res.status(200).json({ message: 'Configuración de notificaciones actualizada correctamente' });
    } catch (error) {
        console.error("Error al actualizar la configuración de notificaciones:", error);
        return res.status(500).json({ error: error.message });
    }
};

// Función para eliminar el trabajo de Google Cloud Scheduler
const deleteSchedulerJob = async (userId) => {
    const jobName = `send-notification-job-${userId}`;

    try {
        await scheduler.projects.locations.jobs.delete({
            name: `projects/monje-financiero/locations/us-central1/jobs/${jobName}`,
        });
        console.log(`Trabajo de notificación eliminado para el usuario ${userId}`);
    } catch (error) {
        console.error(`No se pudo eliminar el trabajo de notificación para el usuario ${userId}:`, error);
    }
};