import { Router } from "express";
import { dbQuery } from "../db.js";
import { normalizeFips, normalizeStateAbbr } from "../validators.js";

const router = Router();

router.get("/geo/states", async (req, res) => {
  try {
    const q = `SELECT state_id, state_name, state_abbr FROM dim.v_states ORDER BY state_name;`;
    const { rows } = await dbQuery(q, []);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: "Failed to load states" });
  }
});

router.get("/geo/counties", async (req, res) => {
  const state = normalizeStateAbbr(req.query.state);
  try {
    if (!state) return res.status(400).json({ error: "Invalid state" });

    const q = `SELECT county_fips, county_name FROM dim.v_counties WHERE state_abbr = $1 ORDER BY county_name; `;
    const { rows } = await dbQuery(q, [state]);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: "Failed to load counties" });
  }
});

router.get("/general-demographics", async (req, res) => {
  const state = normalizeStateAbbr(req.query.state);
  const countyFips = normalizeFips(req.query.county_fips);

  if (req.query.state && !state) {
    return res.status(400).json({ error: "Invalid state" });
  }

  if (req.query.county_fips && !countyFips) {
    return res.status(400).json({ error: "Invalid county_fips" });
  }

  if (countyFips && !state) {
    return res.status(400).json({ error: "state is required when county_fips is provided" });
  }

  try {
    const params = [];
    let where = `WHERE d.data_year = 2020`;

    if (state) {
      params.push(state);
      where += ` AND s.state_abbr = $${params.length}`;
    }

    if (countyFips) {
      params.push(countyFips);
      where += ` AND c.county_fips = $${params.length}`;
    }

    const q = `
      SELECT
        SUM(d.population_2020_population)::bigint AS population_2020,
        SUM(d.population_2010_population)::bigint AS population_2010,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.income_median_houseold_income, 0)::numeric * COALESCE(d.population_2020_population, 0)::numeric) / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),0)
          ELSE NULL
        END AS median_income,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.education_bachelors_degree_or_higher, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0), 2)
          ELSE NULL
        END AS education_bachelors_degree_or_higher,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.education_high_school_or_higher, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS education_high_school_or_higher,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(
            SUM(COALESCE(d.age_percent_65_and_older, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS age_percent_65_and_older,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.age_percent_under_18_years, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0), 2)
          ELSE NULL
        END AS age_percent_under_18_years,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.age_percent_under_5_years, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0), 2)
          ELSE NULL
        END AS age_percent_under_5_years,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.ethnicities_white_alone, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0), 2)
          ELSE NULL
        END AS ethnicities_white_alone,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.ethnicities_black_alone, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS ethnicities_black_alone,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.ethnicities_hispanic_or_latino, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS ethnicities_hispanic_or_latino,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.ethnicities_asian_alone, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS ethnicities_asian_alone,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.ethnicities_american_indian_and_alaska_native_alone, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS ethnicities_american_indian_and_alaska_native_alone,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.housing_homeownership_rate, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS housing_homeownership_rate,
        CASE WHEN SUM(COALESCE(d.population_2020_population, 0)) > 0
          THEN ROUND(SUM(COALESCE(d.population_population_per_square_mile, 0) * COALESCE(d.population_2020_population, 0))::numeric / NULLIF(SUM(COALESCE(d.population_2020_population, 0)), 0),2)
          ELSE NULL
        END AS population_per_square_mile
      FROM fact.county_demographics d
      JOIN dim.county c ON c.county_id = d.county_id
      JOIN dim.state s ON s.state_id = c.state_id
      ${where};
    `;

    const { rows } = await dbQuery(q, params);

    res.json({
      scope: {
        state,
        county_fips: countyFips
      },
      stats: rows[0] || null
    });
  } catch (e) {
    console.error("general-demographics query error:", e.message);
    res.status(500).json({ error: "Failed to load general demographics" });
  }
});

export default router;