/**
 * Utility functions for the LiftIQ web dashboard.
 */

import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Combines class names using clsx and tailwind-merge.
 * This is the standard pattern for conditional class names in shadcn/ui.
 *
 * @example
 * cn('text-red-500', isActive && 'font-bold', className)
 */
export const cn = (...inputs: ClassValue[]): string => {
  return twMerge(clsx(inputs));
};
