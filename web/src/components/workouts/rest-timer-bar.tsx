"use client";

import { Play, Timer } from "lucide-react";

import { Button } from "@/components/ui/button";
import { formatRestTime } from "./hooks/use-rest-timer";
import { useWorkoutEditor } from "./workout-editor-context";

/**
 * Fixed bottom rest-timer bar. While idle it offers a one-tap start at the
 * user's default rest duration; while running it shows the countdown with
 * ±15s and skip. The keypad overlays it when open.
 */
export const RestTimerBar = () => {
  const { isCompletedEdit, restTimer, settings } = useWorkoutEditor();

  if (isCompletedEdit) {
    return null;
  }

  return (
    <div className="fixed inset-x-0 bottom-0 z-[40] border-t border-rule bg-surface-raised pb-[env(safe-area-inset-bottom)]">
      <div className="mx-auto flex max-w-3xl items-center gap-2 px-5 py-2">
        <Timer className="h-4 w-4 shrink-0 text-timer" />
        {restTimer.running ? (
          <>
            <span className="num min-w-[3.5rem] text-xl font-semibold text-timer">
              {formatRestTime(restTimer.remaining)}
            </span>
            <div className="ml-auto flex items-center gap-1.5">
              <Button size="sm" type="button" variant="outline" onClick={() => restTimer.adjust(-15)}>
                −15s
              </Button>
              <Button size="sm" type="button" variant="outline" onClick={() => restTimer.adjust(15)}>
                +15s
              </Button>
              <Button size="sm" type="button" variant="ghost" onClick={restTimer.skip}>
                Skip
              </Button>
            </div>
          </>
        ) : (
          <>
            <span className="text-xs text-ink-muted">Rest timer</span>
            <div className="ml-auto flex items-center gap-1.5">
              <Button
                size="sm"
                type="button"
                variant="outline"
                onClick={() => restTimer.start(settings.rest.warmupSeconds)}
              >
                {formatRestTime(settings.rest.warmupSeconds)}
              </Button>
              <Button
                className="border-timer/40 text-timer"
                size="sm"
                type="button"
                variant="outline"
                onClick={() => restTimer.start(settings.rest.workingSeconds)}
              >
                <Play className="h-3.5 w-3.5" />
                Rest {formatRestTime(settings.rest.workingSeconds)}
              </Button>
            </div>
          </>
        )}
      </div>
    </div>
  );
};
