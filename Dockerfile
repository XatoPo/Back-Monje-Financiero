# Usa una imagen de Node.js como base
FROM node:18-alpine

# Crea un directorio de trabajo en el contenedor
WORKDIR /usr/src/app

# Copia los archivos de tu proyecto
COPY package*.json ./
RUN npm install
COPY . .

# Expone el puerto 8080 que Cloud Run necesita
EXPOSE 8080

# Configura el puerto que la aplicación debe escuchar (Cloud Run establece PORT=8080)
ENV PORT=8080

# Comando para iniciar la API
CMD ["node", "src/app.js"]