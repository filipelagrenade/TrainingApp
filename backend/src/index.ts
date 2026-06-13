import { env } from "./config/env";
import { createApp } from "./app";
import { logger } from "./lib/logger";
import { prisma } from "./lib/prisma";
import { configureWebPush } from "./services/push.service";
import { startReminderScheduler, stopReminderScheduler } from "./services/supplement-reminder.service";

const app = createApp();

// Configure Web Push once at startup (no-op when VAPID keys are absent).
configureWebPush();

const server = app.listen(env.PORT, () => {
  logger.info(`LiftIQ backend listening on port ${env.PORT}`);
  // Start the supplement reminder cron (no-op when push is disabled).
  startReminderScheduler();
});

const shutdown = async () => {
  stopReminderScheduler();
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
};

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
