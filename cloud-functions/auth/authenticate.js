const { fromEvent } = require("graphcool-lib");
const bcryptjs = require("bcryptjs");

const userQuery = `
query UserQuery($email: String!) {
  User(email: $email) {
    id
    password
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

module.exports = event =>
  (async () => {
    if (!event.context.graphcool.pat) {
      return Promise.reject(Error("Root token not provided!"));
    }

    const email = event.data.email;
    const password = event.data.password;

    const graphcool = fromEvent(event);
    const api = graphcool.api("simple/v1");

    const user = await getGraphcoolUser(api, email);

    if (!user) {
      return Promise.reject(Error("Email is not in use!"));
    }

    return (await bcryptjs.compare(password, user.password))
      ? {
          data: {
            id: user.id,
            email,
            token: await graphcool.generateAuthToken(user.id, "User")
          }
        }
      : Promise.reject(Error("Incorrect password!"));
  })().catch(err => ({
    error: err.message
  }));
