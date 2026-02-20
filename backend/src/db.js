import pg from "pg";
import { ENV } from "./env.js";

const { Pool } = pg;

export const pool = new Pool({
  host: ENV.DB_HOST,
  port: ENV.DB_PORT,
  database: ENV.DB_NAME,
  user: ENV.DB_USER,
  password: ENV.DB_PASSWORD,
  ssl: ENV.DB_SSL ? { rejectUnauthorized: false } : false,
  max: ENV.DB_POOL_MAX,
  idleTimeoutMillis: ENV.DB_IDLE_TIMEOUT_MS,
  connectionTimeoutMillis: ENV.DB_CONN_TIMEOUT_MS
});

export async function dbQuery(text, params) {
  const client = await pool.connect();
  try {
    return await client.query(text, params);
  } finally {
    client.release();
  }
}