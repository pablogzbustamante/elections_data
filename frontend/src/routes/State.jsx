import React, { useEffect, useMemo, useState } from "react";
import { api } from "../api.js";
import { Link } from "react-router-dom";



function fmtInt(v) {
  if (v == null) return "—";
  const n = typeof v === "number" ? v : Number(String(v).replace(/,/g, ""));
  if (!Number.isFinite(n)) return String(v);
  return n.toLocaleString();
}

export default function State() {
  const [states, setStates] = useState([]);
    function cleanStates(list) {
    const byAbbr = new Map();
    for (const s of list || []) {
        const abbr = String(s.state_abbr || "").trim();
        if (!abbr) continue;
        const name = String(s.state_name || "").trim();

        const prev = byAbbr.get(abbr);
        if (!prev) {
        byAbbr.set(abbr, s);
        } else {
        const prevName = String(prev.state_name || "").trim();
        if (!prevName && name) byAbbr.set(abbr, s);
        }
    }
    return Array.from(byAbbr.values())
        .filter((s) => String(s.state_name || "").trim() !== "")
        .sort((a, b) => String(a.state_name).localeCompare(String(b.state_name)));
    }

  const [stateAbbr, setStateAbbr] = useState("");
  const [summary, setSummary] = useState(null);
  const [counties, setCounties] = useState([]);
  const [q, setQ] = useState("");
  const [err, setErr] = useState("");
  const [loading, setLoading] = useState(false);

    useEffect(() => {
    api.states()
        .then((rows) => setStates(cleanStates(rows)))
        .catch((e) => setErr(e.message));
    }, []);


  useEffect(() => {
    if (!stateAbbr) return;
    setErr("");
    setLoading(true);
    setSummary(null);
    setCounties([]);

    Promise.all([api.stateSummary(stateAbbr), api.mapCounties(stateAbbr)])
      .then(([s, c]) => {
        setSummary(s);
        setCounties(c);
      })
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, [stateAbbr]);

  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    if (!needle) return counties;
    return counties.filter((r) => String(r.county_name || "").toLowerCase().includes(needle));
  }, [counties, q]);

  return (
    <div>
      <div className="row">
        <div>
          <div className="h2">State explorer</div>
          <div className="small">Elige un estado para ver resumen y condados.</div>
        </div>

        <div style={{ minWidth: 320 }}>
          <select
            className="input"
            value={stateAbbr}
            onChange={(e) => setStateAbbr(e.target.value)}
          >
            <option value="" disabled>
              Select a state…
            </option>
            {states
                .filter((s) => s.state_name && s.state_name.trim() !== "")
                .map((s) => (
                    <option key={s.state_abbr} value={s.state_abbr}>
                    {s.state_name} ({s.state_abbr})
                    </option>
                ))}
          </select>
        </div>
      </div>

      {err && <p>Error: {err}</p>}
      {loading && <p className="small">Loading…</p>}

      {summary && (
        <>
          <div className="grid" style={{ marginTop: 12, marginBottom: 12 }}>
            <div className="card kpi">
              <div className="label">Winner</div>
                <div className="value">{summary.winner_state ?? "—"}</div>
            </div>
            <div className="card kpi">
              <div className="label">Total votes</div>
                <div className="value">{fmtInt(summary.votes_total_state)}</div>
            </div>
            <div className="card kpi">
              <div className="label">Counties</div>
              <div className="value">{fmtInt(counties.length)}</div>
            </div>
          </div>
        </>
      )}

      {counties.length > 0 && (
        <>
          <div className="row" style={{ marginTop: 8 }}>
            <div className="h2" style={{ margin: 0 }}>Counties</div>
            <input
              className="input"
              style={{ maxWidth: 360 }}
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search county…"
            />
          </div>

          <div className="tableWrap">
            <table>
              <thead>
                <tr>
                  <th>FIPS</th>
                  <th>County</th>
                  <th>Winner</th>
                  <th style={{ textAlign: "right" }}>Votes</th>
                  <th>Detail</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((r) => (
                  <tr key={r.county_fips}>
                    <td>{r.county_fips}</td>
                    <td>{r.county_name}</td>
                    <td>{r.winner_2024 ?? "—"}</td>
                    <td style={{ textAlign: "right" }}>{fmtInt(r.votes_total)}</td>
                    <td>
                      <Link to={`/county/${r.county_fips}`}>Open</Link>
                    </td>
                  </tr>
                ))}
                {filtered.length === 0 && (
                  <tr>
                    <td colSpan="5" className="small" style={{ padding: 12 }}>
                      No results
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </>
      )}

      {!stateAbbr && (
        <div className="small" style={{ marginTop: 14 }}>
          Selecciona un estado para cargar datos.
        </div>
      )}
    </div>
  );
}