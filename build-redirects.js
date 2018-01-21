const { readFileSync, writeFileSync } = require("fs");

const { GRAPHQL_ENDPOINT } = process.env;

const template = readFileSync("./src/_redirects", "UTF8");

writeFileSync("./public/_redirects", template.replace("API", GRAPHQL_ENDPOINT));
