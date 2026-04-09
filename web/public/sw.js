const CACHE_NAME = "liftiq-static-v3";
const STATIC_PATHS = new Set(["/icon.svg", "/manifest.webmanifest"]);

self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(Promise.resolve());
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener("message", (event) => {
  if (event.data?.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});

const isStaticAsset = (request) => {
  const url = new URL(request.url);

  if (url.origin !== self.location.origin) {
    return false;
  }

  if (url.pathname.startsWith("/api/")) {
    return false;
  }

  if (request.mode === "navigate") {
    return false;
  }

  return STATIC_PATHS.has(url.pathname);
};

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET" || !isStaticAsset(event.request)) {
    return;
  }

  event.respondWith(
    caches.open(CACHE_NAME).then(async (cache) => {
      const cachedResponse = await cache.match(event.request);
      const networkRequest = fetch(event.request)
        .then((networkResponse) => {
          if (networkResponse.ok) {
            cache.put(event.request, networkResponse.clone());
          }

          return networkResponse;
        })
        .catch(() => cachedResponse);

      return cachedResponse ?? networkRequest;
    }),
  );
});
