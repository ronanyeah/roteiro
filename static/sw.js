self.addEventListener("fetch", e =>
  e.respondWith(
    fetch(e.request)
      .then(res => {
        if (
          res.ok &&
          !e.request.url.startsWith(self.location.origin + "/api")
        ) {
          caches.open("roteiro-cache").then(cache => cache.put(e.request, res));
        }
        return res.clone();
      })
      .catch(err => caches.match(e.request).then(res => res || err))
  )
);
