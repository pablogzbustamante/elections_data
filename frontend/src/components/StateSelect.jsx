import React from "react";

export default function StateSelect({ states, value, onChange }) {
  return (
    <label style={{ display: "block", marginBottom: 12 }}>
      State:
      <select value={value || ""}
        onChange={(e) => onChange(e.target.value)}
        style={{ marginLeft: 8, padding: 6 }}
      >
        <option value="" disabled>
          Select...
        </option>
        {states.map((s) => (
          <option key={s.state_abbr} value={s.state_abbr}>
            {s.state_name} ({s.state_abbr})
          </option>
        ))}
      </select>
    </label>
  );
}