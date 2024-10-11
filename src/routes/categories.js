import { Router } from "express";
import { insertCategory, getCategory, getAllCategories, updateCategory, deleteCategory } from "../controllers/categoriesController.js";

const router = Router();

router.post("/", insertCategory);
router.get("/:id", getCategory);
router.get("/:id", getAllCategories);
router.put("/:id", updateCategory);
router.delete("/:id", deleteCategory);

export default router;