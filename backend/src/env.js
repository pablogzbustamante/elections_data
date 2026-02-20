import dotenv from "dotenv";
dotenv.config();

const must = (k) => {
  const v = process.env[k];
  if (!v) throw new Error(`Missing env var: ${k}`);
  return v;
};

export const ENV = {
  PORT: Number(process.env.PORT || 8080),
  CORS_ORIGIN: must("CORS_ORIGIN"),
  DB_HOST: must("DB_HOST"),
  DB_PORT: Number(process.env.DB_PORT || 5432),
  DB_NAME: must("DB_NAME"),
  DB_USER: must("DB_USER"),
  DB_PASSWORD: must("DB_PASSWORD"),
  DB_SSL: String(process.env.DB_SSL || "false").toLowerCase() === "true",
  DB_POOL_MAX: Number(process.env.DB_POOL_MAX || 10),
  DB_IDLE_TIMEOUT_MS: Number(process.env.DB_IDLE_TIMEOUT_MS || 30000),
  DB_CONN_TIMEOUT_MS: Number(process.env.DB_CONN_TIMEOUT_MS || 3000)
};
