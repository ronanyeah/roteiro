const { assoc, prop } = require("ramda");
const bcryptjs = require("bcryptjs");
const validator = require("validator");

const { clean, getUserId, sign, hash } = require("../utils.js");

const { APP_SECRET } = process.env;

const deleteOne = async (dataName, ctx, dataId) => {
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

const update = async (dataName, ctx, args, info) => {
  const userId = await getUserId(ctx.request);

  const isOwner = await ctx.db.exists[dataName]({
    AND: [{ id: args.id }, { user: { id: userId } }]
  });

  if (!isOwner) {
    return Error("Oops!");
  }

  return ctx.db.mutation[`update${dataName}`](
    {
      data: clean(args),
      where: { id: args.id }
    },
    info
  );
};

module.exports = {
  deletePosition: async (_, args, ctx, _info) =>
    deleteOne("Position", ctx, args.id),

  deleteSubmission: async (_, args, ctx, _info) =>
    deleteOne("Submission", ctx, args.id),

  deleteTransition: async (_, args, ctx, _info) =>
    deleteOne("Transition", ctx, args.id),

  deleteTag: async (_, args, ctx, _info) => deleteOne("Tag", ctx, args.id),

  deleteTopic: async (_, args, ctx, _info) => deleteOne("Topic", ctx, args.id),

  updatePosition: async (_, args, ctx, info) =>
    update("Position", ctx, args, info),

  updateSubmission: async (_, args, ctx, info) =>
    update("Submission", ctx, args, info),

  updateTag: async (_, args, ctx, info) => update("Tag", ctx, args, info),

  updateTopic: async (_, args, ctx, info) => update("Topic", ctx, args, info),

  updateTransition: async (_, args, ctx, info) =>
    update("Transition", ctx, args, info),

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
