-- AddForeignKey
ALTER TABLE "SupplementReminderLog" ADD CONSTRAINT "SupplementReminderLog_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES "SupplementSchedule"("id") ON DELETE CASCADE ON UPDATE CASCADE;
