const { GraphQLServer } = require("graphql-yoga");
const { Prisma } = require("prisma-binding");
const jwt = require("jsonwebtoken");
const bcryptjs = require("bcryptjs");
const validator = require("validator");
const { promisify } = require("util");
const { resolve } = require("path");
const { dissoc, evolve, pipe, assoc } = require("ramda");
const { PRISMA_DEBUG, PRISMA_ENDPOINT, APP_SECRET } = process.env;

const verify = promisify(jwt.verify);
const sign = promisify(jwt.sign);

const getUserId = async req => {
  const authHeader = req.get("Authorization");
  if (!authHeader) throw Error("Unauthorised!");

  const token = authHeader.replace("Bearer ", "");
  const { userId } = await verify(token, APP_SECRET);

  return userId;
};

const clean = pipe(
  dissoc("id"),
  evolve({
    steps: xs => ({ set: xs }),
    notes: xs => ({ set: xs }),
    startPosition: id => ({ connect: { id } }),
    endPosition: id => ({ connect: { id } }),
    position: id => ({ connect: { id } })
  })
);

const resolvers = {
  Query: {
    user: async (_, __, ctx, info) =>
      ctx.db.query.user(
        {
          where: {
            id: await getUserId(ctx.request)
          }
        },
        info
      ),

    positions: async (_, args, ctx, info) =>
      ctx.db.query.positions(
        {
          where: {
            user: { id: await getUserId(ctx.request) }
          }
        },
        info
      ),

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

    transitions: async (_, args, ctx, info) =>
      ctx.db.query.transitions(
        {
          where: {
            user: { id: await getUserId(ctx.request) }
          }
        },
        info
      ),

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

    submissions: async (_, args, ctx, info) =>
      ctx.db.query.submissions(
        {
          where: {
            user: { id: await getUserId(ctx.request) }
          }
        },
        info
      ),

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

    tags: async (_, args, ctx, info) =>
      ctx.db.query.tags(
        {
          where: {
            user: { id: await getUserId(ctx.request) }
          }
        },
        info
      ),

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

    topics: async (_, args, ctx, info) =>
      ctx.db.query.topics(
        {
          where: {
            user: { id: await getUserId(ctx.request) }
          }
        },
        info
      ),

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
    updatePosition: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      const isOwner = await ctx.db.exists.Position({
        AND: [{ id: args.id }, { user: { id: userId } }]
      });

      if (!isOwner) {
        return Error("Oops!");
      }

      return ctx.db.mutation.updatePosition(
        {
          data: clean(args),
          where: { id: args.id }
        },
        info
      );
    },

    updateSubmission: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      const isOwner = await ctx.db.exists.Submission({
        AND: [{ id: args.id }, { user: { id: userId } }]
      });

      if (!isOwner) {
        return Error("Oops!");
      }

      return ctx.db.mutation.updateSubmission(
        {
          data: clean(args),
          where: { id: args.id }
        },
        info
      );
    },

    updateTag: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      const isOwner = await ctx.db.exists.Tag({
        AND: [{ id: args.id }, { user: { id: userId } }]
      });

      if (!isOwner) {
        return Error("Oops!");
      }

      return ctx.db.mutation.updateTag(
        {
          data: clean(args),
          where: { id: args.id }
        },
        info
      );
    },

    updateTopic: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      const isOwner = await ctx.db.exists.Topic({
        AND: [{ id: args.id }, { user: { id: userId } }]
      });

      if (!isOwner) {
        return Error("Oops!");
      }

      return ctx.db.mutation.updateTopic(
        {
          data: clean(args),
          where: { id: args.id }
        },
        info
      );
    },

    updateTransition: async (_, args, ctx, info) => {
      const userId = await getUserId(ctx.request);

      const isOwner = await ctx.db.exists.Transition({
        AND: [{ id: args.id }, { user: { id: userId } }]
      });

      if (!isOwner) {
        return Error("Oops!");
      }

      return ctx.db.mutation.updateTransition(
        {
          data: clean(args),
          where: { id: args.id }
        },
        info
      );
    },

    createPosition: async (_, args, ctx, info) =>
      ctx.db.mutation.createPosition(
        {
          data: assoc(
            "user",
            { connect: { id: await getUserId(ctx.request) } },
            clean(args)
          )
        },
        info
      ),

    createSubmission: async (_, args, ctx, info) =>
      ctx.db.mutation.createSubmission(
        {
          data: assoc(
            "user",
            { connect: { id: await getUserId(ctx.request) } },
            clean(args)
          )
        },
        info
      ),

    createTransition: async (_, args, ctx, info) =>
      ctx.db.mutation.createTransition(
        {
          data: assoc(
            "user",
            { connect: { id: await getUserId(ctx.request) } },
            clean(args)
          )
        },
        info
      ),

    createTag: async (_, args, ctx, info) =>
      ctx.db.mutation.createTag(
        {
          data: assoc(
            "user",
            { connect: { id: await getUserId(ctx.request) } },
            clean(args)
          )
        },
        info
      ),

    createTopic: async (_, args, ctx, info) =>
      ctx.db.mutation.createTopic(
        {
          data: assoc(
            "user",
            { connect: { id: await getUserId(ctx.request) } },
            clean(args)
          )
        },
        info
      ),

    authenticateUser: async (_, { email, password }, ctx, _info) => {
      const user = await ctx.db.query.user(
        { where: { email } },
        "{ id, email, password }"
      );

      if (!validator.isEmail(email)) {
        return Error("Not a valid email address!");
      }

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

    signUpUser: async (_, args, ctx, _info) =>
      !validator.isEmail(args.email)
        ? Error("Not a valid email address!")
        : ctx.db.mutation
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
  typeDefs: resolve(__dirname, "./schema.graphql"),
  resolvers,
  context: req => ({
    ...req,
    db: new Prisma({
      typeDefs: resolve(__dirname, "../prisma/generated/prisma.graphql"),
      endpoint: PRISMA_ENDPOINT,
      debug: PRISMA_DEBUG === "true"
    })
  })
}).start(() =>
  console.log("GraphQL server is running on http://localhost:4000")
);
