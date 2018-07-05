const { getUserId } = require("../utils.js");

module.exports = {
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
};
