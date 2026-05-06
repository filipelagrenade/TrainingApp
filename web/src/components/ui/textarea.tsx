import * as React from "react";

import { cn } from "@/lib/utils";

const Textarea = React.forwardRef<HTMLTextAreaElement, React.ComponentProps<"textarea">>(
  ({ className, ...props }, ref) => (
    <textarea
      ref={ref}
      className={cn(
        "flex min-h-24 w-full rounded-md border border-rule bg-surface-raised px-3 py-2.5 text-sm leading-6 text-ink placeholder:text-ink-subtle focus-visible:outline-none focus-visible:border-ink focus-visible:ring-1 focus-visible:ring-ink disabled:opacity-50 transition-colors",
        className,
      )}
      {...props}
    />
  ),
);
Textarea.displayName = "Textarea";

export { Textarea };
