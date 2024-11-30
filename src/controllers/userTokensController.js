import { pool } from "../db.js";
import axios from 'axios';
import cron from 'node-cron';  // Importa node-cron

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
        cron.schedule(cronExpression, async () => {
            console.log(`Ejecutando notificación para el usuario ${userId} con frecuencia ${notificationFrequency}...`);
            const title = '¡Tú Monje Financiero te llama!';
            const body = 'No te olvides de realizar el registro de tus gastos';
            try {
                await sendPushNotification(userId, title, body);
            } catch (error) {
                console.error('Error al enviar notificación:', error);
            }
        });

        console.log(`Notificación programada para el usuario ${userId} con frecuencia ${notificationFrequency}.`);
    } catch (error) {
        console.error("Error al programar la notificación:", error);
    }
};

// Función para obtener la expresión cron según la frecuencia de notificación
const getCronExpression = (notificationFrequency) => {
    switch (notificationFrequency) {
        case 'Diario':
            return '13 9 * * *';  // Todos los días a las 3:40 AM hora de Perú (8:40 AM UTC)
        case 'Semanal':
            return '13 9 * * MON';  // Todos los lunes a las 3:40 AM hora de Perú (8:40 AM UTC)
        case 'Mensual':
            return '13 9 1 * *';  // El primer día de cada mes a las 3:40 AM hora de Perú (8:40 AM UTC)
        default:
            return '13 9 * * *';  // Por defecto, todos los días a las 3:40 AM hora de Perú (8:40 AM UTC)
    }
};

// Función para eliminar los cron jobs programados de un usuario
const clearUserCron = async (userId) => {
    // Este es un lugar para que implementes la lógica para limpiar el cron existente, si tienes algún sistema para manejar eso.
    // Para simplificar, no hay código aquí pero deberías almacenar y eliminar los cron jobs según el userId si es necesario.
    console.log(`Limpiando cron para el usuario ${userId} (si es necesario).`);
};

// Función para enviar la notificación push
export const sendPushNotification = async (userId, title, body) => {
    try {
        // Verificar si el token existe en la base de datos
        const [result] = await pool.query("SELECT fcm_token FROM UserTokens WHERE id = ?", [userId]);

        if (result.length === 0) {
            console.log("Token no encontrado para el usuario:", userId);
            return;
        }

        const fcmToken = result[0].fcm_token;

        // Mensaje a enviar
        const message = {
            to: fcmToken,
            notification: {
                title: title,
                body: body,
            },
            priority: "high",
        };

        const headers = {
            "Authorization": `key=SbB8zeQgur4gqPO1hM79bQCQYVYsatBOUu-EL1L_vwY`,  // Tu clave FCM
            "Content-Type": "application/json",
        };

        // Enviar notificación a FCM
        console.log("Enviando notificación...");
        const response = await axios.post("https://fcm.googleapis.com/fcm/send", message, { headers });

        // Depuración adicional: detalles de la respuesta
        console.log("Respuesta de FCM:", JSON.stringify(response.data, null, 2));

        if (response.status === 200) {
            console.log("Notificación enviada exitosamente:", response.data);
            return response.data;
        } else {
            console.error("Error al enviar la notificación, respuesta no exitosa:", response.data);
            throw new Error('Respuesta no exitosa de FCM');
        }
    } catch (error) {
        console.error("Error al enviar la notificación:", error.message);
        if (error.response) {
            console.error("Detalles del error de FCM:", error.response.data);
            console.error("Código de error:", error.response.status);
        } else {
            console.error("Detalles del error:", error);
        }
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