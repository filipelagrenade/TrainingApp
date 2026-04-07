import { describe, expect, it } from "vitest";

import { cn } from "@/lib/utils";

describe("cn", () => {
  it("merges and de-duplicates tailwind classes", () => {
    expect(cn("px-2 py-2", "px-4", "text-sm")).toBe("py-2 px-4 text-sm");
  });
});
