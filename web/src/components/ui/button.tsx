import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ink disabled:pointer-events-none disabled:opacity-40 select-none",
  {
    variants: {
      variant: {
        default:
          "bg-ink text-surface hover:bg-ink-soft rounded-md",
        accent:
          "bg-accent text-accent-foreground hover:opacity-90 rounded-md",
        outline:
          "border border-rule bg-transparent text-ink hover:border-rule-strong hover:bg-surface-sunken rounded-md",
        ghost:
          "bg-transparent text-ink hover:bg-surface-sunken rounded-md",
        quiet:
          "bg-transparent text-ink-soft hover:text-ink underline-offset-4 hover:underline px-0 h-auto",
        danger:
          "bg-transparent border border-rule text-danger hover:bg-surface-sunken rounded-md",
      },
      size: {
        default: "h-10 px-4",
        sm: "h-8 px-3 text-xs",
        lg: "h-11 px-6",
        icon: "h-9 w-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";

    return <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />;
  },
);
Button.displayName = "Button";

export { Button, buttonVariants };
