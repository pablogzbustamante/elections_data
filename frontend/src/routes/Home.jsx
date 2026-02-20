import React, { useEffect, useState } from "react";
import { api } from "../api.js";

function fmtInt(v) {
  if (v == null) return "—";
  const n = typeof v === "number" ? v : Number(String(v).replace(/,/g, ""));
  if (!Number.isFinite(n)) return String(v);
  return n.toLocaleString();
}

function fmtPct(v) {
  if (v == null) return "—";
  const n = typeof v === "number" ? v : Number(String(v));
  if (!Number.isFinite(n)) return String(v);
  return `${(n * 100).toFixed(2)}%`;
}

export default function Home() {
  const [data, setData] = useState(null);
  const [err, setErr] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    setLoading(true);
    api.nationalSummary()
      .then((x) => {
        if (!alive) return;
        setData(x);
        setErr("");
      })
      .catch((e) => alive && setErr(e.message))
      .finally(() => alive && setLoading(false));
    return () => {
      alive = false;
    };
  }, []);

  if (loading) return <p className="small">Loading national summary…</p>;
  if (err) return <p>Error: {err}</p>;
  if (!data) return <p className="small">No data.</p>;

  const votesTotal = data.votes_total;
  const winner = data.winner_national;
  const winnerVotes = data.winner_votes_national;
  const winnerPct = data.winner_pct_national;

  return (
    <div>
      <div className="h2">National results</div>

      <div className="grid" style={{ marginBottom: 12 }}>
        <div className="card kpi">
          <div className="label">Winner</div>
          <div className="value">{winner ?? "—"}</div>
        </div>

        <div className="card kpi">
          <div className="label">Winner votes</div>
          <div className="value">{fmtInt(winnerVotes)}</div>
        </div>

        <div className="card kpi">
          <div className="label">Winner share</div>
          <div className="value">{fmtPct(winnerPct)}</div>
        </div>
      </div>

      <div className="card kpi" style={{ marginBottom: 12 }}>
        <div className="label">Total votes</div>
        <div className="value">{fmtInt(votesTotal)}</div>
      </div>

    </div>
  );
}
