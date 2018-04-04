const isGoogleFontResponse = (url, response) =>
  url.startsWith("https://fonts.googleapis.com") && response.type === "opaque";

const isIndex = url => {
  const { origin, pathname } = new URL(url);
  return (
    origin === self.location.origin &&
    (pathname === "/" || pathname.startsWith("/app"))
  );
};

const isAsset = url =>
  url.startsWith(self.location.origin) ||
  url.startsWith("https://use.fontawesome.com") ||
  url.startsWith("https://fonts.gstatic.com");

const cacheResponse = (key, response) =>
  caches.open("roteiro-cache").then(cache => cache.put(key, response));

self.addEventListener(
  "fetch",
  e =>
    e.request.url === self.location.origin + "/api"
      ? e
      : e.respondWith(
          fetch(e.request)
            .then(res => {
              if (isGoogleFontResponse(e.request.url, res)) {
                cacheResponse(e.request, res);
              } else if (res.ok && isIndex(e.request.url)) {
                cacheResponse("/index.html", res);
              } else if (res.ok && isAsset(e.request.url)) {
                cacheResponse(e.request, res);
              }
              return res.clone();
            })
            .catch(err =>
              caches
                .match(isIndex(e.request.url) ? "/index.html" : e.request)
                .then(res => res || err)
            )
        )
);
