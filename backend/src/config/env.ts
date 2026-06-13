import { config } from "dotenv";
import { z } from "zod";

config();

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  PORT: z.coerce.number().default(4000),
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  APP_URL: z.string().url().default("http://localhost:3000"),
  SESSION_COOKIE_NAME: z.string().min(1).default("liftiq_session"),
  SESSION_TTL_DAYS: z.coerce.number().min(1).max(365).default(30),
  // Web Push (VAPID) — entirely optional. When either key is missing, all push
  // functionality is inert (no-op) and the app runs normally.
  VAPID_PUBLIC_KEY: z.string().min(1).optional(),
  VAPID_PRIVATE_KEY: z.string().min(1).optional(),
  VAPID_SUBJECT: z.string().min(1).default("mailto:filipe@lagrenade.dev"),
});

export const env = envSchema.parse(process.env);
