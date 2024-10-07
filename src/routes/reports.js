import { Router } from "express";
import { insertReport, getReport, getAllReports, updateReport, deleteReport } from "../controllers/reportsController.js";

const router = Router();

router.post("/", insertReport);
router.get("/:id", getReport);
router.get("/", getAllReports);
router.put("/:id", updateReport);
router.delete("/:id", deleteReport);

export default router;