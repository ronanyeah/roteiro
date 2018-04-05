if (window.navigator.serviceWorker) {
  window.navigator.serviceWorker
    .register("/sw.js")
    .then(console.log)
    .catch(console.error);
}

if (
  window.URLSearchParams &&
  new window.URLSearchParams(document.location.search).get("applaunch") ===
    "true"
) {
  console.log("App Launch!");
}

const Elm = require("./Main.elm");

const getStoredData = () => {
  const data = localStorage.getItem("ROTEIRO");

  if (!data) return null;

  try {
    return JSON.parse(data);
  } catch (_) {
    return null;
  }
};

const app = Elm.Main.embed(document.body, {
  auth: getStoredData()
});

app.ports.saveAuth.subscribe(auth =>
  localStorage.setItem("ROTEIRO", JSON.stringify(auth))
);

app.ports.clearAuth.subscribe(() => localStorage.removeItem("ROTEIRO"));

app.ports.log.subscribe(console.log);
