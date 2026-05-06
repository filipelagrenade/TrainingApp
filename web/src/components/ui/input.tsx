import * as React from "react";

import { cn } from "@/lib/utils";

const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<"input">>(
  ({ className, type, ...props }, ref) => {
    const isNumeric = type === "number" || props.inputMode === "numeric" || props.inputMode === "decimal";
    return (
      <input
        ref={ref}
        type={type}
        className={cn(
          "flex h-10 w-full rounded-md border border-rule bg-surface-raised px-3 py-2 text-sm text-ink placeholder:text-ink-subtle focus-visible:outline-none focus-visible:border-ink focus-visible:ring-1 focus-visible:ring-ink disabled:opacity-50 disabled:cursor-not-allowed transition-colors",
          isNumeric && "font-mono tabular-nums",
          className,
        )}
        {...props}
      />
    );
  },
);
Input.displayName = "Input";

export { Input };
