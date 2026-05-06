import type * as React from "react";
import * as ProgressPrimitive from "@radix-ui/react-progress";

import { cn } from "@/lib/utils";

export const Progress = ({
  className,
  value,
  indicatorClassName,
  ...props
}: React.ComponentPropsWithoutRef<typeof ProgressPrimitive.Root> & {
  indicatorClassName?: string;
}) => (
  <ProgressPrimitive.Root
    className={cn(
      "relative h-1 w-full overflow-hidden rounded-full bg-surface-sunken",
      className,
    )}
    value={value}
    {...props}
  >
    <ProgressPrimitive.Indicator
      className={cn("h-full w-full flex-1 bg-ink transition-transform duration-500 ease-[cubic-bezier(0.16,1,0.3,1)]", indicatorClassName)}
      style={{ transform: `translateX(-${100 - (value ?? 0)}%)` }}
    />
  </ProgressPrimitive.Root>
);
