import React from "react";
import { Routes, Route } from "react-router-dom";
import Layout from "./components/Layout.jsx";
import Home from "./routes/Home.jsx";
import State from "./routes/State.jsx";
import County from "./routes/County.jsx";
import CountyExplorer from "./routes/CountyExplorer.jsx";
import GeneralDemographics from "./routes/generalDemographics.jsx";

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/state" element={<State />} />
        <Route path="/county/:fips" element={<County />} />
        <Route path="/counties" element={<CountyExplorer />} />      
        <Route path="/general-demographics" element={<GeneralDemographics />} />
      </Routes>
    </Layout>
  );
}