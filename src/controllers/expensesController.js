import { pool } from "../db.js";

export const insertExpense = async (req, res) => {
    const { user_id, description, amount, category_id, date, is_recurring } = req.body;
    try {
        const [result] = await pool.query("CALL InsertExpense(?, ?, ?, ?, ?, ?)", [user_id, description, amount, category_id, date, is_recurring]);
        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getExpense = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetExpense(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getAllExpenses = async (req, res) => {
    try {
        const [result] = await pool.query("CALL GetAllExpenses()");
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateExpense = async (req, res) => {
    const { id } = req.params;
    const { description, amount, category_id, date, is_recurring } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateExpense(?, ?, ?, ?, ?, ?)", [id, description, amount, category_id, date, is_recurring]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deleteExpense = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteExpense(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};