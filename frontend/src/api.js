const API_BASE = import.meta.env.VITE_API_BASE;

async function getJson(path) {
  const r = await fetch(`${API_BASE}${path}`);
  if (!r.ok) {
    const msg = await r.text().catch(() => "");
    throw new Error(`HTTP ${r.status} ${msg}`);
  }
  return r.json();
}

export const api = {
  states: () => getJson("/states"),
  geoStates: () => getJson("/api/geo/states"),
  geoCounties: (stateAbbr) => getJson(`/api/geo/counties?state=${encodeURIComponent(stateAbbr)}`),
  generalDemographics: ({ stateAbbr, countyFips } = {}) => {
    const qs = new URLSearchParams();
    if (stateAbbr) qs.set("state", stateAbbr);
    if (countyFips) qs.set("county_fips", countyFips);
    const suffix = qs.toString();
    return getJson(`/api/general-demographics${suffix ? `?${suffix}` : ""}`);
  },

  nationalSummary: () => getJson("/national/summary"),

  stateSummary: (stateAbbr) =>
    getJson(`/state/summary?state_abbr=${stateAbbr}`),

  mapCounties: (stateAbbr) => {
    if (!stateAbbr) return getJson("/map/counties");
    return getJson(`/map/counties?state_abbr=${stateAbbr}`);
  },

  county: (fips) =>
    getJson(`/county?fips=${fips}`),
};