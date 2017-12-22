if (window.navigator.serviceWorker) {
  window.navigator.serviceWorker
    .register("/sw.js")
    .then(console.log)
    .catch(console.error);
}

if (
  window.URLSearchParams &&
  new URLSearchParams(document.location.search).get("applaunch") === "true"
) {
  console.log("App Launch!");
}

var Elm = require("./Main.elm");

var token = localStorage.getItem("ROTEIRO_TOKEN") || "";

var app = Elm.Main.embed(document.getElementById("roteiro"), [
  GRAPHQL_ENDPOINT,
  token
]);

app.ports.saveToken.subscribe(function(str) {
  return localStorage.setItem("ROTEIRO_TOKEN", str);
});
