"use client";

import { Timer } from "lucide-react";

import { Button } from "@/components/ui/button";
import { formatRestTime } from "./hooks/use-rest-timer";
import { useWorkoutEditor } from "./workout-editor-context";

/** Fixed bottom rest-timer bar. Hidden while idle; the keypad overlays it. */
export const RestTimerBar = () => {
  const { restTimer } = useWorkoutEditor();

  if (!restTimer.running) {
    return null;
  }

  return (
    <div className="fixed inset-x-0 bottom-0 z-[40] border-t border-rule bg-surface-raised pb-[env(safe-area-inset-bottom)]">
      <div className="mx-auto flex max-w-3xl items-center gap-2 px-5 py-2">
        <Timer className="h-4 w-4 shrink-0 text-timer" />
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
      </div>
    </div>
  );
};
