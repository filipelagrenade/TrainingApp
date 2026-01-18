/**
 * LiftIQ Web Dashboard - Root Layout
 *
 * This is the root layout for the Next.js application.
 * It provides:
 * - Global providers (TanStack Query, Jotai, Theme)
 * - Metadata configuration
 * - Font loading
 */

import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ThemeProvider } from '@/components/providers/theme-provider';
import { QueryProvider } from '@/components/providers/query-provider';
import { Toaster } from '@/components/ui/sonner';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: {
    default: 'LiftIQ - AI Workout Assistant',
    template: '%s | LiftIQ',
  },
  description: 'Track your workouts with AI-powered progressive overload coaching',
  keywords: ['workout', 'fitness', 'gym', 'progressive overload', 'AI coach'],
  authors: [{ name: 'LiftIQ Team' }],
  creator: 'LiftIQ',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://liftiq.app',
    siteName: 'LiftIQ',
    title: 'LiftIQ - AI Workout Assistant',
    description: 'Track your workouts with AI-powered progressive overload coaching',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'LiftIQ - AI Workout Assistant',
    description: 'Track your workouts with AI-powered progressive overload coaching',
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}): JSX.Element {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          <QueryProvider>
            {children}
            <Toaster />
          </QueryProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
