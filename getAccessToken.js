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
    } catch (error) {
        console.error('Error obteniendo el token:', error);
    }
}

// Llamar a la función para obtener el token
getAccessToken();