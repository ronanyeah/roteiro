const {
  APP_SECRET,
  PRISMA_DEBUG,
  PRISMA_ENDPOINT,
  PRISMA_SECRET
} = process.env;

if (!APP_SECRET) throw Error("missing app secret");
if (!PRISMA_ENDPOINT) throw Error("missing prisma endpoint");
if (!PRISMA_SECRET) throw Error("missing prisma secret");

module.exports = {
  APP_SECRET,
  PRISMA_DEBUG,
  PRISMA_ENDPOINT,
  PRISMA_SECRET
};
