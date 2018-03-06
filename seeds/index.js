const { GraphQLClient } = require("graphql-request");
const faker = require("faker");

const { GRAPHQL_ENDPOINT, TOKEN } = process.env;

if (!GRAPHQL_ENDPOINT) throw Error("missing api endpoint");
if (!TOKEN) throw Error("missing api token");

const client = new GraphQLClient(GRAPHQL_ENDPOINT, {
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
  allUsers {
    id
  }
}`);

const getPositions = () =>
  client.request(`{
  allPositions {
    id
  }
}`);

const getSubmissions = () =>
  client.request(`{
  allSubmissions {
    id
  }
}`);

const getTags = () =>
  client.request(`{
  allTags {
    id
  }
}`);

const getTopics = () =>
  client.request(`{
  allTopics {
    id
  }
}`);

const getTransitions = () =>
  client.request(`{
  allTransitions {
    id
  }
}`);

// MUTATIONS

const signUp = () =>
  client.request(`
  mutation {
    signupUser(email: "ronan@yeah.com", password: "pw") {
      id
    }
  }
`);

const createPosition = userId =>
  client.request(`
  mutation {
    createPosition(name: "${faker.commerce.productAdjective() +
      " " +
      faker.name.lastName()}", notes: [${lorem()}], userId: "${userId}") {
      id
      name
    }
  }
`);

const createSubmission = (userId, positionId, tagIds) =>
  client.request(`
  mutation {
    createSubmission(name: "${faker.name.jobArea()}", positionId: "${positionId}", notes: [${lorem()}], steps: [${lorem()}], tagsIds: [${formatArray(
    pickN(2, tagIds)
  )}], userId: "${userId}") {
      id
      name
    }
  }
`);

const createTransition = (userId, start, end, tagIds) =>
  client.request(`
  mutation {
    createTransition(name: "${faker.name.jobArea()}", startPositionId: "${start}", endPositionId: "${end}", notes: [${lorem()}], steps: [${lorem()}], tagsIds: [${formatArray(
    pickN(2, tagIds)
  )}], userId: "${userId}") {
      id
      name
    }
  }
`);

const createTag = userId =>
  client.request(`
  mutation {
    createTag(name: "${faker.lorem.word()}", userId: "${userId}") {
      id
      name
    }
  }
`);

const createTopic = userId =>
  client.request(`
  mutation {
    createTopic(name: "${faker.random.word()}", notes: [${lorem()}], userId: "${userId}") {
      id
      name
    }
  }
`);

const deleteSubmission = id =>
  client.request(`
  mutation {
    deleteSubmission(id: "${id}") {
      id
    }
  }
`);

const deleteTag = id =>
  client.request(`
  mutation {
    deleteTag(id: "${id}") {
      id
    }
  }
`);

const deleteTopic = id =>
  client.request(`
  mutation {
    deleteTopic(id: "${id}") {
      id
    }
  }
`);

const deleteTransition = id =>
  client.request(`
  mutation {
    deleteTransition(id: "${id}") {
      id
    }
  }
`);

const deletePosition = id =>
  client.request(`
  mutation {
    deletePosition(id: "${id}") {
      id
    }
  }
`);

const deleteUser = id =>
  client.request(`
  mutation {
    deleteUser(id: "${id}") {
      id
    }
  }
`);

const fill = async () => {
  const userId = (await signUp()).signupUser.id;

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
  const subIds = (await getSubmissions()).allSubmissions.map(x => x.id);
  await Promise.all(subIds.map(deleteSubmission));

  const trIds = (await getTransitions()).allTransitions.map(x => x.id);
  await Promise.all(trIds.map(deleteTransition));

  const posIds = (await getPositions()).allPositions.map(x => x.id);
  await Promise.all(posIds.map(deletePosition));

  const tagIds = (await getTags()).allTags.map(x => x.id);
  await Promise.all(tagIds.map(deleteTag));

  const topicIds = (await getTopics()).allTopics.map(x => x.id);
  await Promise.all(topicIds.map(deleteTopic));

  const userIds = (await getUsers()).allUsers.map(x => x.id);
  await Promise.all(userIds.map(deleteUser));

  return "OK";
};

(async () => {
  await clear();
  return fill();
})()
  .then(console.log)
  .catch(console.error);
