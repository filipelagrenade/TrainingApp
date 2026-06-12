import type { LucideIcon } from "lucide-react";
import type { ReactNode } from "react";

import { cn } from "@/lib/utils";

export const EmptyState = ({
  icon: Icon,
  title,
  description,
  action,
  className,
}: {
  icon?: LucideIcon;
  title: string;
  description?: string;
  action?: ReactNode;
  className?: string;
}) => (
  <div
    className={cn(
      "flex flex-col items-center justify-center gap-3 rounded-md border border-dashed border-rule px-6 py-10 text-center",
      className,
    )}
  >
    {Icon ? <Icon className="h-6 w-6 text-ink-subtle" strokeWidth={1.5} /> : null}
    <div className="space-y-1">
      <p className="text-sm font-medium text-ink">{title}</p>
      {description ? <p className="text-sm text-ink-muted">{description}</p> : null}
    </div>
    {action ? <div className="mt-1">{action}</div> : null}
  </div>
);
