BEGIN;

-- 1) Election (2024 PRES)
INSERT INTO dim.election (election_year, election_type)
VALUES (2024, 'PRES')
ON CONFLICT (election_year, election_type) DO NOTHING;

-- 2) Candidates from raw (2024)
INSERT INTO dim.candidate (candidate_name)
SELECT DISTINCT x.candidate_name
FROM (
  SELECT NULLIF(trim(winner_2024), '') AS candidate_name
  FROM raw.elections_data
  UNION ALL SELECT 'Trump'
  UNION ALL SELECT 'Harris'
  UNION ALL SELECT 'Stein'
) x
WHERE x.candidate_name IS NOT NULL
ON CONFLICT (candidate_name) DO NOTHING;

-- 3) States (from raw)
INSERT INTO dim.state (state_name, state_abbr)
SELECT DISTINCT
  NULLIF(trim(state_name), '') AS state_name,
  NULLIF(trim(state_abbr), '') AS state_abbr
FROM raw.elections_data
WHERE NULLIF(trim(state_name), '') IS NOT NULL
ON CONFLICT (state_name) DO NOTHING;

-- 4) Counties (from raw) -> uses (state_id, county_name) unique constraint
INSERT INTO dim.county (county_name, state_id, county_fips)
SELECT DISTINCT
  NULLIF(trim(e.county_name), '') AS county_name,
  s.state_id,
  NULLIF(trim(e.fips), '')::char(5) AS county_fips
FROM raw.elections_data e
JOIN dim.state s
  ON s.state_name = NULLIF(trim(e.state_name), '')
WHERE NULLIF(trim(e.county_name), '') IS NOT NULL
ON CONFLICT (state_id, county_name) DO UPDATE
SET county_fips = COALESCE(EXCLUDED.county_fips, dim.county.county_fips);

-- Helpers for ids
-- election_id for 2024 PRES
WITH elec AS (
  SELECT election_id
  FROM dim.election
  WHERE election_year = 2024 AND election_type = 'PRES'
)
-- 5) fact.county_election_summary
INSERT INTO fact.county_election_summary (
  election_id, county_id, votes_total, winner_name, source_objectid, winner_candidate_id
)
SELECT
  elec.election_id,
  c.county_id,
  NULLIF(regexp_replace(e.votes_tot, '[^0-9]', '', 'g'), '')::int AS votes_total,
  NULLIF(trim(e.winner_2024), '') AS winner_name,
  NULLIF(regexp_replace(e.objectid, '[^0-9]', '', 'g'), '')::int AS source_objectid,
  w.candidate_id AS winner_candidate_id
FROM raw.elections_data e
JOIN elec ON true
JOIN dim.state s ON s.state_name = NULLIF(trim(e.state_name), '')
JOIN dim.county c ON c.state_id = s.state_id AND c.county_name = NULLIF(trim(e.county_name), '')
JOIN dim.candidate w ON w.candidate_name = NULLIF(trim(e.winner_2024), '')
ON CONFLICT (election_id, county_id) DO NOTHING;

-- 6) fact.county_election_candidate (Trump/Harris/Stein)
WITH elec AS (
  SELECT election_id
  FROM dim.election
  WHERE election_year = 2024 AND election_type = 'PRES'
),
rows AS (
  SELECT
    e.state_name,
    e.county_name,
    'Trump'::text AS candidate_name,
    e.votes_trump AS votes_txt,
    e.pct_trump AS pct_txt
  FROM raw.elections_data e
  UNION ALL
  SELECT e.state_name, e.county_name, 'Harris', e.votes_harris, e.pct_harris FROM raw.elections_data e
  UNION ALL
  SELECT e.state_name, e.county_name, 'Stein', e.votes_stein, e.pct_stein FROM raw.elections_data e
)
INSERT INTO fact.county_election_candidate (election_id, county_id, candidate_id, votes, pct)
SELECT elec.election_id, c.county_id, cand.candidate_id,
  NULLIF(regexp_replace(r.votes_txt, '[^0-9]', '', 'g'), '')::int AS votes,
  NULLIF(regexp_replace(r.pct_txt, '[^0-9\.]', '', 'g'), '')::numeric AS pct
FROM rows r
JOIN elec ON true
JOIN dim.state s ON s.state_name = NULLIF(trim(r.state_name), '')
JOIN dim.county c ON c.state_id = s.state_id AND c.county_name = NULLIF(trim(r.county_name), '')
JOIN dim.candidate cand ON cand.candidate_name = r.candidate_name
WHERE NULLIF(regexp_replace(r.votes_txt, '[^0-9]', '', 'g'), '') IS NOT NULL
ON CONFLICT (election_id, county_id, candidate_id) DO NOTHING;

-- 7) fact.county_demographics (2020) from raw.demographics_data
-- Assumes raw.demographics_data.state is state name and raw.demographics_data.county is county name.
INSERT INTO fact.county_demographics (
  county_id, data_year,
  age_percent_65_and_older,
  age_percent_under_18_years,
  age_percent_under_5_years,
  education_bachelors_degree_or_higher,
  education_high_school_or_higher,
  income_median_houseold_income,
  population_2020_population,
  population_2010_population,
  population_population_per_square_mile
)
SELECT
  c.county_id,
  2020::smallint AS data_year,
  NULLIF(regexp_replace(d.age_percent_65_and_older, '[^0-9\.]', '', 'g'), '')::numeric(6,2),
  NULLIF(regexp_replace(d.age_percent_under_18_years, '[^0-9\.]', '', 'g'), '')::numeric(6,2),
  NULLIF(regexp_replace(d.age_percent_under_5_years, '[^0-9\.]', '', 'g'), '')::numeric(6,2),
  NULLIF(regexp_replace(d.education_bachelors_degree_or_higher, '[^0-9\.]', '', 'g'), '')::numeric(6,2),
  NULLIF(regexp_replace(d.education_high_school_or_higher, '[^0-9\.]', '', 'g'), '')::numeric(6,2),
  NULLIF(regexp_replace(d.income_median_houseold_income, '[^0-9]', '', 'g'), '')::int,
  NULLIF(regexp_replace(d.population_2020_population, '[^0-9]', '', 'g'), '')::int,
  NULLIF(regexp_replace(d.population_2010_population, '[^0-9]', '', 'g'), '')::int,
  NULLIF(regexp_replace(d.population_population_per_square_mile, '[^0-9\.]', '', 'g'), '')::numeric(12,2)
FROM raw.demographics_data d
JOIN dim.state s ON (
  s.state_abbr = upper(NULLIF(trim(d.state), ''))
  OR s.state_name = NULLIF(trim(d.state), '')
)
JOIN dim.county c ON c.state_id = s.state_id AND c.county_name = NULLIF(trim(d.county), '')
ON CONFLICT (county_id, data_year) DO NOTHING;

COMMIT;
