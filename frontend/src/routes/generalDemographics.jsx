import React, { useEffect, useMemo, useState } from "react";
import { api } from "../api.js";

const EMPTY = "-";
const fmtInt = (v) => (v === null || v === undefined ? EMPTY : Number(v).toLocaleString("en-US"));
const fmtMoney = (v) => (v === null || v === undefined ? EMPTY : `$${Number(v).toLocaleString("en-US")}`);
const fmtPct = (v) => (v === null || v === undefined ? EMPTY : `${Number(v).toFixed(2)}%`);
const fmtNum = (v) => (v === null || v === undefined ? EMPTY : Number(v).toLocaleString("en-US"));
const isStateAbbrAsName = (name) => /^[A-Z]{2}$/.test(String(name || "").trim());

function cleanStates(list) {
  const byAbbr = new Map();
  for (const s of list || []) {
    const abbr = String(s.state_abbr || "").trim();
    if (!abbr) continue;

    const name = String(s.state_name || "").trim();
    if (!name || isStateAbbrAsName(name)) continue;

    const prev = byAbbr.get(abbr);
    if (!prev) {
      byAbbr.set(abbr, s);
      continue;
    }

    const prevName = String(prev.state_name || "").trim();
    if (prevName.length < name.length) byAbbr.set(abbr, s);
  }

  return Array.from(byAbbr.values()).sort((a, b) =>
    String(a.state_name).localeCompare(String(b.state_name))
  );
}

export default function GeneralDemographics() {
  const [states, setStates] = useState([]);
  const [counties, setCounties] = useState([]);

  const [stateAbbr, setStateAbbr] = useState("");
  const [countyFips, setCountyFips] = useState("");

  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState(null);
  const [error, setError] = useState("");

  const scopeLabel = useMemo(() => {
    if (!stateAbbr) return "United States (all states)";
    if (!countyFips) return `${stateAbbr} (all counties)`;
    const countyName = counties.find((c) => c.county_fips === countyFips)?.county_name;
    return countyName ? `${countyName}, ${stateAbbr}` : `${countyFips}, ${stateAbbr}`;
  }, [stateAbbr, countyFips, counties]);

  useEffect(() => {
    api.geoStates()
      .then((rows) => setStates(cleanStates(rows)))
      .catch(() => setStates([]));
  }, []);

  useEffect(() => {
    setCountyFips("");
    if (!stateAbbr) {
      setCounties([]);
      return;
    }

    api.geoCounties(stateAbbr)
      .then((rows) => setCounties(Array.isArray(rows) ? rows : []))
      .catch(() => setCounties([]));
  }, [stateAbbr]);

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await api.generalDemographics({ stateAbbr, countyFips });
      setStats(data?.stats || null);
    } catch (e) {
      setStats(null);
      setError(String(e?.message || e));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="gd-wrap">
      <div className="gd-header">
        <div>
          <div className="gd-title">General demographics</div>
          <div className="gd-subtitle">{scopeLabel}</div>
        </div>

        <div className="gd-filters">
          <div className="gd-field">
            <div className="gd-label">State</div>
            <select className="gd-select" value={stateAbbr} onChange={(e) => setStateAbbr(e.target.value)}>
              <option value="">All states (USA)</option>
              {states.map((s) => (
                <option key={s.state_id} value={s.state_abbr || ""}>
                  {s.state_name}
                </option>
              ))}
            </select>
          </div>

          <div className="gd-field">
            <div className="gd-label">County</div>
            <select
              className="gd-select"
              value={countyFips}
              onChange={(e) => setCountyFips(e.target.value)}
              disabled={!stateAbbr}
            >
              <option value="">{stateAbbr ? "All counties (state)" : "Select a state first"}</option>
              {counties.map((c) => (
                <option key={c.county_fips} value={c.county_fips}>
                  {c.county_name} ({c.county_fips})
                </option>
              ))}
            </select>
          </div>

          <button className="gd-btn" onClick={load} disabled={loading}>
            {loading ? "Loading..." : "Apply filter"}
          </button>
        </div>
      </div>

      {error ? <div className="gd-error">{error}</div> : null}

      <div className="gd-grid">
        <div className="gd-card">
          <div className="gd-card-label">Population (2020)</div>
          <div className="gd-card-value">{fmtInt(stats?.population_2020)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Population (2010)</div>
          <div className="gd-card-value">{fmtInt(stats?.population_2010)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Median income</div>
          <div className="gd-card-value">{fmtMoney(stats?.median_income)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Bachelor's degree or higher</div>
          <div className="gd-card-value">{fmtPct(stats?.education_bachelors_degree_or_higher)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">High school or higher</div>
          <div className="gd-card-value">{fmtPct(stats?.education_high_school_or_higher)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Age 65+ years</div>
          <div className="gd-card-value">{fmtPct(stats?.age_percent_65_and_older)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Age under 18 years</div>
          <div className="gd-card-value">{fmtPct(stats?.age_percent_under_18_years)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Age under 5 years</div>
          <div className="gd-card-value">{fmtPct(stats?.age_percent_under_5_years)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">White alone</div>
          <div className="gd-card-value">{fmtPct(stats?.ethnicities_white_alone)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Black alone</div>
          <div className="gd-card-value">{fmtPct(stats?.ethnicities_black_alone)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Hispanic or Latino</div>
          <div className="gd-card-value">{fmtPct(stats?.ethnicities_hispanic_or_latino)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Asian alone</div>
          <div className="gd-card-value">{fmtPct(stats?.ethnicities_asian_alone)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">American Indian / Alaska Native alone</div>
          <div className="gd-card-value">{fmtPct(stats?.ethnicities_american_indian_and_alaska_native_alone)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Homeownership rate</div>
          <div className="gd-card-value">{fmtPct(stats?.housing_homeownership_rate)}</div>
        </div>

        <div className="gd-card">
          <div className="gd-card-label">Population density (per sq mi)</div>
          <div className="gd-card-value">{fmtNum(stats?.population_per_square_mile)}</div>
        </div>
      </div>
    </div>
  );
}