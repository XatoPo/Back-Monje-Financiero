import express from "express";
import { pool } from "./db.js";

const app = express();

app.get("/", (req, res) => {
    res.send("Monje Financiero");
});

app.get("/ping", (req, res) => {
    const result = pool.query("SELECT id, name, email, password, date_of_birth, profile_image_url FROM users");
    res.json(result.rows);
    res.send("Monje Financiero - Users");
});

app.listen(3000, () => {
    console.log("Servidor escuchando en el puerto 3000");
});