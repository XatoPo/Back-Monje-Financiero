import { pool } from "../db.js";

export const insertReport = async (req, res) => {
    const { user_id, start_date, end_date, total_expenses, category_breakdown } = req.body;
    try {
        const [result] = await pool.query("CALL InsertReport(?, ?, ?, ?, ?)", [user_id, start_date, end_date, total_expenses, category_breakdown]);
        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getReport = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetReport(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getAllReports = async (req, res) => {
    try {
        const [result] = await pool.query("CALL GetAllReports()");
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateReport = async (req, res) => {
    const { id } = req.params;
    const { start_date, end_date, total_expenses, category_breakdown } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateReport(?, ?, ?, ?, ?)", [id, start_date, end_date, total_expenses, category_breakdown]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deleteReport = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteReport(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getReportData = async (req, res) => {
    const { user_id, start_date, end_date } = req.query;
    try {
        const [result] = await pool.query(
            "CALL GenerateExpenseReport(?, ?, ?)", 
            [user_id, start_date, end_date]
        );

        const categoryBreakdown = []; // Desglose de gastos por categoría
        let totalExpenses = 0;

        result.forEach(row => {
            categoryBreakdown.push({
                category: row.category_name,
                amount: row.total_amount
            });
            totalExpenses += row.total_amount;
        });

        res.status(200).json({
            total_expenses: totalExpenses,
            category_breakdown: categoryBreakdown
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
