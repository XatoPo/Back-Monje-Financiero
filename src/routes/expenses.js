import { Router } from "express";
import { insertExpense, getExpense, getAllExpenses, updateExpense, deleteExpense } from "../controllers/expensesController.js";

const router = Router();

router.post("/", insertExpense);
router.get("/:id", getExpense);
router.get("/", getAllExpenses);
router.put("/:id", updateExpense);
router.delete("/:id", deleteExpense);

export default router;