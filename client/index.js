require("../node_modules/@fortawesome/fontawesome-free/scss/fontawesome.scss");
require("../node_modules/@fortawesome/fontawesome-free/scss/solid.scss");

const Elm = require("./Main.elm");

const app = Elm.Main.embed(document.body, {
  maybeAuth: localStorage.getItem("ROTEIRO"),
  size: {
    width: window.innerWidth,
    height: window.innerHeight
  },
  apiUrl: API_URL
});

app.ports.saveAuth.subscribe(auth => localStorage.setItem("ROTEIRO", auth));

app.ports.clearAuth.subscribe(() => localStorage.removeItem("ROTEIRO"));

app.ports.log.subscribe(console.log);