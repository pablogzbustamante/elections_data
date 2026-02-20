--
-- PostgreSQL database dump
--

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-02-19 21:27:25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 18263)
-- Name: dim; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dim;


ALTER SCHEMA dim OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 18264)
-- Name: fact; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA fact;


ALTER SCHEMA fact OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 18262)
-- Name: raw; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA raw;


ALTER SCHEMA raw OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 231 (class 1259 OID 18336)
-- Name: candidate; Type: TABLE; Schema: dim; Owner: postgres
--

CREATE TABLE dim.candidate (
    candidate_id smallint NOT NULL,
    candidate_name text NOT NULL
);


ALTER TABLE dim.candidate OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18335)
-- Name: candidate_candidate_id_seq; Type: SEQUENCE; Schema: dim; Owner: postgres
--

CREATE SEQUENCE dim.candidate_candidate_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dim.candidate_candidate_id_seq OWNER TO postgres;

--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 230
-- Name: candidate_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: dim; Owner: postgres
--

ALTER SEQUENCE dim.candidate_candidate_id_seq OWNED BY dim.candidate.candidate_id;


--
-- TOC entry 227 (class 1259 OID 18297)
-- Name: county; Type: TABLE; Schema: dim; Owner: postgres
--

CREATE TABLE dim.county (
    county_id bigint NOT NULL,
    county_name text NOT NULL,
    state_id smallint NOT NULL,
    county_fips character(5),
    CONSTRAINT ck_county_fips_digits CHECK (((county_fips IS NULL) OR (county_fips ~ '^[0-9]{5}$'::text)))
);


ALTER TABLE dim.county OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18296)
-- Name: county_county_id_seq; Type: SEQUENCE; Schema: dim; Owner: postgres
--

CREATE SEQUENCE dim.county_county_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dim.county_county_id_seq OWNER TO postgres;

--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 226
-- Name: county_county_id_seq; Type: SEQUENCE OWNED BY; Schema: dim; Owner: postgres
--

ALTER SEQUENCE dim.county_county_id_seq OWNED BY dim.county.county_id;


--
-- TOC entry 229 (class 1259 OID 18320)
-- Name: election; Type: TABLE; Schema: dim; Owner: postgres
--

CREATE TABLE dim.election (
    election_id smallint NOT NULL,
    election_year smallint NOT NULL,
    election_type text DEFAULT 'PRES'::text NOT NULL,
    CONSTRAINT ck_election_year CHECK (((election_year >= 1800) AND (election_year <= 2100)))
);


ALTER TABLE dim.election OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18319)
-- Name: election_election_id_seq; Type: SEQUENCE; Schema: dim; Owner: postgres
--

CREATE SEQUENCE dim.election_election_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dim.election_election_id_seq OWNER TO postgres;

--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 228
-- Name: election_election_id_seq; Type: SEQUENCE OWNED BY; Schema: dim; Owner: postgres
--

ALTER SEQUENCE dim.election_election_id_seq OWNED BY dim.election.election_id;


--
-- TOC entry 225 (class 1259 OID 18280)
-- Name: state; Type: TABLE; Schema: dim; Owner: postgres
--

CREATE TABLE dim.state (
    state_id smallint NOT NULL,
    state_name text NOT NULL,
    state_abbr character(2),
    CONSTRAINT ck_state_abbr_len CHECK (((state_abbr IS NULL) OR (char_length(state_abbr) = 2)))
);


ALTER TABLE dim.state OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18279)
-- Name: state_state_id_seq; Type: SEQUENCE; Schema: dim; Owner: postgres
--

CREATE SEQUENCE dim.state_state_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dim.state_state_id_seq OWNER TO postgres;

--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 224
-- Name: state_state_id_seq; Type: SEQUENCE OWNED BY; Schema: dim; Owner: postgres
--

ALTER SEQUENCE dim.state_state_id_seq OWNED BY dim.state.state_id;


--
-- TOC entry 238 (class 1259 OID 18446)
-- Name: v_candidates; Type: VIEW; Schema: dim; Owner: postgres
--

CREATE VIEW dim.v_candidates AS
 SELECT candidate_id,
    candidate_name
   FROM dim.candidate
  ORDER BY candidate_name;


ALTER VIEW dim.v_candidates OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 18438)
-- Name: v_counties; Type: VIEW; Schema: dim; Owner: postgres
--

CREATE VIEW dim.v_counties AS
 SELECT c.county_id,
    c.county_name,
    c.county_fips,
    s.state_id,
    s.state_name,
    s.state_abbr
   FROM (dim.county c
     JOIN dim.state s ON ((s.state_id = c.state_id)))
  ORDER BY s.state_name, c.county_name;


ALTER VIEW dim.v_counties OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 18442)
-- Name: v_elections; Type: VIEW; Schema: dim; Owner: postgres
--

CREATE VIEW dim.v_elections AS
 SELECT election_id,
    election_year,
    election_type
   FROM dim.election
  ORDER BY election_year DESC, election_type;


ALTER VIEW dim.v_elections OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 18434)
-- Name: v_states; Type: VIEW; Schema: dim; Owner: postgres
--

CREATE VIEW dim.v_states AS
 SELECT state_id,
    state_name,
    state_abbr
   FROM dim.state
  ORDER BY state_name;


ALTER VIEW dim.v_states OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18396)
-- Name: county_demographics; Type: TABLE; Schema: fact; Owner: postgres
--

CREATE TABLE fact.county_demographics (
    county_id bigint NOT NULL,
    data_year smallint DEFAULT 2020 NOT NULL,
    age_percent_65_and_older numeric(6,2),
    age_percent_under_18_years numeric(6,2),
    age_percent_under_5_years numeric(6,2),
    education_bachelors_degree_or_higher numeric(6,2),
    education_high_school_or_higher numeric(6,2),
    employment_nonemployer_establishments integer,
    ethnicities_american_indian_and_alaska_native_alone numeric(6,2),
    ethnicities_asian_alone numeric(6,2),
    ethnicities_black_alone numeric(6,2),
    ethnicities_hispanic_or_latino numeric(6,2),
    ethnicities_native_hawaiian_and_other_pacific_islander_alone numeric(6,2),
    ethnicities_two_or_more_races numeric(6,2),
    ethnicities_white_alone numeric(6,2),
    ethnicities_white_alone_not_hispanic_or_latino numeric(6,2),
    housing_homeownership_rate numeric(6,2),
    housing_households integer,
    housing_housing_units integer,
    housing_median_value_of_owner_occupied_units integer,
    housing_persons_per_household numeric(6,2),
    income_median_houseold_income integer,
    income_per_capita_income integer,
    miscellaneous_foreign_born numeric(6,2),
    miscellaneous_land_area numeric(12,2),
    miscellaneous_language_other_than_english_at_home numeric(6,2),
    miscellaneous_living_in_same_house_1_years numeric(6,2),
    miscellaneous_manufacturers_shipments bigint,
    miscellaneous_mean_travel_time_to_work numeric(6,2),
    miscellaneous_percent_female numeric(6,2),
    miscellaneous_veterans integer,
    population_2020_population integer,
    population_2010_population integer,
    population_population_per_square_mile numeric(12,2),
    sales_accommodation_and_food_services_sales bigint,
    sales_retail_sales bigint,
    employment_firms_total integer,
    employment_firms_women_owned integer,
    employment_firms_men_owned integer,
    employment_firms_minority_owned integer,
    employment_firms_nonminority_owned integer,
    employment_firms_veteran_owned integer,
    employment_firms_nonveteran_owned integer,
    CONSTRAINT ck_demo_year CHECK (((data_year >= 1800) AND (data_year <= 2100)))
);


ALTER TABLE fact.county_demographics OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 18370)
-- Name: county_election_candidate; Type: TABLE; Schema: fact; Owner: postgres
--

CREATE TABLE fact.county_election_candidate (
    election_id smallint NOT NULL,
    county_id bigint NOT NULL,
    candidate_id smallint NOT NULL,
    votes integer NOT NULL,
    pct numeric(7,4),
    CONSTRAINT ck_pct_range CHECK (((pct IS NULL) OR ((pct >= (0)::numeric) AND (pct <= 1.0)))),
    CONSTRAINT ck_votes_nonneg CHECK ((votes >= 0))
);


ALTER TABLE fact.county_election_candidate OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18349)
-- Name: county_election_summary; Type: TABLE; Schema: fact; Owner: postgres
--

CREATE TABLE fact.county_election_summary (
    election_id smallint NOT NULL,
    county_id bigint NOT NULL,
    votes_total integer NOT NULL,
    winner_name text,
    source_objectid integer,
    winner_candidate_id smallint NOT NULL,
    CONSTRAINT ck_votes_total_nonneg CHECK ((votes_total >= 0))
);


ALTER TABLE fact.county_election_summary OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 18455)
-- Name: v_county_candidate_long_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_county_candidate_long_2024 AS
 SELECT e.election_year,
    e.election_type,
    st.state_abbr,
    st.state_name,
    c.county_id,
    c.county_name,
    c.county_fips,
    cand.candidate_name,
    ec.votes,
    ec.pct
   FROM ((((fact.county_election_candidate ec
     JOIN dim.election e ON ((e.election_id = ec.election_id)))
     JOIN dim.county c ON ((c.county_id = ec.county_id)))
     JOIN dim.state st ON ((st.state_id = c.state_id)))
     JOIN dim.candidate cand ON ((cand.candidate_id = ec.candidate_id)))
  WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text));


ALTER VIEW fact.v_county_candidate_long_2024 OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 18485)
-- Name: v_county_demographics_2020; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_county_demographics_2020 AS
 SELECT st.state_abbr,
    st.state_name,
    c.county_id,
    c.county_name,
    c.county_fips,
    d.data_year,
    d.age_percent_65_and_older,
    d.age_percent_under_18_years,
    d.age_percent_under_5_years,
    d.education_bachelors_degree_or_higher,
    d.education_high_school_or_higher,
    d.employment_nonemployer_establishments,
    d.ethnicities_american_indian_and_alaska_native_alone,
    d.ethnicities_asian_alone,
    d.ethnicities_black_alone,
    d.ethnicities_hispanic_or_latino,
    d.ethnicities_white_alone,
    d.housing_homeownership_rate,
    d.income_median_houseold_income,
    d.population_2020_population,
    d.population_2010_population,
    d.population_population_per_square_mile
   FROM ((fact.county_demographics d
     JOIN dim.county c ON ((c.county_id = d.county_id)))
     JOIN dim.state st ON ((st.state_id = c.state_id)))
  WHERE (d.data_year = 2020);


ALTER VIEW fact.v_county_demographics_2020 OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 18480)
-- Name: v_county_margin_rank_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_county_margin_rank_2024 AS
 WITH x AS (
         SELECT ec.election_id,
            ec.county_id,
            max(ec.votes) AS top_votes
           FROM (fact.county_election_candidate ec
             JOIN dim.election e ON ((e.election_id = ec.election_id)))
          WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
          GROUP BY ec.election_id, ec.county_id
        ), y AS (
         SELECT ec.election_id,
            ec.county_id,
            ec.votes
           FROM (fact.county_election_candidate ec
             JOIN dim.election e ON ((e.election_id = ec.election_id)))
          WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
        ), z AS (
         SELECT y.election_id,
            y.county_id,
            ( SELECT max(y2.votes) AS max
                   FROM y y2
                  WHERE ((y2.election_id = y.election_id) AND (y2.county_id = y.county_id) AND (y2.votes < x.top_votes))) AS second_votes,
            x.top_votes
           FROM (y
             JOIN x ON (((x.election_id = y.election_id) AND (x.county_id = y.county_id))))
          GROUP BY y.election_id, y.county_id, x.top_votes
        )
 SELECT st.state_abbr,
    c.county_name,
    c.county_fips,
    z.top_votes,
    z.second_votes,
    (z.top_votes - COALESCE(z.second_votes, 0)) AS margin_votes
   FROM ((z
     JOIN dim.county c ON ((c.county_id = z.county_id)))
     JOIN dim.state st ON ((st.state_id = c.state_id)))
  ORDER BY (z.top_votes - COALESCE(z.second_votes, 0)) DESC;


ALTER VIEW fact.v_county_margin_rank_2024 OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 18450)
-- Name: v_county_profile_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_county_profile_2024 AS
 SELECT es.election_id,
    st.state_abbr,
    st.state_name,
    c.county_id,
    c.county_name,
    c.county_fips,
    es.votes_total,
    w.candidate_name AS winner_2024,
    max(
        CASE
            WHEN (cand.candidate_name = 'Trump'::text) THEN ec.votes
            ELSE NULL::integer
        END) AS votes_trump,
    max(
        CASE
            WHEN (cand.candidate_name = 'Harris'::text) THEN ec.votes
            ELSE NULL::integer
        END) AS votes_harris,
    max(
        CASE
            WHEN (cand.candidate_name = 'Stein'::text) THEN ec.votes
            ELSE NULL::integer
        END) AS votes_stein,
    max(
        CASE
            WHEN (cand.candidate_name = 'Trump'::text) THEN ec.pct
            ELSE NULL::numeric
        END) AS pct_trump,
    max(
        CASE
            WHEN (cand.candidate_name = 'Harris'::text) THEN ec.pct
            ELSE NULL::numeric
        END) AS pct_harris,
    max(
        CASE
            WHEN (cand.candidate_name = 'Stein'::text) THEN ec.pct
            ELSE NULL::numeric
        END) AS pct_stein,
    d.population_2020_population,
    d.income_median_houseold_income,
    d.education_bachelors_degree_or_higher,
    d.population_population_per_square_mile
   FROM (((((((fact.county_election_summary es
     JOIN dim.election e ON ((e.election_id = es.election_id)))
     JOIN dim.county c ON ((c.county_id = es.county_id)))
     JOIN dim.state st ON ((st.state_id = c.state_id)))
     LEFT JOIN dim.candidate w ON ((w.candidate_id = es.winner_candidate_id)))
     LEFT JOIN fact.county_election_candidate ec ON (((ec.election_id = es.election_id) AND (ec.county_id = es.county_id))))
     LEFT JOIN dim.candidate cand ON ((cand.candidate_id = ec.candidate_id)))
     LEFT JOIN fact.county_demographics d ON (((d.county_id = es.county_id) AND (d.data_year = 2020))))
  WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
  GROUP BY es.election_id, st.state_abbr, st.state_name, c.county_id, c.county_name, c.county_fips, es.votes_total, w.candidate_name, d.population_2020_population, d.income_median_houseold_income, d.education_bachelors_degree_or_higher, d.population_population_per_square_mile;


ALTER VIEW fact.v_county_profile_2024 OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 18475)
-- Name: v_national_candidate_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_national_candidate_2024 AS
 SELECT cnd.candidate_name,
    sum(ec.votes) AS votes,
    round(((sum(ec.votes))::numeric / NULLIF(sum(sum(ec.votes)) OVER (), (0)::numeric)), 6) AS pct
   FROM ((fact.county_election_candidate ec
     JOIN dim.election e ON ((e.election_id = ec.election_id)))
     JOIN dim.candidate cnd ON ((cnd.candidate_id = ec.candidate_id)))
  WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
  GROUP BY cnd.candidate_name
  ORDER BY (sum(ec.votes)) DESC;


ALTER VIEW fact.v_national_candidate_2024 OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 18470)
-- Name: v_national_summary_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_national_summary_2024 AS
 WITH nat AS (
         SELECT sum(es.votes_total) AS votes_total
           FROM (fact.county_election_summary es
             JOIN dim.election e ON ((e.election_id = es.election_id)))
          WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
        ), cand AS (
         SELECT cnd.candidate_name,
            sum(ec.votes) AS votes
           FROM ((fact.county_election_candidate ec
             JOIN dim.election e ON ((e.election_id = ec.election_id)))
             JOIN dim.candidate cnd ON ((cnd.candidate_id = ec.candidate_id)))
          WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
          GROUP BY cnd.candidate_name
        ), winner AS (
         SELECT cand.candidate_name,
            cand.votes
           FROM cand
          ORDER BY cand.votes DESC
         LIMIT 1
        )
 SELECT nat.votes_total,
    w.candidate_name AS winner_national,
    w.votes AS winner_votes_national,
    round(((w.votes)::numeric / (NULLIF(nat.votes_total, 0))::numeric), 6) AS winner_pct_national
   FROM (nat
     CROSS JOIN winner w);


ALTER VIEW fact.v_national_summary_2024 OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 18465)
-- Name: v_state_candidate_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_state_candidate_2024 AS
 SELECT st.state_id,
    st.state_abbr,
    st.state_name,
    cand.candidate_name,
    sum(ec.votes) AS votes,
    round(((sum(ec.votes))::numeric / NULLIF(sum(sum(ec.votes)) OVER (PARTITION BY st.state_id), (0)::numeric)), 6) AS pct
   FROM ((((fact.county_election_candidate ec
     JOIN dim.election e ON ((e.election_id = ec.election_id)))
     JOIN dim.county c ON ((c.county_id = ec.county_id)))
     JOIN dim.state st ON ((st.state_id = c.state_id)))
     JOIN dim.candidate cand ON ((cand.candidate_id = ec.candidate_id)))
  WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
  GROUP BY st.state_id, st.state_abbr, st.state_name, cand.candidate_name;


ALTER VIEW fact.v_state_candidate_2024 OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 18460)
-- Name: v_state_summary_2024; Type: VIEW; Schema: fact; Owner: postgres
--

CREATE VIEW fact.v_state_summary_2024 AS
 WITH state_totals AS (
         SELECT st.state_id,
            st.state_abbr,
            st.state_name,
            sum(es.votes_total) AS votes_total_state
           FROM (((fact.county_election_summary es
             JOIN dim.election e ON ((e.election_id = es.election_id)))
             JOIN dim.county c ON ((c.county_id = es.county_id)))
             JOIN dim.state st ON ((st.state_id = c.state_id)))
          WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
          GROUP BY st.state_id, st.state_abbr, st.state_name
        ), state_candidate AS (
         SELECT st.state_id,
            cand.candidate_name,
            sum(ec.votes) AS votes_candidate_state
           FROM ((((fact.county_election_candidate ec
             JOIN dim.election e ON ((e.election_id = ec.election_id)))
             JOIN dim.county c ON ((c.county_id = ec.county_id)))
             JOIN dim.state st ON ((st.state_id = c.state_id)))
             JOIN dim.candidate cand ON ((cand.candidate_id = ec.candidate_id)))
          WHERE ((e.election_year = 2024) AND (e.election_type = 'PRES'::text))
          GROUP BY st.state_id, cand.candidate_name
        ), state_winner AS (
         SELECT DISTINCT ON (sc.state_id) sc.state_id,
            sc.candidate_name AS winner_state,
            sc.votes_candidate_state
           FROM state_candidate sc
          ORDER BY sc.state_id, sc.votes_candidate_state DESC
        )
 SELECT t.state_id,
    t.state_abbr,
    t.state_name,
    t.votes_total_state,
    w.winner_state,
    w.votes_candidate_state AS winner_votes_state,
    round(((w.votes_candidate_state)::numeric / (NULLIF(t.votes_total_state, 0))::numeric), 6) AS winner_pct_state
   FROM (state_totals t
     LEFT JOIN state_winner w ON ((w.state_id = t.state_id)));


ALTER VIEW fact.v_state_summary_2024 OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 18272)
-- Name: demographics_data; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.demographics_data (
    county text,
    state text,
    age_percent_65_and_older text,
    age_percent_under_18_years text,
    age_percent_under_5_years text,
    education_bachelors_degree_or_higher text,
    education_high_school_or_higher text,
    employment_nonemployer_establishments text,
    ethnicities_american_indian_and_alaska_native_alone text,
    ethnicities_asian_alone text,
    ethnicities_black_alone text,
    ethnicities_hispanic_or_latino text,
    ethnicities_native_hawaiian_and_other_pacific_islander_alone text,
    ethnicities_two_or_more_races text,
    ethnicities_white_alone text,
    ethnicities_white_alone_not_hispanic_or_latino text,
    housing_homeownership_rate text,
    housing_households text,
    housing_housing_units text,
    housing_median_value_of_owner_occupied_units text,
    housing_persons_per_household text,
    income_median_houseold_income text,
    income_per_capita_income text,
    miscellaneous_foreign_born text,
    miscellaneous_land_area text,
    miscellaneous_language_other_than_english_at_home text,
    miscellaneous_living_in_same_house_1_years text,
    miscellaneous_manufacturers_shipments text,
    miscellaneous_mean_travel_time_to_work text,
    miscellaneous_percent_female text,
    miscellaneous_veterans text,
    population_2020_population text,
    population_2010_population text,
    population_population_per_square_mile text,
    sales_accommodation_and_food_services_sales text,
    sales_retail_sales text,
    employment_firms_total text,
    employment_firms_women_owned text,
    employment_firms_men_owned text,
    employment_firms_minority_owned text,
    employment_firms_nonminority_owned text,
    employment_firms_veteran_owned text,
    employment_firms_nonveteran_owned text,
    _loaded_at timestamp with time zone DEFAULT now() NOT NULL,
    _source_file text
);


ALTER TABLE raw.demographics_data OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 18265)
-- Name: elections_data; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.elections_data (
    objectid text,
    county_name text,
    state_name text,
    state_abbr text,
    fips text,
    votes_tot text,
    votes_trump text,
    votes_harris text,
    votes_stein text,
    pct_trump text,
    pct_harris text,
    pct_stein text,
    winner_2024 text,
    winner_2020 text,
    winner_2016 text,
    _loaded_at timestamp with time zone DEFAULT now() NOT NULL,
    _source_file text
);


ALTER TABLE raw.elections_data OWNER TO postgres;

--
-- TOC entry 4950 (class 2604 OID 18339)
-- Name: candidate candidate_id; Type: DEFAULT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.candidate ALTER COLUMN candidate_id SET DEFAULT nextval('dim.candidate_candidate_id_seq'::regclass);


--
-- TOC entry 4947 (class 2604 OID 18300)
-- Name: county county_id; Type: DEFAULT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.county ALTER COLUMN county_id SET DEFAULT nextval('dim.county_county_id_seq'::regclass);


--
-- TOC entry 4948 (class 2604 OID 18323)
-- Name: election election_id; Type: DEFAULT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.election ALTER COLUMN election_id SET DEFAULT nextval('dim.election_election_id_seq'::regclass);


--
-- TOC entry 4946 (class 2604 OID 18283)
-- Name: state state_id; Type: DEFAULT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.state ALTER COLUMN state_id SET DEFAULT nextval('dim.state_state_id_seq'::regclass);


--
-- TOC entry 4978 (class 2606 OID 18347)
-- Name: candidate candidate_candidate_name_key; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.candidate
    ADD CONSTRAINT candidate_candidate_name_key UNIQUE (candidate_name);


--
-- TOC entry 4980 (class 2606 OID 18345)
-- Name: candidate candidate_pkey; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.candidate
    ADD CONSTRAINT candidate_pkey PRIMARY KEY (candidate_id);


--
-- TOC entry 4966 (class 2606 OID 18310)
-- Name: county county_county_fips_key; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.county
    ADD CONSTRAINT county_county_fips_key UNIQUE (county_fips);


--
-- TOC entry 4968 (class 2606 OID 18308)
-- Name: county county_pkey; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.county
    ADD CONSTRAINT county_pkey PRIMARY KEY (county_id);


--
-- TOC entry 4974 (class 2606 OID 18332)
-- Name: election election_pkey; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.election
    ADD CONSTRAINT election_pkey PRIMARY KEY (election_id);


--
-- TOC entry 4960 (class 2606 OID 18290)
-- Name: state state_pkey; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.state
    ADD CONSTRAINT state_pkey PRIMARY KEY (state_id);


--
-- TOC entry 4962 (class 2606 OID 18294)
-- Name: state state_state_abbr_key; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.state
    ADD CONSTRAINT state_state_abbr_key UNIQUE (state_abbr);


--
-- TOC entry 4964 (class 2606 OID 18292)
-- Name: state state_state_name_key; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.state
    ADD CONSTRAINT state_state_name_key UNIQUE (state_name);


--
-- TOC entry 4972 (class 2606 OID 18312)
-- Name: county uq_county_state_name; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.county
    ADD CONSTRAINT uq_county_state_name UNIQUE (state_id, county_name);


--
-- TOC entry 4976 (class 2606 OID 18334)
-- Name: election uq_election; Type: CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.election
    ADD CONSTRAINT uq_election UNIQUE (election_year, election_type);


--
-- TOC entry 4988 (class 2606 OID 18404)
-- Name: county_demographics county_demographics_pkey; Type: CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_demographics
    ADD CONSTRAINT county_demographics_pkey PRIMARY KEY (county_id, data_year);


--
-- TOC entry 4986 (class 2606 OID 18380)
-- Name: county_election_candidate county_election_candidate_pkey; Type: CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_candidate
    ADD CONSTRAINT county_election_candidate_pkey PRIMARY KEY (election_id, county_id, candidate_id);


--
-- TOC entry 4982 (class 2606 OID 18359)
-- Name: county_election_summary county_election_summary_pkey; Type: CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_summary
    ADD CONSTRAINT county_election_summary_pkey PRIMARY KEY (election_id, county_id);


--
-- TOC entry 4969 (class 1259 OID 18410)
-- Name: ix_county_fips; Type: INDEX; Schema: dim; Owner: postgres
--

CREATE INDEX ix_county_fips ON dim.county USING btree (county_fips);


--
-- TOC entry 4970 (class 1259 OID 18411)
-- Name: ix_county_state; Type: INDEX; Schema: dim; Owner: postgres
--

CREATE INDEX ix_county_state ON dim.county USING btree (state_id);


--
-- TOC entry 4989 (class 1259 OID 18413)
-- Name: ix_demo_county; Type: INDEX; Schema: fact; Owner: postgres
--

CREATE INDEX ix_demo_county ON fact.county_demographics USING btree (county_id);


--
-- TOC entry 4983 (class 1259 OID 18412)
-- Name: ix_elec_summary_county; Type: INDEX; Schema: fact; Owner: postgres
--

CREATE INDEX ix_elec_summary_county ON fact.county_election_summary USING btree (county_id);


--
-- TOC entry 4984 (class 1259 OID 18423)
-- Name: ix_summary_winner_candidate; Type: INDEX; Schema: fact; Owner: postgres
--

CREATE INDEX ix_summary_winner_candidate ON fact.county_election_summary USING btree (winner_candidate_id);


--
-- TOC entry 4990 (class 2606 OID 18313)
-- Name: county county_state_id_fkey; Type: FK CONSTRAINT; Schema: dim; Owner: postgres
--

ALTER TABLE ONLY dim.county
    ADD CONSTRAINT county_state_id_fkey FOREIGN KEY (state_id) REFERENCES dim.state(state_id);


--
-- TOC entry 4997 (class 2606 OID 18405)
-- Name: county_demographics county_demographics_county_id_fkey; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_demographics
    ADD CONSTRAINT county_demographics_county_id_fkey FOREIGN KEY (county_id) REFERENCES dim.county(county_id);


--
-- TOC entry 4994 (class 2606 OID 18391)
-- Name: county_election_candidate county_election_candidate_candidate_id_fkey; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_candidate
    ADD CONSTRAINT county_election_candidate_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES dim.candidate(candidate_id);


--
-- TOC entry 4995 (class 2606 OID 18386)
-- Name: county_election_candidate county_election_candidate_county_id_fkey; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_candidate
    ADD CONSTRAINT county_election_candidate_county_id_fkey FOREIGN KEY (county_id) REFERENCES dim.county(county_id);


--
-- TOC entry 4996 (class 2606 OID 18381)
-- Name: county_election_candidate county_election_candidate_election_id_fkey; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_candidate
    ADD CONSTRAINT county_election_candidate_election_id_fkey FOREIGN KEY (election_id) REFERENCES dim.election(election_id);


--
-- TOC entry 4991 (class 2606 OID 18365)
-- Name: county_election_summary county_election_summary_county_id_fkey; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_summary
    ADD CONSTRAINT county_election_summary_county_id_fkey FOREIGN KEY (county_id) REFERENCES dim.county(county_id);


--
-- TOC entry 4992 (class 2606 OID 18360)
-- Name: county_election_summary county_election_summary_election_id_fkey; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_summary
    ADD CONSTRAINT county_election_summary_election_id_fkey FOREIGN KEY (election_id) REFERENCES dim.election(election_id);


--
-- TOC entry 4993 (class 2606 OID 18417)
-- Name: county_election_summary fk_summary_winner_candidate; Type: FK CONSTRAINT; Schema: fact; Owner: postgres
--

ALTER TABLE ONLY fact.county_election_summary
    ADD CONSTRAINT fk_summary_winner_candidate FOREIGN KEY (winner_candidate_id) REFERENCES dim.candidate(candidate_id);


ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA dim GRANT SELECT ON TABLES TO app_reader;


--
-- TOC entry 2139 (class 826 OID 18428)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: fact; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA fact GRANT SELECT ON TABLES TO app_reader;


-- Completed on 2026-02-19 21:27:25

--
-- PostgreSQL database dump complete
--