const { fromEvent } = require("graphcool-lib");
const bcryptjs = require("bcryptjs");
const validator = require("validator");

const SALT_ROUNDS = 10;

const userQuery = `
query UserQuery($email: String!) {
  User(email: $email) {
    id
    password
  }
}`;

const createUserMutation = `
mutation CreateUserMutation($email: String!, $passwordHash: String!) {
  createUser(
    email: $email,
    password: $passwordHash
  ) {
    id
  }
}`;

const getGraphcoolUser = (api, email) =>
  api
    .request(userQuery, { email })
    .then(
      userQueryResult =>
        userQueryResult.error
          ? Promise.reject(userQueryResult.error)
          : userQueryResult.User
    );

const createGraphcoolUser = (api, email, passwordHash) =>
  api
    .request(createUserMutation, { email, passwordHash })
    .then(userMutationResult => userMutationResult.createUser.id);

module.exports = event =>
  (async () => {
    if (!event.context.graphcool.pat) {
      return Promise.reject(Error("Root token not provided"));
    }

    const email = event.data.email;
    const password = event.data.password;

    const graphcool = fromEvent(event);
    const api = graphcool.api("simple/v1");

    const salt = bcryptjs.genSaltSync(SALT_ROUNDS);

    if (!validator.isEmail(email)) {
      return Promise.reject(Error("Not a valid email"));
    }

    if (await getGraphcoolUser(api, email)) {
      return Promise.reject(Error("Email already in use"));
    }

    const hash = await bcryptjs.hash(password, salt);
    const id = await createGraphcoolUser(api, email, hash);
    const token = await graphcool.generateAuthToken(id, "User");

    return { data: { id, email, token } };
  })().catch(err => ({
    error: err.message
  }));
