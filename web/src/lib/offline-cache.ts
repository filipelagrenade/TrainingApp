import { createAsyncStoragePersister } from "@tanstack/query-async-storage-persister";
import { del, get, set } from "idb-keyval";

// Bump this whenever the persisted query shape becomes incompatible; it busts the
// service-worker cache name (manually, in sw.js) and the React Query persist cache.
export const APP_CACHE_VERSION = "v4";

const QUERY_CACHE_KEY = "liftiq-react-query-cache";

// IndexedDB-backed async storage adapter for the React Query persister. IndexedDB
// (via idb-keyval) handles the large, structured query cache far better than
// localStorage and is available in standalone PWA contexts.
const indexedDbStorage = {
  getItem: (key: string) => get<string>(key).then((value) => value ?? null),
  setItem: (key: string, value: string) => set(key, value),
  removeItem: (key: string) => del(key),
};

export const createQueryPersister = () =>
  createAsyncStoragePersister({
    storage: indexedDbStorage,
    key: QUERY_CACHE_KEY,
    // Persist near-immediately so an in-session cache update (e.g. a settings change
    // via setQueryData) is durable before a full-document navigation recreates the
    // client and restores from IndexedDB — otherwise the restore can resurrect stale data.
    throttleTime: 0,
  });

export const QUERY_PERSIST_MAX_AGE = 24 * 60 * 60 * 1000; // 24h
