const cacheName = "roteiro-cache-1";

const assets = [
  "/",
  "/index.html",
  "/bundle.js",
  "/manifest.json",
  "map.png",
  "map.svg",
  "favicon.ico"
];

self.addEventListener("install", e =>
  e.waitUntil(caches.open(cacheName).then(cache => cache.addAll(assets)))
);

self.addEventListener(
  "activate",
  e => (
    e.waitUntil(
      caches
        .keys()
        .then(cacheKeys =>
          Promise.all(
            cacheKeys
              .filter(key => key !== cacheName)
              .map(key => caches.delete(key))
          )
        )
    ),
    self.clients.claim()
  )
);

self.addEventListener("fetch", e =>
  e.respondWith(
    caches.match(e.request).then(response => response || fetch(e.request))
  )
);
