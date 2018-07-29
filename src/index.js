require("../node_modules/@fortawesome/fontawesome-free/scss/fontawesome.scss");
require("../node_modules/@fortawesome/fontawesome-free/scss/solid.scss");
require("./fonts.scss");

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

const app = Elm.Main.embed(document.body, {
  auth: localStorage.getItem("ROTEIRO")
});

app.ports.saveAuth.subscribe(auth =>
  localStorage.setItem("ROTEIRO", JSON.stringify(auth))
);

app.ports.clearAuth.subscribe(() => localStorage.removeItem("ROTEIRO"));

app.ports.log.subscribe(console.log);
