var Elm = require("./Main.elm");

var token = localStorage.getItem("ROTEIRO_TOKEN") || prompt("Token?");

localStorage.setItem("ROTEIRO_TOKEN", token);

Elm.Main.embed(document.getElementById("roteiro"), [GRAPHQL_ENDPOINT, token]);
