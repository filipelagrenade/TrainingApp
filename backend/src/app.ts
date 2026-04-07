import cookieParser from "cookie-parser";
import cors from "cors";
import express from "express";
import helmet from "helmet";
import pinoHttp from "pino-http";

import { env } from "./config/env";
import { logger } from "./lib/logger";
import { authMiddleware } from "./middleware/auth";
import { errorMiddleware } from "./middleware/error";
import { apiRouter } from "./routes";

export const createApp = () => {
  const app = express();

  app.use(
    cors({
      origin: env.APP_URL,
      credentials: true,
    }),
  );
  app.use(helmet());
  app.use(express.json({ limit: "1mb" }));
  app.use(cookieParser());
  app.use(pinoHttp({ logger }));
  app.use(authMiddleware);
  app.use("/api/v1", apiRouter);
  app.use(errorMiddleware);

  return app;
};
