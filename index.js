const { GraphQLServer } = require("graphql-yoga");
const { Prisma } = require("prisma-binding");
const jwt = require("jsonwebtoken");
const bcryptjs = require("bcryptjs");
const validator = require("validator");
const { promisify } = require("util");
const { PRISMA_ENDPOINT, APP_SECRET } = process.env;

const verify = promisify(jwt.verify);
const sign = promisify(jwt.sign);

const getUserId = async req => {
  const authHeader = req.get("Authorization");
  if (!authHeader) throw Error("Unauthorised!");

  const token = authHeader.replace("Bearer ", "");
  const { userId } = await verify(token, APP_SECRET);

  return userId;
};

const resolvers = {
  Query: {
    user: (_, args, context, info) =>
      context.db.query.user(
        {
          where: {
            id: args.id
          }
        },
        info
      ),

    positions: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query.positions(
        {
          where: {
            user: { id: userId }
          }
        },
        info
      );
    },

    position: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query
        .positions(
          {
            where: {
              AND: [{ id: args.id }, { user: { id: userId } }]
            }
          },
          info
        )
        .then(([x]) => x || null);
    },

    transitions: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query.transitions(
        {
          where: {
            user: { id: userId }
          }
        },
        info
      );
    },

    transition: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query
        .transitions(
          {
            where: {
              AND: [{ id: args.id }, { user: { id: userId } }]
            }
          },
          info
        )
        .then(([x]) => x || null);
    },

    submissions: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query.submissions(
        {
          where: {
            user: { id: userId }
          }
        },
        info
      );
    },

    submission: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query
        .submissions(
          {
            where: {
              AND: [{ id: args.id }, { user: { id: userId } }]
            }
          },
          info
        )
        .then(([x]) => x || null);
    },

    tags: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query.tags(
        {
          where: {
            user: { id: userId }
          }
        },
        info
      );
    },

    tag: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query
        .tags(
          {
            where: {
              AND: [{ id: args.id }, { user: { id: userId } }]
            }
          },
          info
        )
        .then(([x]) => x || null);
    },

    topics: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query.topics(
        {
          where: {
            user: { id: userId }
          }
        },
        info
      );
    },

    topic: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      return ctx.db.query
        .topics(
          {
            where: {
              AND: [{ id: args.id }, { user: { id: userId } }]
            }
          },
          info
        )
        .then(([x]) => x || null);
    }
  },
  Mutation: {
    authenticateUser: async (_, { email, password }, ctx, _info) => {
      const user = await ctx.db.query.user(
        { where: { email } },
        "{ id, email, password }"
      );

      if (!user) {
        return Error("Email is not in use!");
      }

      return (await bcryptjs.compare(password, user.password))
        ? Object.assign(
            {
              token: await sign({ userId: user.id }, APP_SECRET)
            },
            user
          )
        : Error("Incorrect password!");
    },

    signUpUser: async (_, args, context, _info) =>
      !validator.isEmail(args.email)
        ? Error("Not a valid email address!")
        : context.db.mutation
            .createUser(
              {
                data: {
                  ...args,
                  password: await bcryptjs.hash(args.password, 10)
                }
              },
              "{ id, email, password }"
            )
            .then(async user =>
              Object.assign(
                { token: await sign({ userId: user.id }, APP_SECRET) },
                user
              )
            )
  }
};

new GraphQLServer({
  typeDefs: "./schema.graphql",
  resolvers,
  context: req => ({
    ...req,
    db: new Prisma({
      typeDefs: "./generated/prisma.graphql",
      endpoint: PRISMA_ENDPOINT
      //debug: true
    })
  })
}).start(() =>
  console.log("GraphQL server is running on http://localhost:4000")
);
