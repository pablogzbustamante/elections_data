import { Router } from "express";
import { dbQuery } from "../db.js";

const r = Router();

r.get("/health", async (req, res, next) => {
  try {
    const out = await dbQuery("SELECT 1 AS ok", []);
    res.json({ ok: true, db: out.rows?.[0]?.ok === 1 });
  } catch (e) {
    next(e);
  }
});

export default r;
