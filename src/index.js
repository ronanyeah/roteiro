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

const app = Elm.Main.embed(
  document.body,
  localStorage.getItem("ROTEIRO_TOKEN")
);

app.ports.saveToken.subscribe(str =>
  localStorage.setItem("ROTEIRO_TOKEN", str)
);

app.ports.clearToken.subscribe(() => localStorage.removeItem("ROTEIRO_TOKEN"));

app.ports.log.subscribe(console.log);
