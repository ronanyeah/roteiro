const { GraphQLClient } = require("graphql-request");
const faker = require("faker");

const { PRISMA_ENDPOINT, TOKEN } = process.env;

if (!PRISMA_ENDPOINT) throw Error("missing api endpoint");
if (!TOKEN) throw Error("missing api token");

const client = new GraphQLClient(PRISMA_ENDPOINT, {
  headers: {
    Authorization: "Bearer " + TOKEN
  }
});

// HELPERS

const makePair = (id, xs) => [
  id,
  faker.helpers.randomize(xs.filter(x => x !== id))
];

const formatArray = xs => xs.map(JSON.stringify).join(", ");

const formatIds = xs => xs.map(x => `{ id: ${JSON.stringify(x)} }`).join(", ");

const pickN = (n, xs) => faker.helpers.shuffle(xs).slice(0, n);

const times = (n, fn) =>
  Array(n)
    .fill(0)
    .map(fn);

const lorem = () =>
  formatArray(
    times(5, () => faker.lorem.sentence() + " " + faker.lorem.sentence())
  );

const concatMap = (fn, xs) => xs.map(fn).reduce((acc, x) => acc.concat(x), []);

// QUERIES

const getUsers = () =>
  client.request(`{
  users {
    id
  }
}`);

const getPositions = () =>
  client.request(`{
  positions {
    id
  }
}`);

const getSubmissions = () =>
  client.request(`{
  submissions {
    id
  }
}`);

const getTags = () =>
  client.request(`{
  tags {
    id
  }
}`);

const getTopics = () =>
  client.request(`{
  topics {
    id
  }
}`);

const getTransitions = () =>
  client.request(`{
  transitions {
    id
  }
}`);

// MUTATIONS

const signUp = () =>
  client.request(`
  mutation {
    createUser(data: { email: "ronan@yeah.com", password: "pw" }) {
      id
    }
  }
`);

const createPosition = userId =>
  client.request(`
  mutation {
    createPosition(data: { name: "${faker.commerce.productAdjective() +
      " " +
      faker.name.lastName()}", notes: { set: [${lorem()}] }, user: { connect: { id: "${userId}" } } }) {
      id
      name
    }
  }
`);

const createSubmission = (userId, positionId, tagIds) =>
  client.request(`
  mutation {
    createSubmission(data: { name: "${faker.name.jobArea()}", position: { connect: { id: "${positionId}" } }, notes: { set: [${lorem()}] }, steps: { set: [${lorem()}] }, tags: { connect: [${formatIds(
    pickN(2, tagIds)
  )}] }, user: { connect: { id: "${userId}" } } }) {
      id
      name
    }
  }
`);

const createTransition = (userId, start, end, tagIds) =>
  client.request(`
  mutation {
    createTransition(data: { name: "${faker.name.jobArea()}", startPosition: { connect: { id: "${start}" } }, endPosition: { connect: { id: "${end}" } }, notes: { set: [${lorem()}] }, steps: { set: [${lorem()}] }, tags: { connect: [${formatIds(
    pickN(2, tagIds)
  )}] }, user: { connect: { id: "${userId}" } } }) {
      id
      name
    }
  }
`);

const createTag = userId =>
  client.request(`
  mutation {
    createTag(data: { name: "${faker.lorem.word()}", user: { connect: { id: "${userId}" } } }) {
      id
      name
    }
  }
`);

const createTopic = userId =>
  client.request(`
  mutation {
    createTopic(data: { name: "${faker.random.word()}", notes: { set: [${lorem()}] }, user: { connect: { id: "${userId}" } } }) {
      id
      name
    }
  }
`);

const deleteSubmission = id =>
  client.request(`
  mutation {
    deleteSubmission(where: { id: "${id}" }) {
      id
    }
  }
`);

const deleteTag = id =>
  client.request(`
  mutation {
    deleteTag(where: { id: "${id}" }) {
      id
    }
  }
`);

const deleteTopic = id =>
  client.request(`
  mutation {
    deleteTopic(where: { id: "${id}" }) {
      id
    }
  }
`);

const deleteTransition = id =>
  client.request(`
  mutation {
    deleteTransition(where: { id: "${id}" }) {
      id
    }
  }
`);

const deletePosition = id =>
  client.request(`
  mutation {
    deletePosition(where: { id: "${id}" }) {
      id
    }
  }
`);

const deleteUser = id =>
  client.request(`
  mutation {
    deleteUser(where: { id: "${id}" }) {
      id
    }
  }
`);

const fill = async () => {
  const userId = (await signUp()).createUser.id;

  const posIds = (await Promise.all(
    times(10, () => createPosition(userId))
  )).map(x => x.createPosition.id);

  const tagIds = (await Promise.all(times(10, () => createTag(userId)))).map(
    x => x.createTag.id
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
          createTransition(userId, ...makePair(id, posIds), tagIds)
        ),
      posIds
    )
  );

  await Promise.all(times(10, () => createTopic(userId)));

  return "OK";
};

const clear = async () => {
  const subIds = (await getSubmissions()).submissions.map(x => x.id);
  await Promise.all(subIds.map(deleteSubmission));

  const trIds = (await getTransitions()).transitions.map(x => x.id);
  await Promise.all(trIds.map(deleteTransition));

  const posIds = (await getPositions()).positions.map(x => x.id);
  await Promise.all(posIds.map(deletePosition));

  const tagIds = (await getTags()).tags.map(x => x.id);
  await Promise.all(tagIds.map(deleteTag));

  const topicIds = (await getTopics()).topics.map(x => x.id);
  await Promise.all(topicIds.map(deleteTopic));

  const userIds = (await getUsers()).users.map(x => x.id);
  await Promise.all(userIds.map(deleteUser));

  return "OK";
};

(async () => {
  await clear();
  return fill();
})()
  .then(console.log)
  .catch(console.error);
