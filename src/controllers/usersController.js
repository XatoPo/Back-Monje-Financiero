import { pool } from "../db.js";

export const registerUser = async (req, res) => {
    const { name, email, password, date_of_birth, profile_image_url } = req.body;
    try {
        const [result] = await pool.query("CALL RegisterUser(?, ?, ?, ?, ?)", [name, email, password, date_of_birth, profile_image_url]);
        res.status(201).json(result);
    } catch (error) {
        console.error(error); // Agrega esto para ver errores en la consola
        console.log(error);
        res.status(500).json({ error: error.message });
    }
};

export const getUser = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL GetUser(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        console.error(error); // Agrega esto para ver errores en la consola
        console.log(error);
        res.status(500).json({ error: error.message });
    }
};

export const loginUser = async (req, res) => {
    const { email, password } = req.body;
    try {
        // Ejecuta la consulta con el nuevo parámetro de salida
        await pool.query("CALL LoginUser(?, ?, @user_id)", [email, password]);
        
        // Obtiene el valor del parámetro de salida
        const [userIdRow] = await pool.query("SELECT @user_id AS user_id");

        if (userIdRow[0].user_id) {
            res.status(200).json({
                success: true,
                userId: userIdRow[0].user_id
            });
        } else {
            res.status(401).json({ error: 'Invalid email or password.' });
        }
    } catch (error) {
        console.error(error); // Agrega esto para ver errores en la consola
        console.log(error);
        res.status(500).json({ error: error.message });
    }
};

export const updateUser = async (req, res) => {
    const { id } = req.params;
    const { name, profile_image_url } = req.body;
    try {
        const [result] = await pool.query("CALL UpdateUser(?, ?, ?)", [id, name, profile_image_url]);
        res.status(200).json(result);
    } catch (error) {
        console.error(error); // Agrega esto para ver errores en la consola
        console.log(error);
        res.status(500).json({ error: error.message });
    }
};

export const deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query("CALL DeleteUser(?)", [id]);
        res.status(200).json(result);
    } catch (error) {
        console.error(error); // Agrega esto para ver errores en la consola
        console.log(error);
        res.status(500).json({ error: error.message });
    }
};