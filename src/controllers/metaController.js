import { pool } from "../db.js";

export const insertMeta = async (req, res) => {
    const { user_id, target_amount, achieved_amount, deadline } = req.body;
    try {
        const [result] = await pool.query("CALL InsertMeta(?, ?, ?, ?)", [user_id, target_amount, achieved_amount, deadline]);
        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getMeta = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetMeta(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getAllMeta = async (req, res) => {
    try {
        const [result] = await pool.query("CALL GetAllMeta()");
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateMeta = async (req, res) => {
    const { id } = req.params;
    const { target_amount, achieved_amount, deadline } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateMeta(?, ?, ?, ?)", [id, target_amount, achieved_amount, deadline]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deleteMeta = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteMeta(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};