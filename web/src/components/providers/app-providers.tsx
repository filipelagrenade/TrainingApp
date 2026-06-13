"use client";

import { QueryClient } from "@tanstack/react-query";
import { PersistQueryClientProvider } from "@tanstack/react-query-persist-client";
import { useState, type ReactNode } from "react";
import { Toaster } from "sonner";

import { OfflineIndicator } from "@/components/layout/offline-indicator";
import {
  APP_CACHE_VERSION,
  QUERY_PERSIST_MAX_AGE,
  createQueryPersister,
} from "@/lib/offline-cache";

import { ServiceWorkerRegistration } from "./service-worker-registration";
import { ThemeProvider } from "./theme-provider";

export const AppProviders = ({ children }: { children: ReactNode }) => {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 3 * 60 * 1000,
            gcTime: 24 * 60 * 60 * 1000,
            retry: 1,
            refetchOnWindowFocus: false,
            // Serve cached data instantly (incl. offline) and refetch when online.
            networkMode: "offlineFirst",
          },
        },
      }),
  );

  // Lazily created so it only touches IndexedDB in the browser, never during SSR.
  const [persister] = useState(() => createQueryPersister());

  return (
    <PersistQueryClientProvider
      client={queryClient}
      persistOptions={{
        persister,
        maxAge: QUERY_PERSIST_MAX_AGE,
        buster: APP_CACHE_VERSION,
        dehydrateOptions: {
          // Only persist successful queries — never write error/pending states to disk.
          shouldDehydrateQuery: (query) => query.state.status === "success",
        },
      }}
    >
      <ThemeProvider>
        <ServiceWorkerRegistration />
        {children}
        <OfflineIndicator />
        <Toaster richColors position="top-right" />
      </ThemeProvider>
    </PersistQueryClientProvider>
  );
};
