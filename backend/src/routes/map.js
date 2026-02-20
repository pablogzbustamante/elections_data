import { Router } from "express";
import { dbQuery } from "../db.js";
import { normalizeStateAbbr, normalizeFips } from "../validators.js";

const r = Router();

r.get("/map/counties", async (req, res, next) => {
  try {
    const abbr = normalizeStateAbbr(req.query.state_abbr);

    if (abbr) {
      const q = `SELECT * FROM fact.v_county_profile_2024 WHERE state_abbr = $1 ORDER BY county_name`;
      const out = await dbQuery(q, [abbr]);
      return res.json(out.rows);
    }

    const qAll = `SELECT * FROM fact.v_county_profile_2024 ORDER BY state_abbr, county_name`;
    const outAll = await dbQuery(qAll, []);
    res.json(outAll.rows);
  } catch (e) {
    next(e);
  }
});

r.get("/county", async (req, res, next) => {
  try {
    const fips = normalizeFips(req.query.fips);
    if (!fips) return res.status(400).json({ error: "Invalid fips" });

    const q = `SELECT * FROM fact.v_county_profile_2024 WHERE county_fips = $1 LIMIT 1`;
    const out = await dbQuery(q, [fips]);
    if (out.rows.length === 0) return res.status(404).json({ error: "Not found" });
    res.json(out.rows[0]);
  } catch (e) {
    next(e);
  }
});

r.get("/state/summary", async (req, res, next) => {
  try {
    const abbr = normalizeStateAbbr(req.query.state_abbr);

    if (abbr) {
      const q = `SELECT * FROM fact.v_state_summary_2024 WHERE state_abbr = $1 LIMIT 1`;
      const out = await dbQuery(q, [abbr]);
      if (out.rows.length === 0) return res.status(404).json({ error: "Not found" });
      return res.json(out.rows[0]);
    }

    const qAll = `SELECT * FROM fact.v_state_summary_2024 ORDER BY state_abbr`;
    const outAll = await dbQuery(qAll, []);
    res.json(outAll.rows);
  } catch (e) {
    next(e);
  }
});

r.get("/national/summary", async (req, res, next) => {
  try {
    const q = `SELECT * FROM fact.v_national_summary_2024`;
    const out = await dbQuery(q, []);
    res.json(out.rows[0] || null);
  } catch (e) {
    next(e);
  }
});

export default r;