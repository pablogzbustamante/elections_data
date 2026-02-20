import { Router } from "express";
import { dbQuery } from "../db.js";
import { normalizeStateAbbr } from "../validators.js";

const r = Router();

r.get("/states", async (req, res, next) => {
  try {
    const q = "SELECT * FROM dim.v_states ORDER BY state_name";
    const out = await dbQuery(q, []);
    res.json(out.rows);
  } catch (e) {
    next(e);
  }
});

r.get("/counties", async (req, res, next) => {
  try {
    const abbr = normalizeStateAbbr(req.query.state_abbr);
    if (!abbr) return res.status(400).json({ error: "Invalid state_abbr" });

    const q = `SELECT * FROM dim.v_counties WHERE state_abbr = $1 ORDER BY county_name`;
    const out = await dbQuery(q, [abbr]);
    res.json(out.rows);
  } catch (e) {
    next(e);
  }
});

export default r;