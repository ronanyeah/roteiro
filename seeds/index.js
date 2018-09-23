const { prisma } = require("../prisma-client");
const faker = require("faker");

const { PRISMA_ENDPOINT, PRISMA_SECRET } = process.env;

if (!PRISMA_ENDPOINT || !PRISMA_SECRET) throw Error("missing prisma env");

// HELPERS

const pickN = (n, xs) => faker.helpers.shuffle(xs).slice(0, n);

const times = (n, fn) =>
  Array(n)
    .fill(0)
    .map(fn);

const lorem = () =>
  times(5, () => faker.lorem.sentence() + " " + faker.lorem.sentence());

const concatMap = (fn, xs) => xs.map(fn).reduce((acc, x) => acc.concat(x), []);

// MUTATIONS

const signUp = () =>
  prisma.createUser({
    email: "ronan@yeah.com",
    password: "$2a$10$2rZPHxm1tqEpjaAKqRU6OOAKKHI7H/lvg.eOwjjt9/wn6P1XBG2g2"
  });

const createPosition = userId =>
  prisma.createPosition({
    name: faker.commerce.productAdjective() + " " + faker.name.lastName(),
    notes: {
      set: lorem()
    },
    user: {
      connect: { id: userId }
    }
  });

const createSubmission = (userId, positionId, tagIds) =>
  prisma.createSubmission({
    name: faker.name.jobArea(),
    notes: {
      set: lorem()
    },
    position: { connect: { id: positionId } },
    steps: { set: lorem() },
    user: {
      connect: { id: userId }
    },
    tags: {
      connect: pickN(2, tagIds).map(id => ({ id }))
    }
  });

const createTransition = (userId, start, end, tagIds) =>
  prisma.createTransition({
    name: faker.name.jobArea(),
    notes: {
      set: lorem()
    },
    startPosition: { connect: { id: start } },
    endPosition: { connect: { id: end } },
    steps: { set: lorem() },
    user: {
      connect: { id: userId }
    },
    tags: {
      connect: pickN(2, tagIds).map(id => ({ id }))
    }
  });

const createTag = userId =>
  prisma.createTag({
    name: faker.random.word(),
    user: {
      connect: { id: userId }
    }
  });

const createTopic = userId =>
  prisma.createTopic({
    name: faker.random.word(),
    notes: {
      set: lorem()
    },
    user: {
      connect: { id: userId }
    }
  });

(async () => {
  // clear existing data
  await prisma.deleteManySubmissions({
    id_not_in: []
  });

  await prisma.deleteManyTransitions({
    id_not_in: []
  });

  await prisma.deleteManyPositions({
    id_not_in: []
  });

  await prisma.deleteManyTags({
    id_not_in: []
  });

  await prisma.deleteManyTopics({
    id_not_in: []
  });

  await prisma.deleteManyUsers({
    id_not_in: []
  });

  // fill with new data
  const userId = (await signUp()).id;

  const posIds = (await Promise.all(
    times(10, () => createPosition(userId))
  )).map(({ id }) => id);

  const tagIds = (await Promise.all(times(10, () => createTag(userId)))).map(
    ({ id }) => id
  );

  await Promise.all(
    concatMap(
      id => times(3, () => createSubmission(userId, id, tagIds)),
      posIds
    )
  );

  await Promise.all(
    concatMap(
      id =>
        times(3, () =>
          createTransition(
            userId,
            id,
            faker.helpers.randomize(posIds.filter(x => x !== id)),
            tagIds
          )
        ),
      posIds
    )
  );

  await Promise.all(times(10, () => createTopic(userId)));
})()
  .then(_ => {
    console.log("OK");
    process.exit();
  })
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
