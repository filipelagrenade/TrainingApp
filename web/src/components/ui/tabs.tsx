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
      "inline-flex items-center gap-6 border-b border-rule",
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
      "relative inline-flex items-center justify-center px-0 py-3 text-sm font-medium text-ink-muted transition-colors hover:text-ink focus-visible:outline-none data-[state=active]:text-ink data-[state=active]:after:scale-x-100 after:absolute after:inset-x-0 after:-bottom-px after:h-px after:scale-x-0 after:bg-ink after:transition-transform after:origin-left",
      className,
    )}
    {...props}
  />
);

const TabsContent = ({
  className,
  ...props
}: React.ComponentPropsWithoutRef<typeof TabsPrimitive.Content>) => (
  <TabsPrimitive.Content className={cn("mt-6", className)} {...props} />
);

export { Tabs, TabsContent, TabsList, TabsTrigger };
