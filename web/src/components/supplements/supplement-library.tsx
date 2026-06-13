"use client";

import { Layers, Repeat } from "lucide-react";
import { useState } from "react";

import { EmptyState } from "@/components/ui/empty-state";
import { Segmented } from "@/components/ui/segmented";

import { SupplementList } from "./supplement-list";

type LibraryView = "supplements" | "stacks" | "cycles";

const VIEW_OPTIONS: ReadonlyArray<{ value: LibraryView; label: string }> = [
  { value: "supplements", label: "Supplements" },
  { value: "stacks", label: "Stacks" },
  { value: "cycles", label: "Cycles" },
];

/**
 * Library tab shell. A Segmented sub-nav switches between the supplement
 * catalog, stacks, and cycles. Supplements is fully implemented; Stacks and
 * Cycles are placeholders until their follow-up task — drop <SupplementStacks/>
 * / <SupplementCycles/> into the switch below when they land.
 */
export const SupplementLibrary = () => {
  const [view, setView] = useState<LibraryView>("supplements");

  return (
    <div className="space-y-5">
      <Segmented options={VIEW_OPTIONS} value={view} onChange={setView} />

      {view === "supplements" ? <SupplementList /> : null}

      {view === "stacks" ? (
        <EmptyState
          icon={Layers}
          title="Stacks coming next"
          description="Group supplements you take together so Today can offer one-tap “take all”."
        />
      ) : null}

      {view === "cycles" ? (
        <EmptyState
          icon={Repeat}
          title="Cycles coming next"
          description="On/off cycles and phases that drive the Today cycle position chips."
        />
      ) : null}
    </div>
  );
};
