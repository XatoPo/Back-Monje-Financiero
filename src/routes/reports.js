import { Router } from "express";
import { insertReport, getReport, getAllReports, updateReport, deleteReport, getReportData } from "../controllers/reportsController.js";

const router = Router();

router.post("/", insertReport);
router.get("/:id", getReport); // Para obtener un reporte específico por su ID
router.get("/data", getReportData); // Para generar un reporte basado en fechas
router.get("/all", getAllReports); // Para obtener todos los reportes
router.put("/:id", updateReport);
router.delete("/:id", deleteReport);

export default router;
