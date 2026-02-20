export function normalizeStateAbbr(v) {
  if (v == null) return null;
  const s = String(v).trim().toUpperCase();
  if (s.length !== 2) return null;
  if (!/^[A-Z]{2}$/.test(s)) return null;
  return s;
}

export function normalizeFips(v) {
  if (v == null) return null;
  const s = String(v).trim();
  if (!/^[0-9]{5}$/.test(s)) return null;
  return s;
}

export function normalizeLimit(v, { def = 100, max = 5000 } = {}) {
  if (v == null || v === "") return def;
  const n = Number(v);
  if (!Number.isFinite(n) || n <= 0) return def;
  return Math.min(Math.floor(n), max);
}