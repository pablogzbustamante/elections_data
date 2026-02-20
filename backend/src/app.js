import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import { ENV } from "./env.js";

import healthRouter from "./routes/health.js";
import catalogRouter from "./routes/catalog.js";
import mapRouter from "./routes/map.js";
import rankingsRouter from "./routes/rankings.js";
import generalDemographicsRouter from "./routes/generalDemographics.js";


export const app = express();

app.use(helmet());
app.use(express.json({ limit: "1mb" }));

app.use(
  cors({
    origin: ENV.CORS_ORIGIN,
    methods: ["GET", "OPTIONS"],
    allowedHeaders: ["Content-Type"]
  })
);

app.use(morgan("tiny"));

app.get("/", (req, res) => res.json({ ok: true, service: "elections-backend" }));

app.use("/api", generalDemographicsRouter);
app.use(healthRouter);
app.use(catalogRouter);
app.use(mapRouter);
app.use(rankingsRouter);

app.use((req, res) => res.status(404).json({ error: "Not found" }));

app.use((err, req, res, next) => {
  console.error("ERROR:", err);
  res.status(500).json({ error: "Internal server error" });
});