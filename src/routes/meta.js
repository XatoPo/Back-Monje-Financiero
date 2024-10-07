import { Router } from "express";
import { insertMeta, getMeta, getAllMeta, updateMeta, deleteMeta } from "../controllers/metaController.js";

const router = Router();

router.post("/", insertMeta);
router.get("/:id", getMeta);
router.get("/", getAllMeta);
router.put("/:id", updateMeta);
router.delete("/:id", deleteMeta);

export default router;