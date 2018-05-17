const { GraphQLServer } = require("graphql-yoga");
const { Prisma } = require("prisma-binding");
const jwt = require("jsonwebtoken");
const { PRISMA_ENDPOINT, APP_SECRET } = process.env;

const resolvers = {
  Query: {
    user: (_, args, context, info) =>
      context.prisma.query.user(
        {
          where: {
            id: args.id
          }
        },
        info
      ),
    positions: (_, args, ctx, info) => {
      const Authorization = ctx.request.get("Authorization");
      const token = Authorization.replace("Bearer ", "");
      const { userId } = jwt.verify(token, APP_SECRET);

      return ctx.prisma.query.positions(
        {
          where: {
            user: { id: userId }
          }
        },
        info
      );
    }
  },
  Mutation: {
    authenticateUser: (_, args, context, info) =>
      context.prisma.query
        .user(
          {
            where: {
              email: args.email
            }
          },
          info
        )
        .then(
          x =>
            x
              ? {
                  id: x.id,
                  email: x.email,
                  token: jwt.sign({ userId: x.id }, APP_SECRET)
                }
              : Error("User not found!")
        ),
    signup: (_, args, context, info) =>
      context.prisma.mutation.createUser(
        {
          data: {
            name: args.name
          }
        },
        info
      )
  }
};

new GraphQLServer({
  typeDefs: "./schema.graphql",
  resolvers,
  context: req => ({
    ...req,
    prisma: new Prisma({
      typeDefs: "./generated/prisma.graphql",
      endpoint: PRISMA_ENDPOINT,
      debug: true
    })
  })
}).start(() =>
  console.log("GraphQL server is running on http://localhost:4000")
);
