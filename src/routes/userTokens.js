import { Router } from "express";
import { saveToken, sendPushNotification, updateNotificationSettings } from "../controllers/userTokensController.js";

const router = Router();

// Ruta para guardar o actualizar el token FCM
router.post('/save-token', saveToken);

// Ruta para enviar una notificación push a un usuario
router.post('/send-push-notifications', async (req, res) => {
    // Lógica para obtener la configuración de los usuarios (por ejemplo, "Diario") y enviar notificaciones.
    try {
        const [users] = await pool.query("SELECT * FROM Users");

        for (const user of users) {
            const settings = await pool.query("SELECT * FROM UserSettings WHERE user_id = ?", [user.id]);
            const userSettings = settings[0];

            if (userSettings.notifications_enabled && userSettings.notification_frequency === "Diario") {
                // Enviar notificación
                await sendPushNotification(user.id, "Notificación diaria", "¡Revisa tu cuenta!");
            }
        }

        res.status(200).json({ message: "Notificaciones enviadas correctamente" });
    } catch (error) {
        console.error("Error al enviar notificaciones:", error);
        res.status(500).json({ error: error.message });
    }
});

// Ruta para actualizar la configuración de notificaciones
router.post('/update-notification-settings', updateNotificationSettings);

export default router;