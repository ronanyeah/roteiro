var Elm = require("./Main.elm");

var token = localStorage.getItem("ROTEIRO_TOKEN") || "";

Elm.Main.embed(document.getElementById("roteiro"), [GRAPHQL_ENDPOINT, token]);
