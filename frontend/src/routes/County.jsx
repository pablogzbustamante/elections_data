import React, { useEffect, useState } from "react";
import { useParams, Link } from "react-router-dom";
import { api } from "../api.js";

function fmtInt(v) {
  if (v == null) return "—";
  const n = typeof v === "number" ? v : Number(String(v).replace(/,/g, ""));
  if (!Number.isFinite(n)) return String(v);
  return n.toLocaleString();
}

function fmtPct01(v) {
  if (v == null) return "—";
  const n = typeof v === "number" ? v : Number(String(v));
  if (!Number.isFinite(n)) return String(v);
  return `${(n * 100).toFixed(2)}%`;
}

export default function County() {
  const { fips } = useParams();
  const [data, setData] = useState(null);
  const [err, setErr] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    setErr("");
    api
      .county(fips)
      .then((x) => setData(x))
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, [fips]);

  if (loading) return <p className="small">Loading county…</p>;
  if (err) return <p>Error: {err}</p>;
  if (!data) return <p className="small">No data.</p>;

  const pop = data.population_2020_population;
  const income = data.income_median_houseold_income;
  const bachelors = data.education_bachelors_degree_or_higher; // puede ser % ya
  const density = data.population_population_per_square_mile;

  const noDemo =
    pop == null && income == null && bachelors == null && density == null;

  return (
    <div>
      <div className="row">
        <div>
          <div className="h2">
            {data.county_name} ({data.state_abbr})
          </div>
          <div className="small">FIPS: {data.county_fips}</div>
        </div>

        <Link to="/state" className="small">
          ← Back to state
        </Link>
      </div>

      <div className="grid" style={{ marginTop: 12, marginBottom: 12 }}>
        <div className="card kpi">
          <div className="label">Winner</div>
          <div className="value">{data.winner_2024 ?? "—"}</div>
        </div>

        <div className="card kpi">
          <div className="label">Total votes</div>
          <div className="value">{fmtInt(data.votes_total)}</div>
        </div>

        <div className="card kpi">
          <div className="label">Trump</div>
          <div className="value">
            {fmtInt(data.votes_trump)} <span className="small">({fmtPct01(data.pct_trump)})</span>
          </div>
        </div>

        <div className="card kpi">
          <div className="label">Harris</div>
          <div className="value">
            {fmtInt(data.votes_harris)} <span className="small">({fmtPct01(data.pct_harris)})</span>
          </div>
        </div>
      </div>

      <div className="card" style={{ marginTop: 18 }}>
        <div className="h2">Demographics</div>

        <div className="grid" style={{ marginTop: 12 }}>
          <div className="card kpi">
            <div className="label">Population (2020)</div>
            <div className="value">{fmtInt(pop)}</div>
          </div>

          <div className="card kpi">
            <div className="label">Median household income</div>
            <div className="value">{fmtInt(income)}</div>
          </div>

          <div className="card kpi">
            <div className="label">Bachelor's degree or higher</div>
            <div className="value">
              {bachelors == null ? "—" : `${Number(bachelors).toFixed(2)}%`}
            </div>
          </div>

          <div className="card kpi">
            <div className="label">Population per sq. mile</div>
            <div className="value">{fmtInt(density)}</div>
          </div>
        </div>

        {noDemo && (
          <div className="small" style={{ marginTop: 10 }}>
            No demographic data available for this county (missing join / source not loaded).
          </div>
        )}
      </div>
    </div>
  );
}