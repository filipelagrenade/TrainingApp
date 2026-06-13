"use client";

import { useState } from "react";

import { Segmented } from "@/components/ui/segmented";

import { SupplementCycles } from "./supplement-cycles";
import { SupplementList } from "./supplement-list";
import { SupplementStacks } from "./supplement-stacks";

type LibraryView = "supplements" | "stacks" | "cycles";

const VIEW_OPTIONS: ReadonlyArray<{ value: LibraryView; label: string }> = [
  { value: "supplements", label: "Supplements" },
  { value: "stacks", label: "Stacks" },
  { value: "cycles", label: "Cycles" },
];

/**
 * Library tab shell. A Segmented sub-nav switches between the supplement
 * catalog, stacks, and cycles.
 */
export const SupplementLibrary = () => {
  const [view, setView] = useState<LibraryView>("supplements");

  return (
    <div className="space-y-5">
      <Segmented options={VIEW_OPTIONS} value={view} onChange={setView} />

      {view === "supplements" ? <SupplementList /> : null}
      {view === "stacks" ? <SupplementStacks /> : null}
      {view === "cycles" ? <SupplementCycles /> : null}
    </div>
  );
};
