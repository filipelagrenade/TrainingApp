// LiftIQ service worker — offline-resilient PWA shell.
//
// Caching strategy by request type (GET only; non-GET always passes through):
//   - Navigations (request.mode === "navigate"): NETWORK-FIRST. Always prefer the
//     live network so a fresh deploy is picked up immediately; on success we update
//     the cached app-shell document, on failure (offline) we serve the last cached
//     shell. This avoids the cache-first "stale-version trap" that bricks PWAs.
//   - /_next/static/ assets: CACHE-FIRST. These are content-hashed + immutable, so a
//     cached copy is always correct and lets the shell's JS/CSS load offline.
//   - /api/ requests: NEVER cached, NEVER intercepted (auth cookies; the query
//     persistence layer handles API data offline).
//   - Other same-origin static (svg/png/fonts/etc): STALE-WHILE-REVALIDATE.
//
// Every handler is wrapped so a cache miss/throw can never block the response — it
// always falls through to a plain network fetch.

const CACHE_NAME = "liftiq-v4";
const SHELL_URL = "/";

self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then((cache) =>
        // Precache the app shell so the very first offline navigation has a document
        // to serve. Best-effort: never let a failed precache abort installation.
        cache.add(SHELL_URL).catch(() => undefined),
      )
      .catch(() => undefined),
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))),
      )
      .then(() => self.clients.claim())
      .catch(() => undefined),
  );
});

self.addEventListener("message", (event) => {
  if (event.data?.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});

// Background Sync: when the browser regains connectivity it fires this; we nudge all
// open clients to flush their offline completion queue. Progressive enhancement only —
// the page also flushes on its own "online"/visibilitychange events.
self.addEventListener("sync", (event) => {
  if (event.tag === "liftiq-flush-queue") {
    event.waitUntil(
      self.clients
        .matchAll({ includeUncontrolled: true, type: "window" })
        .then((clients) => {
          for (const client of clients) {
            client.postMessage({ type: "FLUSH_QUEUE" });
          }
        })
        .catch(() => undefined),
    );
  }
});

const isNextStaticAsset = (url) => url.pathname.startsWith("/_next/static/");

// Network-first for navigations. Prefer fresh network; cache successful navigation
// documents (stale-while-revalidate of the shell) so the last-visited shell is
// available offline. On failure, serve the cached navigation, then the precached "/"
// shell, then a minimal inline fallback so the browser never shows its error page.
const handleNavigation = async (request) => {
  const cache = await caches.open(CACHE_NAME);
  let pathname = "";
  try {
    pathname = new URL(request.url).pathname;
  } catch {
    pathname = "";
  }

  try {
    const networkResponse = await fetch(request);
    if (networkResponse && networkResponse.ok) {
      // Remember this specific route's document for offline reloads. We do NOT
      // overwrite the precached "/" shell here — otherwise a cold offline start
      // at "/" could serve some other route's HTML at the home URL.
      cache.put(request, networkResponse.clone()).catch(() => undefined);
      if (pathname === SHELL_URL) {
        cache.put(SHELL_URL, networkResponse.clone()).catch(() => undefined);
      }
    }
    return networkResponse;
  } catch {
    const cachedForRequest = await cache.match(request);
    if (cachedForRequest) {
      return cachedForRequest;
    }

    const cachedShell = await cache.match(SHELL_URL);
    if (cachedShell) {
      return cachedShell;
    }

    return new Response(
      "<!doctype html><html><head><meta charset=\"utf-8\"><title>LiftIQ</title></head><body><p>You are offline. Reconnect to continue.</p></body></html>",
      { status: 200, headers: { "Content-Type": "text/html; charset=utf-8" } },
    );
  }
};

// Cache-first for immutable content-hashed assets.
const handleStaticAsset = async (request) => {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);
  if (cached) {
    return cached;
  }

  const networkResponse = await fetch(request);
  if (networkResponse && networkResponse.ok) {
    cache.put(request, networkResponse.clone()).catch(() => undefined);
  }
  return networkResponse;
};

// Stale-while-revalidate for other same-origin static files.
const handleStaleWhileRevalidate = async (request) => {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);
  const networkPromise = fetch(request)
    .then((networkResponse) => {
      if (networkResponse && networkResponse.ok) {
        cache.put(request, networkResponse.clone()).catch(() => undefined);
      }
      return networkResponse;
    })
    .catch(() => cached);

  return cached ?? networkPromise;
};

self.addEventListener("fetch", (event) => {
  const { request } = event;

  if (request.method !== "GET") {
    return;
  }

  let url;
  try {
    url = new URL(request.url);
  } catch {
    return;
  }

  // Same-origin only; cross-origin requests (CDNs, analytics) are left untouched.
  if (url.origin !== self.location.origin) {
    return;
  }

  // Never touch the API: auth cookies + the persistence layer own offline data.
  if (url.pathname.startsWith("/api/")) {
    return;
  }

  if (request.mode === "navigate") {
    event.respondWith(handleNavigation(request).catch(() => fetch(request)));
    return;
  }

  if (isNextStaticAsset(url)) {
    event.respondWith(handleStaticAsset(request).catch(() => fetch(request)));
    return;
  }

  event.respondWith(handleStaleWhileRevalidate(request).catch(() => fetch(request)));
});
