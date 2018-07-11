const { pipe, reject, pluck, assoc, prop, contains, __ } = require("ramda");
const bcryptjs = require("bcryptjs");
const validator = require("validator");

const { clean, getUserId, sign, hash } = require("../utils.js");

const { APP_SECRET } = process.env;

const deleteOne = async (userId, existsFn, deleteFn, dataId) => {
  const isOwner = await existsFn({
    AND: [{ id: dataId }, { user: { id: userId } }]
  });

  if (!isOwner) throw Error("Resource not available!");

  return deleteFn({
    where: { id: dataId }
  }).then(prop("id"));
};

const update = async (userId, queryFn, existsFn, updateFn, args, info) => {
  const argsFn = await (args.tags
    ? (async () => {
        const [data] = await queryFn(
          {
            where: {
              AND: [{ id: args.id }, { user: { id: userId } }]
            }
          },
          "{ tags { id } }"
        );
        if (!data) throw Error("Resource not available!");

        const currentTags = pluck("id", data.tags);

        const tagData = {
          connect: reject(contains(__, currentTags), args.tags).map(id => ({
            id
          })),
          disconnect: reject(contains(__, args.tags), currentTags).map(id => ({
            id
          }))
        };

        return pipe(
          clean,
          assoc("tags", tagData)
        );
      })()
    : (async () => {
        const isOwner = await existsFn({
          AND: [{ id: args.id }, { user: { id: userId } }]
        });

        if (!isOwner) throw Error("Resource not available!");

        return clean;
      })());

  return updateFn(
    {
      data: argsFn(args),
      where: { id: args.id }
    },
    info
  );
};

const create = async (userId, createFn, args, info) => {
  const argsFn = args.tags
    ? pipe(
        clean,
        assoc("tags", {
          connect: args.tags.map(id => ({
            id
          }))
        })
      )
    : clean;

  return createFn(
    {
      data: assoc("user", { connect: { id: userId } }, argsFn(args))
    },
    info
  );
};

module.exports = {
  deletePosition: async (_, args, ctx, _info) =>
    deleteOne(
      await getUserId(ctx.request),
      ctx.db.exists.Position,
      ctx.db.mutation.deletePosition,
      args.id
    ),

  deleteSubmission: async (_, args, ctx, _info) =>
    deleteOne(
      await getUserId(ctx.request),
      ctx.db.exists.Submission,
      ctx.db.mutation.deleteSubmission,
      args.id
    ),

  deleteTag: async (_, args, ctx, _info) =>
    deleteOne(
      await getUserId(ctx.request),
      ctx.db.exists.Tag,
      ctx.db.mutation.deleteTag,
      args.id
    ),

  deleteTopic: async (_, args, ctx, _info) =>
    deleteOne(
      await getUserId(ctx.request),
      ctx.db.exists.Topic,
      ctx.db.mutation.deleteTopic,
      args.id
    ),
  deleteTransition: async (_, args, ctx, _info) =>
    deleteOne(
      await getUserId(ctx.request),
      ctx.db.exists.Transition,
      ctx.db.mutation.deleteTransition,
      args.id
    ),

  updatePosition: async (_, args, ctx, info) =>
    update(
      await getUserId(ctx.request),
      ctx.db.query.positions,
      ctx.db.exists.Position,
      ctx.db.mutation.updatePosition,
      args,
      info
    ),

  updateSubmission: async (_, args, ctx, info) =>
    update(
      await getUserId(ctx.request),
      ctx.db.query.submissions,
      ctx.db.exists.Submission,
      ctx.db.mutation.updateSubmission,
      args,
      info
    ),

  updateTag: async (_, args, ctx, info) =>
    update(
      await getUserId(ctx.request),
      ctx.db.query.tags,
      ctx.db.exists.Tag,
      ctx.db.mutation.updateTag,
      args,
      info
    ),

  updateTopic: async (_, args, ctx, info) =>
    update(
      await getUserId(ctx.request),
      ctx.db.query.topics,
      ctx.db.exists.Topic,
      ctx.db.mutation.updateTopic,
      args,
      info
    ),

  updateTransition: async (_, args, ctx, info) =>
    update(
      await getUserId(ctx.request),
      ctx.db.query.transitions,
      ctx.db.exists.Transition,
      ctx.db.mutation.updateTransition,
      args,
      info
    ),

  createPosition: async (_, args, ctx, info) =>
    create(
      await getUserId(ctx.request),
      ctx.db.mutation.createPosition,
      args,
      info
    ),

  createSubmission: async (_, args, ctx, info) =>
    create(
      await getUserId(ctx.request),
      ctx.db.mutation.createSubmission,
      args,
      info
    ),

  createTransition: async (_, args, ctx, info) =>
    create(
      await getUserId(ctx.request),
      ctx.db.mutation.createTransition,
      args,
      info
    ),

  createTag: async (_, args, ctx, info) =>
    create(await getUserId(ctx.request), ctx.db.mutation.createTag, args, info),

  createTopic: async (_, args, ctx, info) =>
    create(
      await getUserId(ctx.request),
      ctx.db.mutation.createTopic,
      args,
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
