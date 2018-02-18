const { GraphQLClient } = require("graphql-request");
const faker = require("faker");

const { GRAPHQL_ENDPOINT, TOKEN } = process.env;

if (!GRAPHQL_ENDPOINT || !TOKEN) throw Error("missing credentials");

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

const times = (n, fn) =>
  Array(n)
    .fill(0)
    .map(fn);

const lorem = () =>
  times(5, () => faker.lorem.sentence() + " " + faker.lorem.sentence())
    .map(JSON.stringify)
    .join(", ");

const concatMap = (fn, xs) => xs.map(fn).reduce((acc, x) => acc.concat(x), []);

// QUERIES

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

const getTransitions = () =>
  client.request(`{
  allTransitions {
    id
  }
}`);

// MUTATIONS

const createPosition = () =>
  client.request(`
  mutation {
    createPosition(name: "${faker.commerce.productAdjective() +
      " " +
      faker.name.lastName()}", notes: [${lorem()}]) {
      id
      name
    }
  }
`);

const createSubmission = positionId =>
  client.request(`
  mutation {
    createSubmission(name: "${faker.name.jobArea()}", positionId: "${positionId}", notes: [${lorem()}], steps: [${lorem()}]) {
      id
      name
    }
  }
`);

const createTransition = (start, end) =>
  client.request(`
  mutation {
    createTransition(name: "${faker.name.jobArea()}", startPositionId: "${start}", endPositionId: "${end}", notes: [${lorem()}], steps: [${lorem()}]) {
      id
      name
    }
  }
`);

const createTopic = () =>
  client.request(`
  mutation {
    createTopic(name: "${faker.random.word()}", notes: [${lorem()}]) {
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

const fill = async () => {
  const posIds = (await Promise.all(times(10, () => createPosition()))).map(
    x => x.createPosition.id
  );

  await Promise.all(
    concatMap(id => times(3, () => createSubmission(id)), posIds)
  );

  await Promise.all(
    concatMap(
      id => times(3, () => createTransition(...makePair(id, posIds))),
      posIds
    )
  );

  return "OK";
};

const clear = async () => {
  const subIds = (await getSubmissions()).allSubmissions.map(x => x.id);
  await Promise.all(subIds.map(deleteSubmission));

  const trIds = (await getTransitions()).allTransitions.map(x => x.id);
  await Promise.all(trIds.map(deleteTransition));

  const posIds = (await getPositions()).allPositions.map(x => x.id);
  await Promise.all(posIds.map(deletePosition));

  return "OK";
};

(async () => {
  await clear();
  return fill();
})()
  .then(console.log)
  .catch(console.error);
