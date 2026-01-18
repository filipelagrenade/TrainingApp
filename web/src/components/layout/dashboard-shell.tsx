/**
 * Dashboard Shell Component
 *
 * Container for dashboard page content.
 */

import * as React from 'react';
import { cn } from '@/lib/utils';

interface DashboardShellProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
}

export const DashboardShell = ({
  children,
  className,
  ...props
}: DashboardShellProps): JSX.Element => {
  return (
    <main className={cn('flex-1 overflow-auto', className)} {...props}>
      <div className="container py-6">{children}</div>
    </main>
  );
};
