# ROTEIRO

![home](https://user-images.githubusercontent.com/9598261/34342795-463a193a-e9b3-11e7-8a75-213070e24221.png)

1. edit `./prisma/datamodel.graphql` to change prisma model
1. `npm run deploy` to update prisma (uses `prisma.yml` + `PRISMA_ENDPOINT`)
1. `npm run gen-prisma` to fetch the new schema from the prisma docker server and save it to `./prisma/generated` (used by yoga server)
1. `npm run gen-elm` to generate the new elm api code from the yoga server and save it to `./src/Api`
