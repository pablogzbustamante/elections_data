import React from "react";
import { NavLink } from "react-router-dom";

export default function Layout({ children }) {
  return (
    <div className="container">
      <div className="topbar">
        <div className="brand">
          <div style={{ width: 12, height: 12, borderRadius: 4, background: "var(--accent)" }} />
          <h1 className="h1">2024 Elections Data</h1>
          <span className = "badge">Pablo Gonzalez Bustamante - 0273179</span>
        </div>
        <span className="badge">2024</span>
      </div>

      <div className="shell">
        <aside className="card">
          <div className="h2">Navigation</div>
          <div className="nav">
            <NavLink to="/" className={({ isActive }) => (isActive ? "active" : "")}>
              Home
            </NavLink>
            <NavLink to="/state" className={({ isActive }) => (isActive ? "active" : "")}>
              State explorer
            </NavLink>
            <NavLink to="/counties" className={({ isActive }) => (isActive ? "active" : "")}>
                County explorer
            </NavLink>
            <NavLink to="/general-demographics" className={({ isActive }) => (isActive ? "active" : "")}>
              General demographics
            </NavLink>
          </div>
        </aside>
        <main className="card">{children}</main>
      </div>
    </div>
  );
}