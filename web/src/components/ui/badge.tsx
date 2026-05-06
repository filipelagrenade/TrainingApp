import { cva, type VariantProps } from "class-variance-authority";
import type { HTMLAttributes } from "react";

import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center gap-1 rounded-sm border px-2 py-0.5 text-[11px] font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "border-rule-strong text-ink-soft",
        outline: "border-rule text-ink-muted",
        accent: "border-transparent bg-accent text-accent-foreground",
        pr: "border-transparent bg-pr-soft text-pr",
        soft: "border-transparent bg-surface-sunken text-ink-soft",
        // Compat aliases for existing usages
        secondary: "border-transparent bg-surface-sunken text-ink-soft",
      },
      caps: {
        true: "uppercase tracking-[0.08em] font-mono",
        false: "",
      },
    },
    defaultVariants: {
      variant: "default",
      caps: false,
    },
  },
);

export interface BadgeProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

export const Badge = ({ className, variant, caps, ...props }: BadgeProps) => (
  <div className={cn(badgeVariants({ variant, caps }), className)} {...props} />
);
