var Elm = require("./Main.elm");

var token = localStorage.getItem("ROTEIRO_TOKEN") || "";

var app = Elm.Main.embed(document.getElementById("roteiro"), [
  GRAPHQL_ENDPOINT,
  token
]);

app.ports.saveToken.subscribe(str =>
  localStorage.setItem("ROTEIRO_TOKEN", str)
);
