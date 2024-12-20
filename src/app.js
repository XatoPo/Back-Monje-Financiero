import express from "express";
import { PORT } from "./config.js";
import usersRoutes from "./routes/users.js";
import categoriesRoutes from "./routes/categories.js";
import expensesRoutes from "./routes/expenses.js";
import budgetsRoutes from "./routes/budgets.js";
import reportsRoutes from "./routes/reports.js";
import metaRoutes from "./routes/meta.js";
import userTokensRoutes from "./routes/userTokens.js"; // Importar las rutas de tokens

const app = express();
app.use(express.json());

app.get("/", (req, res) => {
    res.send("Monje Financiero API");
});

// Rutas
app.use("/users", usersRoutes);
app.use("/categories", categoriesRoutes);
app.use("/expenses", expensesRoutes);
app.use("/budgets", budgetsRoutes);
app.use("/reports", reportsRoutes);
app.use("/meta", metaRoutes);
app.use("/user-tokens", userTokensRoutes);

app.listen(PORT, () => {
    console.log("Servidor escuchando en el puerto", PORT);
});