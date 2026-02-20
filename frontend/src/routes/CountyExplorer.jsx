import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api.js";

function fmtInt(v) {
  if (v == null) return "—";
  const n = typeof v === "number" ? v : Number(String(v).replace(/,/g, ""));
  if (!Number.isFinite(n)) return String(v);
  return n.toLocaleString();
}

function cleanStates(list) {
  const byAbbr = new Map();
  for (const s of list || []) {
    const abbr = String(s.state_abbr || "").trim();
    if (!abbr) continue;
    const name = String(s.state_name || "").trim();
    const prev = byAbbr.get(abbr);
    if (!prev) byAbbr.set(abbr, s);
    else {
      const prevName = String(prev.state_name || "").trim();
      if (!prevName && name) byAbbr.set(abbr, s);
    }
  }
  return Array.from(byAbbr.values())
    .filter((s) => String(s.state_name || "").trim() !== "")
    .sort((a, b) => String(a.state_name).localeCompare(String(b.state_name)));
}

export default function CountyExplorer() {
  const [states, setStates] = useState([]);
  const [stateAbbr, setStateAbbr] = useState("");
  const [rows, setRows] = useState([]);
  const [q, setQ] = useState("");
  const [err, setErr] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    api.states()
      .then((x) => setStates(cleanStates(x)))
      .catch((e) => setErr(e.message));
  }, []);

  useEffect(() => {
    setErr("");
    setLoading(true);
    api.mapCounties(stateAbbr || undefined)
      .then((x) => setRows(Array.isArray(x) ? x : []))
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, [stateAbbr]);

  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    if (!needle) return rows;
    return rows.filter((r) => String(r.county_name || "").toLowerCase().includes(needle));
  }, [rows, q]);

  return (
    <div>
      <div className="row">
        <div>
          <div className="h2">County explorer</div>
          <div className="small">Busca condados por nombre (opcional filtrar por estado).</div>
        </div>

        <div style={{ display: "flex", gap: 10, minWidth: 520 }}>
          <select className="input" value={stateAbbr} onChange={(e) => setStateAbbr(e.target.value)}>
            <option value="">All states</option>
            {states.map((s) => (
              <option key={s.state_abbr} value={s.state_abbr}>
                {s.state_name} ({s.state_abbr})
              </option>
            ))}
          </select>

          <input
            className="input"
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search county…"
          />
        </div>
      </div>

      {err && <p>Error: {err}</p>}
      {loading && <p className="small">Loading…</p>}

      <div className="small" style={{ marginTop: 10, marginBottom: 8 }}>
        Results: {fmtInt(filtered.length)}
      </div>

      <div className="tableWrap">
        <table>
          <thead>
            <tr>
              <th>FIPS</th>
              <th>County</th>
              <th>State</th>
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
                <td>{r.state_abbr}</td>
                <td>{r.winner_2024 ?? "—"}</td>
                <td style={{ textAlign: "right" }}>{fmtInt(r.votes_total)}</td>
                <td>
                  <Link to={`/county/${r.county_fips}`}>Open</Link>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan="6" className="small" style={{ padding: 12 }}>
                  No results
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}