import { Router } from "express";
import { dbQuery } from "../db.js";
import { normalizeLimit } from "../validators.js";

const r = Router();

r.get("/rankings/margin", async (req, res, next) => {
  try {
    const limit = normalizeLimit(req.query.limit, { def: 100, max: 5000 });
    const q = `SELECT * FROM fact.v_county_margin_rank_2024 LIMIT $1`;
    const out = await dbQuery(q, [limit]);
    res.json(out.rows);
  } catch (e) {
    next(e);
  }
});

export default r;