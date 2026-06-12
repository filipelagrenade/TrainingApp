"use client";

import { GitCompareArrows, MoreHorizontal, Users } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { useKeypad } from "@/components/ui/keypad-context";
import { formatDuration } from "@/lib/workout-tracking";

import { useWorkoutEditor } from "./workout-editor-context";

/** Compact sticky header: title, elapsed time, sync badge, Finish, invite, tools. */
export const WorkoutHeader = ({
  elapsedSeconds,
  finishDisabled,
  finishLabel,
  onFinish,
  onOpenCompare,
  onOpenInvite,
  onOpenTools,
}: {
  elapsedSeconds: number;
  finishDisabled: boolean;
  finishLabel: string;
  onFinish: () => void;
  onOpenCompare: () => void;
  onOpenInvite: () => void;
  onOpenTools: () => void;
}) => {
  const { draft, session, syncState } = useWorkoutEditor();
  const { closeKeypad } = useKeypad();

  // Dialogs/sheets sit under the keypad's z-index; close (and commit) it first.
  const withKeypadClosed = (action: () => void) => () => {
    closeKeypad();
    action();
  };

  return (
    <div className="sticky top-0 z-[30] -mx-5 border-b border-rule bg-surface/95 px-5 py-2 backdrop-blur-sm">
      <div className="flex items-center gap-2">
        <div className="min-w-0 flex-1">
          <h1 className="truncate text-base font-semibold text-ink">{draft.title}</h1>
          <div className="mt-0.5 flex items-center gap-2">
            <span className="num text-xs text-ink-muted">{formatDuration(elapsedSeconds)}</span>
            <Badge variant="outline" className="px-1.5 py-0 text-[10px]">
              {syncState === "saving" ? "Saving…" : syncState === "error" ? "Pending" : "Synced"}
            </Badge>
            {session.pausedAt ? (
              <Badge variant="secondary" className="px-1.5 py-0 text-[10px]">
                Paused
              </Badge>
            ) : null}
          </div>
        </div>
        {session.inviteId ? (
          <Button
            aria-label="Compare with your workout mate"
            size="icon"
            type="button"
            variant="outline"
            onClick={withKeypadClosed(onOpenCompare)}
          >
            <GitCompareArrows className="h-4 w-4" />
          </Button>
        ) : null}
        <Button
          aria-label="Invite a mate to this workout"
          size="icon"
          type="button"
          variant="outline"
          onClick={withKeypadClosed(onOpenInvite)}
        >
          <Users className="h-4 w-4" />
        </Button>
        <Button
          aria-label="Open workout tools"
          size="icon"
          type="button"
          variant="outline"
          onClick={withKeypadClosed(onOpenTools)}
        >
          <MoreHorizontal className="h-4 w-4" />
        </Button>
        <Button disabled={finishDisabled} type="button" variant="accent" onClick={withKeypadClosed(onFinish)}>
          {finishLabel}
        </Button>
      </div>
    </div>
  );
};
