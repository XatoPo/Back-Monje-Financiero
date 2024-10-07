import { pool } from "../db.js";

export const insertCategory = async (req, res) => {
    const { user_id, name, color, icon_text } = req.body;
    try {
        const [result] = await pool.query("CALL InsertCategory(?, ?, ?, ?)", [user_id, name, color, icon_text]);
        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getCategory = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetCategory(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getAllCategories = async (req, res) => {
    try {
        const [result] = await pool.query("CALL GetAllCategories()");
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateCategory = async (req, res) => {
    const { id } = req.params;
    const { name, color, icon_text } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateCategory(?, ?, ?, ?)", [id, name, color, icon_text]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deleteCategory = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteCategory(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};