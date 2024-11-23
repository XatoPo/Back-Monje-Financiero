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
    const { user_id } = req.query;
    if (!user_id) {
        return res.status(400).json({ error: "user_id es requerido" });
    }

    try {
        const [result] = await pool.query("CALL GetAllExpensesByUser(?)", [user_id]);
        res.status(200).json(result);
    } catch (error) {
        console.log(error);
        console.error(error); // Agrega esto para ver errores en la consola
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