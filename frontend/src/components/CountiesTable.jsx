import React, { useMemo, useState } from "react";
import { Link } from "react-router-dom";

export default function CountiesTable({ rows }) {
  const [q, setQ] = useState("");

  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    if (!needle) return rows;
    return rows.filter((r) => String(r.county_name || "").toLowerCase().includes(needle));
  }, [rows, q]);

  return (
    <div>
      <label style={{ display: "block", marginBottom: 8 }}>
        Search county:
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          style={{ marginLeft: 8, padding: 6, width: 320 }}
          placeholder="e.g. Harris"
        />
      </label>

      <div style={{ overflowX: "auto" }}>
        <table cellPadding="8" style={{ borderCollapse: "collapse", width: "100%" }}>
          <thead>
            <tr>
              <th align="left">FIPS</th>
              <th align="left">County</th>
              <th align="left">State</th>
              <th align="right">Votes total</th>
              <th align="left">Winner 2024</th>
              <th align="left">Detail</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((r) => (
              <tr key={r.county_fips} style={{ borderTop: "1px solid #ddd" }}>
                <td>{r.county_fips}</td>
                <td>{r.county_name}</td>
                <td>{r.state_abbr}</td>
                <td align="right">{r.votes_total?.toLocaleString?.() ?? r.votes_total}</td>
                <td>{r.winner_2024}</td>
                <td>
                  <Link to={`/county/${r.county_fips}`}>Open</Link>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan="6" style={{ padding: 12 }}>
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
