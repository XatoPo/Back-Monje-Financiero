# Usa una imagen de Node.js como base
FROM node:18-alpine

# Crea un directorio de trabajo en el contenedor
WORKDIR /usr/src/app

# Copia los archivos de dependencias
COPY package*.json ./
RUN npm install

# Copia el resto del código de la aplicación
COPY . .

# Copia el archivo JSON de Firebase en el contenedor
COPY ./src/controllers/notification-monje-financiero-firebase-adminsdk-4nbbo-2554f58c99.json /usr/src/app/notification-monje-financiero-firebase-adminsdk-4nbbo-2554f58c99.json

# Expone el puerto 8080 que Cloud Run necesita
EXPOSE 8080

# Configura el puerto que la aplicación debe escuchar (Cloud Run establece PORT=8080)
ENV PORT=8080

# Comando para iniciar la API
CMD ["node", "src/app.js"]
