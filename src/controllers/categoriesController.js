import { pool } from "../db.js";

export const insertCategory = async (req, res) => {
    const { user_id, name, color, icon_text } = req.body;

    // Validaciones básicas
    if (!user_id || !name || !color || !icon_text) {
        return res.status(400).json({ error: 'All fields are required.' });
    }

    try {
        const [result] = await pool.query("CALL InsertCategory(?, ?, ?, ?)", [user_id, name, color, icon_text]);
        
        // Comprobar si se ha insertado correctamente
        if (result.affectedRows === 0) {
            return res.status(500).json({ error: 'Insertion failed, no rows affected.' });
        }

        res.status(201).json(result);
    } catch (error) {
        console.error('Error during insertion:', error); // Log del error en el servidor

        // Manejo de errores específicos
        if (error.message.includes('Category name already exists')) {
            return res.status(409).json({ error: 'Category name already exists for this user.' });
        } else {
            return res.status(500).json({ error: 'An unexpected error occurred. Please try again later.' });
        }
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
    const { user_id } = req.query;
    if (!user_id) {
        return res.status(400).json({ error: "user_id es requerido" });
    }

    try {
        const [result] = await pool.query("CALL GetAllCategoriesByUser(?)", [user_id]);
        res.status(200).json(result);
    } catch (error) {
        console.error(error); // Agrega esto para ver errores en la consola
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