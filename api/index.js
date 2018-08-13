const { GraphQLServer } = require("graphql-yoga");
const { Prisma } = require("prisma-binding");
const { resolve } = require("path");

const Query = require("./resolvers/query.js");
const Mutation = require("./resolvers/mutation.js");

const { PRISMA_DEBUG, PRISMA_ENDPOINT, PRISMA_SECRET } = require("./config.js");

new GraphQLServer({
  typeDefs: resolve(__dirname, "./schema.graphql"),
  resolvers: {
    Query,
    Mutation
  },
  context: req => ({
    ...req,
    db: new Prisma({
      typeDefs: resolve(__dirname, "./prisma.graphql"),
      endpoint: PRISMA_ENDPOINT,
      secret: PRISMA_SECRET,
      debug: PRISMA_DEBUG === "true"
    })
  })
}).start(({ port }) =>
  console.log(`GraphQL server is running on port ${port}!`)
);
