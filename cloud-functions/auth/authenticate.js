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
      console.log("Please provide a valid root token!");
      return { error: "Email Authentication not configured correctly." };
    }

    // Retrieve payload from event
    const email = event.data.email;
    const password = event.data.password;

    // Create Graphcool API (based on https://github.com/graphcool/graphql-request)
    const graphcool = fromEvent(event);
    const api = graphcool.api("simple/v1");

    const user = await getGraphcoolUser(api, email);

    if (!user) {
      return Promise.reject("Invalid Credentials");
    }

    return (await bcryptjs.compare(password, user.password))
      ? {
          data: {
            id: user.id,
            email,
            token: await graphcool.generateAuthToken(user.id, "User")
          }
        }
      : Promise.reject("Invalid Credentials");
  })().catch(err => ({
    error: JSON.stringify(err)
  }));
