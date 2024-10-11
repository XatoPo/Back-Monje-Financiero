import { pool } from "../db.js";

export const insertBudget = async (req, res) => {
    const { user_id, name, budget_limit, category_id, period } = req.body;
    try {
        const [result] = await pool.query("CALL InsertBudget(?, ?, ?, ?, ?)", [user_id, name, budget_limit, category_id, period]);
        if (result.affectedRows === 0) {
            throw new Error("No se pudo insertar el presupuesto.");
        }
        res.status(201).json(result);
    } catch (error) {
        console.error("Error en MySQL al insertar presupuesto:", error); // Mostrar más detalles del error
        res.status(500).json({ error: error.message });
    }
};

export const getBudget = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetBudget(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getAllBudgets = async (req, res) => {
    try {
        const [result] = await pool.query("CALL GetAllBudgets()");
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateBudget = async (req, res) => {
    const { id } = req.params;
    const { name, budget_limit, category_id, period } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateBudget(?, ?, ?, ?, ?)", [id, name, budget_limit, category_id, period]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deleteBudget = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteBudget(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};