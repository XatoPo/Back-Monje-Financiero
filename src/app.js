import express from "express";
import { pool } from "./db.js";

const app = express();
app.use(express.json());

app.get("/", (req, res) => {
    res.send("Monje Financiero");
});

app.get("/ping", async (req, res) => {
    const [result] = await pool.query(`SELECT "hello world" as RESULT`);
    console.log(result);
    //res.send("Monje Financiero - Ping");
    res.json(result);
});

app.get("/usersTest", async (req, res) => {
    const [result] = await pool.query("SELECT id, name, email, password, date_of_birth, profile_image_url FROM users");
    console.log(result);
    //res.send("Monje Financiero - Users");
    res.json(result);
});

app.post("/userTestInsert", async (req, res) => {
    const { id, name, email, password, date_of_birth, profile_image_url } = req.body;
    try {
        const [result] = await pool.query(
            "INSERT INTO users (id, name, email, password, date_of_birth, profile_image_url) VALUES (?, ?, ?, ?, ?, ?)", 
            [id, name, email, password, date_of_birth, profile_image_url]
        );
        console.log(result);
        res.json(result);
    } catch (error) {
        console.error('Error details:', error);
        res.status(500).json({ error: 'Error inserting user' });
    }
});

app.listen(3000, () => {
    console.log("Servidor escuchando en el puerto 3000");
});