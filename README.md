# ROTEIRO

![home](https://user-images.githubusercontent.com/9598261/34342795-463a193a-e9b3-11e7-8a75-213070e24221.png)

---

Datamodel changes:

1. edit `./datamodel.graphql` to change prisma model
1. `npm run deploy:prisma` to update prisma (uses `./prisma.yml` + `PRISMA_ENDPOINT`)
1. `npx get-graphql-schema -h Authorization="Bearer XXX" http://localhost:4466 > ./api/prisma.graphql` to fetch and save the new schema from the prisma docker server
1. `npm run gen:elm` to generate the new elm api code from the yoga server and save it to `./client/Api`

---

Api server changes:
`npm run deploy:now` (uses `APP_SECRET` + `PRISMA_ENDPOINT` + `NODE_ENV`)
