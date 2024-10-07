import { Router } from "express";
import { registerUser, getUser, loginUser, updateUser, deleteUser } from "../controllers/usersController.js";

const router = Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/:id", getUser);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

export default router;