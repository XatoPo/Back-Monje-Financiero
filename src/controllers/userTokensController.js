import { pool } from "../db.js";
import axios from 'axios';
import cron from 'node-cron';  // Importa node-cron
import { google } from 'googleapis';
import fs from 'fs';
import path from 'path';

// Cargar las credenciales del servicio desde el archivo JSON
const serviceAccount = JSON.parse(fs.readFileSync(path.resolve('notification-monje-financiero-firebase-adminsdk-4nbbo-2554f58c99.json'), 'utf8'));

// Configurar la autenticación con las credenciales de la cuenta de servicio
const auth = new google.auth.JWT(
    serviceAccount.client_email,  // El correo de la cuenta de servicio
    null,
    serviceAccount.private_key,   // La clave privada
    ['https://www.googleapis.com/auth/firebase.messaging']  // El alcance necesario para FCM
);

// Obtener el token de acceso OAuth 2.0
async function getAccessToken() {
    try {
        // Autorizar la solicitud y obtener el token de acceso
        const tokens = await auth.authorize();
        console.log('Access Token:', tokens.access_token);
        return tokens.access_token;  // Devuelve el token
    } catch (error) {
        console.error('Error obteniendo el token:', error);
    }
}

// Mapa para almacenar los cron jobs de los usuarios
const userCronJobs = {};

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

// Función para actualizar la configuración de notificaciones
export const updateNotificationSettings = async (req, res) => {
    const { userId, notificationFrequency, notificationsEnabled } = req.body;

    if (!userId || notificationFrequency === undefined || notificationsEnabled === undefined) {
        return res.status(400).json({ message: 'userId, notificationFrequency y notificationsEnabled son necesarios' });
    }

    try {
        // Verificar si existe la configuración previa
        const [existingSettings] = await pool.query("SELECT * FROM UserSettings WHERE user_id = ?", [userId]);

        if (existingSettings.length > 0) {
            // Si existe, actualizamos
            await pool.query(
                `UPDATE UserSettings SET notification_frequency = ?, notifications_enabled = ? WHERE user_id = ?`,
                [notificationFrequency, notificationsEnabled, userId]
            );
            console.log(`Configuración de usuario ${userId} actualizada.`);
        } else {
            // Si no existe, insertamos
            await pool.query(
                `INSERT INTO UserSettings (user_id, notification_frequency, notifications_enabled) VALUES (?, ?, ?)`,
                [userId, notificationFrequency, notificationsEnabled]
            );
            console.log(`Configuración de usuario ${userId} guardada.`);
        }

        // Después de la actualización, programamos el cron para este usuario
        await scheduleNotificationForUser(userId, notificationFrequency, notificationsEnabled);

        return res.status(200).json({ message: 'Configuración de notificaciones actualizada correctamente' });
    } catch (error) {
        console.error("Error al actualizar la configuración de notificaciones:", error);
        return res.status(500).json({ error: error.message });
    }
};

// Función para programar una notificación para un usuario específico
const scheduleNotificationForUser = async (userId, notificationFrequency, notificationsEnabled) => {
    if (!notificationsEnabled) return;  // No programar si las notificaciones están deshabilitadas

    const cronExpression = getCronExpression(notificationFrequency);

    try {
        // Limpiar cualquier cron existente para este usuario antes de crear uno nuevo
        await clearUserCron(userId);

        // Programar la nueva notificación con la expresión cron
        const job = cron.schedule(cronExpression, async () => {
            console.log(`Ejecutando notificación para el usuario ${userId} con frecuencia ${notificationFrequency}...`);
            const title = '¡Tú Monje Financiero te llama!';
            const body = 'No te olvides de realizar el registro de tus gastos';
            try {
                await sendPushNotification(userId, title, body);
            } catch (error) {
                console.error('Error al enviar notificación:', error);
            }
        });

        // Guardamos el cron job para poder limpiarlo luego
        userCronJobs[userId] = job;

        console.log(`Notificación programada para el usuario ${userId} con frecuencia ${notificationFrequency}.`);
    } catch (error) {
        console.error("Error al programar la notificación:", error);
    }
};

// Función para obtener la expresión cron según la frecuencia de notificación
const getCronExpression = (notificationFrequency) => {
    switch (notificationFrequency) {
        case 'Diario':
            return '10 0 * * *';  // Todos los días a las 7:10 PM hora de Perú (12:10 AM UTC)
        case 'Semanal':
            return '10 0 * * MON';  // Todos los lunes a las 7:10 PM hora de Perú (12:10 AM UTC)
        case 'Mensual':
            return '10 0 1 * *';  // El primer día de cada mes a las 7:10 PM hora de Perú (12:10 AM UTC)
        default:
            return '10 0 * * *';  // Por defecto, todos los días a las 7:10 PM hora de Perú (12:10 AM UTC)
    }
};

// Función para eliminar los cron jobs programados de un usuario
const clearUserCron = async (userId) => {
    const cronJob = userCronJobs[userId];

    if (cronJob) {
        console.log(`Deteniendo cron para el usuario ${userId}.`);
        cronJob.stop();  // Detenemos el cron job
        delete userCronJobs[userId];  // Eliminamos el cron job del mapa
    } else {
        console.log(`No se encontró un cron job para el usuario ${userId}.`);
    }
};

// Función para enviar la notificación push
export const sendPushNotification = async (userId, title, body) => {
    try {
        const token = await getAccessToken();  // Usamos await aquí

        // Verificar si el token existe en la base de datos
        const [result] = await pool.query("SELECT fcm_token FROM UserTokens WHERE id = ?", [userId]);

        if (result.length === 0) {
            console.log("Token no encontrado para el usuario:", userId);
            return;
        }

        const fcmToken = result[0].fcm_token;

        // Mensaje a enviar
        const message = {
            "message": {
                "token": fcmToken,
                "notification": {
                    "title": title,
                    "body": body
                }
            }
        };

        const headers = {
            "Authorization": `Bearer ${token}`,  // Tu clave FCM
            "Content-Type": "application/json",
        };

        // Enviar notificación a FCM
        console.log("Enviando notificación...");
        const response = await axios.post("https://fcm.googleapis.com/v1/projects/notification-monje-financiero/messages:send", message, { headers });

        if (response.status === 200) {
            console.log("Notificación enviada exitosamente:", response.data);
            return response.data;
        } else {
            console.error("Error al enviar la notificación:", response.data);
            throw new Error('Respuesta no exitosa de FCM');
        }
    } catch (error) {
        console.error("Error al enviar la notificación:", error.message);
        throw new Error('Error al enviar la notificación');
    }
};

// Llamar a la función scheduleNotifications al iniciar el servidor
const scheduleNotifications = async () => {
    const [users] = await pool.query("SELECT user_id, notification_frequency, notifications_enabled FROM UserSettings WHERE notifications_enabled = 1");

    console.log('Usuarios habilitados para recibir notificaciones:', users);

    // Programar el cron para cada usuario según su frecuencia de notificación
    users.forEach(user => {
        const { user_id, notification_frequency, notifications_enabled } = user;
        scheduleNotificationForUser(user_id, notification_frequency, notifications_enabled);
    });
};

// Ejecutar la función scheduleNotifications al iniciar el servidor
scheduleNotifications();