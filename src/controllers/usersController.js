import { pool } from "../db.js";

export const registerUser = async (req, res) => {
    const { name, email, password, date_of_birth, profile_image_url } = req.body;
    try {
        const [result] = await pool.query("CALL RegisterUser(?, ?, ?, ?, ?)", [name, email, password, date_of_birth, profile_image_url]);
        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getUser = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetUser(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const loginUser = async (req, res) => {
    const { email, password } = req.body;
    try {
        const [result] = await pool.query("CALL LoginUser(?, ?)", [email, password]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateUser = async (req, res) => {
    const { id } = req.params;
    const { name, email, password, date_of_birth, profile_image_url } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateUser(?, ?, ?, ?, ?, ?)", [id, name, email, password, date_of_birth, profile_image_url]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteUser(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};