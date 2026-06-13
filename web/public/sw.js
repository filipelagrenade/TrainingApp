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

// ── Rest-timer notifications ────────────────────────────────────────────────
// HONEST SCOPE: the web platform cannot reliably fire a *scheduled* local
// notification at a precise future time while the page is fully backgrounded
// without a push server. So this SW only surfaces what the page tells it to:
//   - REST_NOTIFY / REST_DONE / REST_CLEAR are driven by the page while it has
//     execution time (visible, or briefly on visibilitychange→hidden).
//   - As PROGRESSIVE ENHANCEMENT, where the Notification Triggers API exists
//     (some Android Chrome), we ALSO schedule a "Rest done" notification via a
//     TimestampTrigger so the done-alert can fire even if the SW is asleep.
// On platforms without action buttons / triggers (notably iOS PWA), the
// try/catch'd calls degrade silently to a basic notification.

const REST_TAG = "liftiq-rest";
const REST_DONE_TAG = "liftiq-rest-done";

const formatMmss = (totalSeconds) => {
  const safe = Math.max(0, Math.floor(totalSeconds));
  const minutes = Math.floor(safe / 60);
  const seconds = safe % 60;
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
};

const supportsTriggers = () =>
  typeof TimestampTrigger !== "undefined" &&
  typeof Notification !== "undefined" &&
  "showTrigger" in Notification.prototype;

const closeNotificationsByTag = (tag) =>
  self.registration
    .getNotifications({ tag, includeTriggered: true })
    .then((notifications) => notifications.forEach((notification) => notification.close()))
    .catch(() => undefined);

const showRestNotification = ({ endTime, remainingSeconds, label, vibrate }) => {
  const body = `${formatMmss(remainingSeconds)} left${label ? ` · ${label}` : ""}`;

  // Live "Resting" notification with action buttons. Actions are unsupported on
  // iOS — wrapped so a throw never breaks the message handler.
  const live = self.registration
    .showNotification("Resting", {
      tag: REST_TAG,
      body,
      actions: [
        { action: "rest-minus", title: "−15s" },
        { action: "rest-plus", title: "+15s" },
        { action: "rest-skip", title: "Skip" },
      ],
      requireInteraction: true,
      silent: true,
      renotify: false,
      timestamp: endTime,
      data: { endTime },
    })
    .catch(() => undefined);

  // Progressive enhancement: schedule the "Rest done" alert to fire at endTime
  // even if the SW is asleep. Re-show replaces any prior trigger with this tag.
  let scheduled = Promise.resolve();
  if (supportsTriggers()) {
    try {
      scheduled = self.registration
        .showNotification("Rest done", {
          tag: REST_DONE_TAG,
          body: label ? `Back to ${label}` : "Time to lift.",
          showTrigger: new TimestampTrigger(endTime),
          vibrate: vibrate === false ? undefined : [200, 100, 200],
          requireInteraction: false,
          data: { endTime },
        })
        .catch(() => undefined);
    } catch {
      scheduled = Promise.resolve();
    }
  }

  return Promise.all([live, scheduled]);
};

self.addEventListener("message", (event) => {
  if (event.data?.type === "SKIP_WAITING") {
    self.skipWaiting();
    return;
  }

  if (event.data?.type === "REST_NOTIFY") {
    event.waitUntil(showRestNotification(event.data));
    return;
  }

  if (event.data?.type === "REST_DONE") {
    // The page reached zero while hidden and triggers weren't available: fire
    // the alerting done-notification directly.
    const label = event.data.label;
    event.waitUntil(
      self.registration
        .showNotification("Rest's up", {
          tag: REST_TAG,
          body: label ? `Back to ${label}` : "Time to lift.",
          vibrate: [200, 100, 200],
          requireInteraction: false,
          renotify: true,
        })
        .catch(() => undefined),
    );
    return;
  }

  if (event.data?.type === "REST_CLEAR") {
    // Dismiss the live "Resting" notification and cancel any pending done
    // trigger (closing a triggered-but-unfired notification cancels it).
    event.waitUntil(
      Promise.all([
        closeNotificationsByTag(REST_TAG),
        closeNotificationsByTag(REST_DONE_TAG),
      ]),
    );
    return;
  }
});

// Lock-screen action buttons (−15s / +15s / Skip) drive the in-page timer:
// forward the action to every open client; a body tap (no action) just focuses
// the app. The page's REST_ACTION listener calls adjust()/skip() so the
// authoritative in-page interval stays the single source of truth.
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const action = event.action;

  event.waitUntil(
    self.clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clients) => {
        if (action === "rest-minus" || action === "rest-plus" || action === "rest-skip") {
          for (const client of clients) {
            client.postMessage({ type: "REST_ACTION", action });
          }
        }
        const target = clients.find(Boolean);
        if (target) {
          return target.focus();
        }
        // No open window: open the app so the page can take over the timer.
        return self.clients.openWindow ? self.clients.openWindow("/") : undefined;
      })
      .catch(() => undefined),
  );
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
