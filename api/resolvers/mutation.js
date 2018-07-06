const { assoc, prop } = require("ramda");
const bcryptjs = require("bcryptjs");
const validator = require("validator");

const { clean, getUserId, sign, hash } = require("../utils.js");

const { APP_SECRET } = process.env;

const deleteOne = async (ctx, dataName, dataId) => {
  const userId = await getUserId(ctx.request);

  const isOwner = await ctx.db.exists[dataName]({
    AND: [{ id: dataId }, { user: { id: userId } }]
  });

  if (!isOwner) {
    return Error("Oops!");
  }

  return ctx.db.mutation[`delete${dataName}`]({
    where: { id: dataId }
  }).then(prop("id"));
};

module.exports = {
  deletePosition: async (_, args, ctx, _info) =>
    deleteOne(ctx, "Position", args.id),

  deleteSubmission: async (_, args, ctx, _info) =>
    deleteOne(ctx, "Submission", args.id),

  deleteTransition: async (_, args, ctx, _info) =>
    deleteOne(ctx, "Transition", args.id),

  deleteTag: async (_, args, ctx, _info) => deleteOne(ctx, "Tag", args.id),

  deleteTopic: async (_, args, ctx, _info) => deleteOne(ctx, "Topic", args.id),

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
                password: await hash(args.password)
              }
            },
            "{ id, email, password }"
          )
          .then(async user =>
            Object.assign(
              { token: await sign({ userId: user.id }, APP_SECRET) },
              user
            )
          ),

  changePassword: async (_, { password }, ctx, _info) => {
    const userId = await getUserId(ctx.request);

    return ctx.db.mutation
      .updateUser({
        data: { password: await hash(password) },
        where: { id: userId }
      })
      .then(_ => true);
  }
};
