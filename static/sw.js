const cacheName = "roteiro-cache-4";

const assets = [
  "/",
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
    fetch(e.request).catch(err =>
      caches.match(e.request).then(response => response || err)
    )
  )
);
