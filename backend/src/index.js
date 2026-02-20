import { app } from "./app.js";
import { ENV } from "./env.js";
import { pool } from "./db.js";

async function start() {
  try {
    await pool.query("SELECT 1");
    console.log("DB ok");
  } catch (e) {
    console.error("DB connection failed:", e.message);
  }

  app.listen(ENV.PORT, () => {
    console.log(`API listening on http://localhost:${ENV.PORT}`);
    console.log(`CORS origin: ${ENV.CORS_ORIGIN}`);
  });
}

start();