const jwt = require("jsonwebtoken");
const bcryptjs = require("bcryptjs");
const { dissoc, evolve, pipe } = require("ramda");
const { promisify } = require("util");

const { APP_SECRET } = process.env;

const verify = promisify(jwt.verify);

module.exports = {
  getUserId: async req => {
    const authHeader = req.get("Authorization");
    if (!authHeader) throw Error("Unauthorised!");

    const token = authHeader.replace("Bearer ", "");
    const { userId } = await verify(token, APP_SECRET);

    return userId;
  },

  clean: pipe(
    dissoc("id"),
    evolve({
      steps: xs => ({ set: xs }),
      notes: xs => ({ set: xs }),
      startPosition: id => ({ connect: { id } }),
      endPosition: id => ({ connect: { id } }),
      position: id => ({ connect: { id } })
    })
  ),

  sign: promisify(jwt.sign),

  hash: str => bcryptjs.hash(str, 10)
};
