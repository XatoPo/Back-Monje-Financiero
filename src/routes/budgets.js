import { Router } from "express";
import { insertBudget, getBudget, getAllBudgets, updateBudget, deleteBudget } from "../controllers/budgetsController.js";

const router = Router();

router.post("/", insertBudget);
router.get("/:id", getBudget);
router.get("/", getAllBudgets);
router.put("/:id", updateBudget);
router.delete("/:id", deleteBudget);

export default router;