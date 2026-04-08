import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-2xl text-sm font-semibold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default:
          "border border-primary/20 bg-primary text-primary-foreground shadow-[0_14px_32px_hsl(var(--primary)/0.28)] hover:-translate-y-0.5 hover:bg-primary/90",
        secondary:
          "border border-accent/10 bg-accent/85 text-accent-foreground shadow-[0_12px_28px_hsl(var(--accent)/0.18)] hover:-translate-y-0.5 hover:bg-accent/75",
        outline:
          "border border-border/75 bg-card/70 text-foreground backdrop-blur-sm hover:-translate-y-0.5 hover:border-primary/20 hover:bg-secondary/60",
        ghost: "border border-transparent bg-transparent text-muted-foreground hover:bg-secondary/65 hover:text-foreground",
      },
      size: {
        default: "h-11 px-4 py-2",
        sm: "h-9 px-3",
        lg: "h-12 px-6",
        icon: "h-10 w-10",
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
