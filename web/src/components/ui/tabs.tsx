import type * as React from "react";
import * as TabsPrimitive from "@radix-ui/react-tabs";

import { cn } from "@/lib/utils";

const Tabs = TabsPrimitive.Root;

const TabsList = ({
  className,
  ...props
}: React.ComponentPropsWithoutRef<typeof TabsPrimitive.List>) => (
  <TabsPrimitive.List
    className={cn(
      "inline-flex h-12 items-center rounded-[1.2rem] border border-border/70 bg-card/70 p-1 text-secondary-foreground backdrop-blur-sm",
      className,
    )}
    {...props}
  />
);

const TabsTrigger = ({
  className,
  ...props
}: React.ComponentPropsWithoutRef<typeof TabsPrimitive.Trigger>) => (
  <TabsPrimitive.Trigger
    className={cn(
      "inline-flex items-center justify-center rounded-2xl px-3 py-2 text-sm font-semibold transition-all data-[state=active]:bg-primary/90 data-[state=active]:text-primary-foreground data-[state=active]:shadow-[0_12px_24px_hsl(var(--primary)/0.24)]",
      className,
    )}
    {...props}
  />
);

const TabsContent = ({
  className,
  ...props
}: React.ComponentPropsWithoutRef<typeof TabsPrimitive.Content>) => (
  <TabsPrimitive.Content className={cn("mt-4", className)} {...props} />
);

export { Tabs, TabsContent, TabsList, TabsTrigger };
