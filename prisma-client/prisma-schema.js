module.exports = {
        typeDefs: /* GraphQL */ `type AggregatePosition {
  count: Int!
}

type AggregateSubmission {
  count: Int!
}

type AggregateTag {
  count: Int!
}

type AggregateTopic {
  count: Int!
}

type AggregateTransition {
  count: Int!
}

type AggregateUser {
  count: Int!
}

type BatchPayload {
  count: Long!
}

scalar DateTime

scalar Long

type Mutation {
  createPosition(data: PositionCreateInput!): Position!
  updatePosition(data: PositionUpdateInput!, where: PositionWhereUniqueInput!): Position
  updateManyPositions(data: PositionUpdateInput!, where: PositionWhereInput): BatchPayload!
  upsertPosition(where: PositionWhereUniqueInput!, create: PositionCreateInput!, update: PositionUpdateInput!): Position!
  deletePosition(where: PositionWhereUniqueInput!): Position
  deleteManyPositions(where: PositionWhereInput): BatchPayload!
  createSubmission(data: SubmissionCreateInput!): Submission!
  updateSubmission(data: SubmissionUpdateInput!, where: SubmissionWhereUniqueInput!): Submission
  updateManySubmissions(data: SubmissionUpdateInput!, where: SubmissionWhereInput): BatchPayload!
  upsertSubmission(where: SubmissionWhereUniqueInput!, create: SubmissionCreateInput!, update: SubmissionUpdateInput!): Submission!
  deleteSubmission(where: SubmissionWhereUniqueInput!): Submission
  deleteManySubmissions(where: SubmissionWhereInput): BatchPayload!
  createTag(data: TagCreateInput!): Tag!
  updateTag(data: TagUpdateInput!, where: TagWhereUniqueInput!): Tag
  updateManyTags(data: TagUpdateInput!, where: TagWhereInput): BatchPayload!
  upsertTag(where: TagWhereUniqueInput!, create: TagCreateInput!, update: TagUpdateInput!): Tag!
  deleteTag(where: TagWhereUniqueInput!): Tag
  deleteManyTags(where: TagWhereInput): BatchPayload!
  createTopic(data: TopicCreateInput!): Topic!
  updateTopic(data: TopicUpdateInput!, where: TopicWhereUniqueInput!): Topic
  updateManyTopics(data: TopicUpdateInput!, where: TopicWhereInput): BatchPayload!
  upsertTopic(where: TopicWhereUniqueInput!, create: TopicCreateInput!, update: TopicUpdateInput!): Topic!
  deleteTopic(where: TopicWhereUniqueInput!): Topic
  deleteManyTopics(where: TopicWhereInput): BatchPayload!
  createTransition(data: TransitionCreateInput!): Transition!
  updateTransition(data: TransitionUpdateInput!, where: TransitionWhereUniqueInput!): Transition
  updateManyTransitions(data: TransitionUpdateInput!, where: TransitionWhereInput): BatchPayload!
  upsertTransition(where: TransitionWhereUniqueInput!, create: TransitionCreateInput!, update: TransitionUpdateInput!): Transition!
  deleteTransition(where: TransitionWhereUniqueInput!): Transition
  deleteManyTransitions(where: TransitionWhereInput): BatchPayload!
  createUser(data: UserCreateInput!): User!
  updateUser(data: UserUpdateInput!, where: UserWhereUniqueInput!): User
  updateManyUsers(data: UserUpdateInput!, where: UserWhereInput): BatchPayload!
  upsertUser(where: UserWhereUniqueInput!, create: UserCreateInput!, update: UserUpdateInput!): User!
  deleteUser(where: UserWhereUniqueInput!): User
  deleteManyUsers(where: UserWhereInput): BatchPayload!
}

enum MutationType {
  CREATED
  UPDATED
  DELETED
}

interface Node {
  id: ID!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type Position {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  notes: [String!]!
  submissions(where: SubmissionWhereInput, orderBy: SubmissionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Submission!]
  transitionsFrom(where: TransitionWhereInput, orderBy: TransitionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Transition!]
  transitionsTo(where: TransitionWhereInput, orderBy: TransitionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Transition!]
  user: User!
}

type PositionConnection {
  pageInfo: PageInfo!
  edges: [PositionEdge]!
  aggregate: AggregatePosition!
}

input PositionCreateInput {
  name: String!
  notes: PositionCreatenotesInput
  submissions: SubmissionCreateManyWithoutPositionInput
  transitionsFrom: TransitionCreateManyWithoutStartPositionInput
  transitionsTo: TransitionCreateManyWithoutEndPositionInput
  user: UserCreateOneWithoutPositionsInput!
}

input PositionCreateManyWithoutUserInput {
  create: [PositionCreateWithoutUserInput!]
  connect: [PositionWhereUniqueInput!]
}

input PositionCreatenotesInput {
  set: [String!]
}

input PositionCreateOneWithoutSubmissionsInput {
  create: PositionCreateWithoutSubmissionsInput
  connect: PositionWhereUniqueInput
}

input PositionCreateOneWithoutTransitionsFromInput {
  create: PositionCreateWithoutTransitionsFromInput
  connect: PositionWhereUniqueInput
}

input PositionCreateOneWithoutTransitionsToInput {
  create: PositionCreateWithoutTransitionsToInput
  connect: PositionWhereUniqueInput
}

input PositionCreateWithoutSubmissionsInput {
  name: String!
  notes: PositionCreatenotesInput
  transitionsFrom: TransitionCreateManyWithoutStartPositionInput
  transitionsTo: TransitionCreateManyWithoutEndPositionInput
  user: UserCreateOneWithoutPositionsInput!
}

input PositionCreateWithoutTransitionsFromInput {
  name: String!
  notes: PositionCreatenotesInput
  submissions: SubmissionCreateManyWithoutPositionInput
  transitionsTo: TransitionCreateManyWithoutEndPositionInput
  user: UserCreateOneWithoutPositionsInput!
}

input PositionCreateWithoutTransitionsToInput {
  name: String!
  notes: PositionCreatenotesInput
  submissions: SubmissionCreateManyWithoutPositionInput
  transitionsFrom: TransitionCreateManyWithoutStartPositionInput
  user: UserCreateOneWithoutPositionsInput!
}

input PositionCreateWithoutUserInput {
  name: String!
  notes: PositionCreatenotesInput
  submissions: SubmissionCreateManyWithoutPositionInput
  transitionsFrom: TransitionCreateManyWithoutStartPositionInput
  transitionsTo: TransitionCreateManyWithoutEndPositionInput
}

type PositionEdge {
  node: Position!
  cursor: String!
}

enum PositionOrderByInput {
  id_ASC
  id_DESC
  createdAt_ASC
  createdAt_DESC
  updatedAt_ASC
  updatedAt_DESC
  name_ASC
  name_DESC
}

type PositionPreviousValues {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  notes: [String!]!
}

type PositionSubscriptionPayload {
  mutation: MutationType!
  node: Position
  updatedFields: [String!]
  previousValues: PositionPreviousValues
}

input PositionSubscriptionWhereInput {
  mutation_in: [MutationType!]
  updatedFields_contains: String
  updatedFields_contains_every: [String!]
  updatedFields_contains_some: [String!]
  node: PositionWhereInput
  AND: [PositionSubscriptionWhereInput!]
  OR: [PositionSubscriptionWhereInput!]
  NOT: [PositionSubscriptionWhereInput!]
}

input PositionUpdateInput {
  name: String
  notes: PositionUpdatenotesInput
  submissions: SubmissionUpdateManyWithoutPositionInput
  transitionsFrom: TransitionUpdateManyWithoutStartPositionInput
  transitionsTo: TransitionUpdateManyWithoutEndPositionInput
  user: UserUpdateOneWithoutPositionsInput
}

input PositionUpdateManyWithoutUserInput {
  create: [PositionCreateWithoutUserInput!]
  delete: [PositionWhereUniqueInput!]
  connect: [PositionWhereUniqueInput!]
  disconnect: [PositionWhereUniqueInput!]
  update: [PositionUpdateWithWhereUniqueWithoutUserInput!]
  upsert: [PositionUpsertWithWhereUniqueWithoutUserInput!]
}

input PositionUpdatenotesInput {
  set: [String!]
}

input PositionUpdateOneWithoutSubmissionsInput {
  create: PositionCreateWithoutSubmissionsInput
  update: PositionUpdateWithoutSubmissionsDataInput
  upsert: PositionUpsertWithoutSubmissionsInput
  delete: Boolean
  connect: PositionWhereUniqueInput
}

input PositionUpdateOneWithoutTransitionsFromInput {
  create: PositionCreateWithoutTransitionsFromInput
  update: PositionUpdateWithoutTransitionsFromDataInput
  upsert: PositionUpsertWithoutTransitionsFromInput
  delete: Boolean
  connect: PositionWhereUniqueInput
}

input PositionUpdateOneWithoutTransitionsToInput {
  create: PositionCreateWithoutTransitionsToInput
  update: PositionUpdateWithoutTransitionsToDataInput
  upsert: PositionUpsertWithoutTransitionsToInput
  delete: Boolean
  connect: PositionWhereUniqueInput
}

input PositionUpdateWithoutSubmissionsDataInput {
  name: String
  notes: PositionUpdatenotesInput
  transitionsFrom: TransitionUpdateManyWithoutStartPositionInput
  transitionsTo: TransitionUpdateManyWithoutEndPositionInput
  user: UserUpdateOneWithoutPositionsInput
}

input PositionUpdateWithoutTransitionsFromDataInput {
  name: String
  notes: PositionUpdatenotesInput
  submissions: SubmissionUpdateManyWithoutPositionInput
  transitionsTo: TransitionUpdateManyWithoutEndPositionInput
  user: UserUpdateOneWithoutPositionsInput
}

input PositionUpdateWithoutTransitionsToDataInput {
  name: String
  notes: PositionUpdatenotesInput
  submissions: SubmissionUpdateManyWithoutPositionInput
  transitionsFrom: TransitionUpdateManyWithoutStartPositionInput
  user: UserUpdateOneWithoutPositionsInput
}

input PositionUpdateWithoutUserDataInput {
  name: String
  notes: PositionUpdatenotesInput
  submissions: SubmissionUpdateManyWithoutPositionInput
  transitionsFrom: TransitionUpdateManyWithoutStartPositionInput
  transitionsTo: TransitionUpdateManyWithoutEndPositionInput
}

input PositionUpdateWithWhereUniqueWithoutUserInput {
  where: PositionWhereUniqueInput!
  data: PositionUpdateWithoutUserDataInput!
}

input PositionUpsertWithoutSubmissionsInput {
  update: PositionUpdateWithoutSubmissionsDataInput!
  create: PositionCreateWithoutSubmissionsInput!
}

input PositionUpsertWithoutTransitionsFromInput {
  update: PositionUpdateWithoutTransitionsFromDataInput!
  create: PositionCreateWithoutTransitionsFromInput!
}

input PositionUpsertWithoutTransitionsToInput {
  update: PositionUpdateWithoutTransitionsToDataInput!
  create: PositionCreateWithoutTransitionsToInput!
}

input PositionUpsertWithWhereUniqueWithoutUserInput {
  where: PositionWhereUniqueInput!
  update: PositionUpdateWithoutUserDataInput!
  create: PositionCreateWithoutUserInput!
}

input PositionWhereInput {
  id: ID
  id_not: ID
  id_in: [ID!]
  id_not_in: [ID!]
  id_lt: ID
  id_lte: ID
  id_gt: ID
  id_gte: ID
  id_contains: ID
  id_not_contains: ID
  id_starts_with: ID
  id_not_starts_with: ID
  id_ends_with: ID
  id_not_ends_with: ID
  createdAt: DateTime
  createdAt_not: DateTime
  createdAt_in: [DateTime!]
  createdAt_not_in: [DateTime!]
  createdAt_lt: DateTime
  createdAt_lte: DateTime
  createdAt_gt: DateTime
  createdAt_gte: DateTime
  updatedAt: DateTime
  updatedAt_not: DateTime
  updatedAt_in: [DateTime!]
  updatedAt_not_in: [DateTime!]
  updatedAt_lt: DateTime
  updatedAt_lte: DateTime
  updatedAt_gt: DateTime
  updatedAt_gte: DateTime
  name: String
  name_not: String
  name_in: [String!]
  name_not_in: [String!]
  name_lt: String
  name_lte: String
  name_gt: String
  name_gte: String
  name_contains: String
  name_not_contains: String
  name_starts_with: String
  name_not_starts_with: String
  name_ends_with: String
  name_not_ends_with: String
  submissions_every: SubmissionWhereInput
  submissions_some: SubmissionWhereInput
  submissions_none: SubmissionWhereInput
  transitionsFrom_every: TransitionWhereInput
  transitionsFrom_some: TransitionWhereInput
  transitionsFrom_none: TransitionWhereInput
  transitionsTo_every: TransitionWhereInput
  transitionsTo_some: TransitionWhereInput
  transitionsTo_none: TransitionWhereInput
  user: UserWhereInput
  AND: [PositionWhereInput!]
  OR: [PositionWhereInput!]
  NOT: [PositionWhereInput!]
}

input PositionWhereUniqueInput {
  id: ID
}

type Query {
  position(where: PositionWhereUniqueInput!): Position
  positions(where: PositionWhereInput, orderBy: PositionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Position]!
  positionsConnection(where: PositionWhereInput, orderBy: PositionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): PositionConnection!
  submission(where: SubmissionWhereUniqueInput!): Submission
  submissions(where: SubmissionWhereInput, orderBy: SubmissionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Submission]!
  submissionsConnection(where: SubmissionWhereInput, orderBy: SubmissionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): SubmissionConnection!
  tag(where: TagWhereUniqueInput!): Tag
  tags(where: TagWhereInput, orderBy: TagOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Tag]!
  tagsConnection(where: TagWhereInput, orderBy: TagOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): TagConnection!
  topic(where: TopicWhereUniqueInput!): Topic
  topics(where: TopicWhereInput, orderBy: TopicOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Topic]!
  topicsConnection(where: TopicWhereInput, orderBy: TopicOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): TopicConnection!
  transition(where: TransitionWhereUniqueInput!): Transition
  transitions(where: TransitionWhereInput, orderBy: TransitionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Transition]!
  transitionsConnection(where: TransitionWhereInput, orderBy: TransitionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): TransitionConnection!
  user(where: UserWhereUniqueInput!): User
  users(where: UserWhereInput, orderBy: UserOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [User]!
  usersConnection(where: UserWhereInput, orderBy: UserOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): UserConnection!
  node(id: ID!): Node
}

type Submission {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  steps: [String!]!
  notes: [String!]!
  position: Position!
  tags(where: TagWhereInput, orderBy: TagOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Tag!]
  user: User!
}

type SubmissionConnection {
  pageInfo: PageInfo!
  edges: [SubmissionEdge]!
  aggregate: AggregateSubmission!
}

input SubmissionCreateInput {
  name: String!
  steps: SubmissionCreatestepsInput
  notes: SubmissionCreatenotesInput
  position: PositionCreateOneWithoutSubmissionsInput!
  tags: TagCreateManyWithoutSubmissionsInput
  user: UserCreateOneWithoutSubmissionsInput!
}

input SubmissionCreateManyWithoutPositionInput {
  create: [SubmissionCreateWithoutPositionInput!]
  connect: [SubmissionWhereUniqueInput!]
}

input SubmissionCreateManyWithoutTagsInput {
  create: [SubmissionCreateWithoutTagsInput!]
  connect: [SubmissionWhereUniqueInput!]
}

input SubmissionCreateManyWithoutUserInput {
  create: [SubmissionCreateWithoutUserInput!]
  connect: [SubmissionWhereUniqueInput!]
}

input SubmissionCreatenotesInput {
  set: [String!]
}

input SubmissionCreatestepsInput {
  set: [String!]
}

input SubmissionCreateWithoutPositionInput {
  name: String!
  steps: SubmissionCreatestepsInput
  notes: SubmissionCreatenotesInput
  tags: TagCreateManyWithoutSubmissionsInput
  user: UserCreateOneWithoutSubmissionsInput!
}

input SubmissionCreateWithoutTagsInput {
  name: String!
  steps: SubmissionCreatestepsInput
  notes: SubmissionCreatenotesInput
  position: PositionCreateOneWithoutSubmissionsInput!
  user: UserCreateOneWithoutSubmissionsInput!
}

input SubmissionCreateWithoutUserInput {
  name: String!
  steps: SubmissionCreatestepsInput
  notes: SubmissionCreatenotesInput
  position: PositionCreateOneWithoutSubmissionsInput!
  tags: TagCreateManyWithoutSubmissionsInput
}

type SubmissionEdge {
  node: Submission!
  cursor: String!
}

enum SubmissionOrderByInput {
  id_ASC
  id_DESC
  createdAt_ASC
  createdAt_DESC
  updatedAt_ASC
  updatedAt_DESC
  name_ASC
  name_DESC
}

type SubmissionPreviousValues {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  steps: [String!]!
  notes: [String!]!
}

type SubmissionSubscriptionPayload {
  mutation: MutationType!
  node: Submission
  updatedFields: [String!]
  previousValues: SubmissionPreviousValues
}

input SubmissionSubscriptionWhereInput {
  mutation_in: [MutationType!]
  updatedFields_contains: String
  updatedFields_contains_every: [String!]
  updatedFields_contains_some: [String!]
  node: SubmissionWhereInput
  AND: [SubmissionSubscriptionWhereInput!]
  OR: [SubmissionSubscriptionWhereInput!]
  NOT: [SubmissionSubscriptionWhereInput!]
}

input SubmissionUpdateInput {
  name: String
  steps: SubmissionUpdatestepsInput
  notes: SubmissionUpdatenotesInput
  position: PositionUpdateOneWithoutSubmissionsInput
  tags: TagUpdateManyWithoutSubmissionsInput
  user: UserUpdateOneWithoutSubmissionsInput
}

input SubmissionUpdateManyWithoutPositionInput {
  create: [SubmissionCreateWithoutPositionInput!]
  delete: [SubmissionWhereUniqueInput!]
  connect: [SubmissionWhereUniqueInput!]
  disconnect: [SubmissionWhereUniqueInput!]
  update: [SubmissionUpdateWithWhereUniqueWithoutPositionInput!]
  upsert: [SubmissionUpsertWithWhereUniqueWithoutPositionInput!]
}

input SubmissionUpdateManyWithoutTagsInput {
  create: [SubmissionCreateWithoutTagsInput!]
  delete: [SubmissionWhereUniqueInput!]
  connect: [SubmissionWhereUniqueInput!]
  disconnect: [SubmissionWhereUniqueInput!]
  update: [SubmissionUpdateWithWhereUniqueWithoutTagsInput!]
  upsert: [SubmissionUpsertWithWhereUniqueWithoutTagsInput!]
}

input SubmissionUpdateManyWithoutUserInput {
  create: [SubmissionCreateWithoutUserInput!]
  delete: [SubmissionWhereUniqueInput!]
  connect: [SubmissionWhereUniqueInput!]
  disconnect: [SubmissionWhereUniqueInput!]
  update: [SubmissionUpdateWithWhereUniqueWithoutUserInput!]
  upsert: [SubmissionUpsertWithWhereUniqueWithoutUserInput!]
}

input SubmissionUpdatenotesInput {
  set: [String!]
}

input SubmissionUpdatestepsInput {
  set: [String!]
}

input SubmissionUpdateWithoutPositionDataInput {
  name: String
  steps: SubmissionUpdatestepsInput
  notes: SubmissionUpdatenotesInput
  tags: TagUpdateManyWithoutSubmissionsInput
  user: UserUpdateOneWithoutSubmissionsInput
}

input SubmissionUpdateWithoutTagsDataInput {
  name: String
  steps: SubmissionUpdatestepsInput
  notes: SubmissionUpdatenotesInput
  position: PositionUpdateOneWithoutSubmissionsInput
  user: UserUpdateOneWithoutSubmissionsInput
}

input SubmissionUpdateWithoutUserDataInput {
  name: String
  steps: SubmissionUpdatestepsInput
  notes: SubmissionUpdatenotesInput
  position: PositionUpdateOneWithoutSubmissionsInput
  tags: TagUpdateManyWithoutSubmissionsInput
}

input SubmissionUpdateWithWhereUniqueWithoutPositionInput {
  where: SubmissionWhereUniqueInput!
  data: SubmissionUpdateWithoutPositionDataInput!
}

input SubmissionUpdateWithWhereUniqueWithoutTagsInput {
  where: SubmissionWhereUniqueInput!
  data: SubmissionUpdateWithoutTagsDataInput!
}

input SubmissionUpdateWithWhereUniqueWithoutUserInput {
  where: SubmissionWhereUniqueInput!
  data: SubmissionUpdateWithoutUserDataInput!
}

input SubmissionUpsertWithWhereUniqueWithoutPositionInput {
  where: SubmissionWhereUniqueInput!
  update: SubmissionUpdateWithoutPositionDataInput!
  create: SubmissionCreateWithoutPositionInput!
}

input SubmissionUpsertWithWhereUniqueWithoutTagsInput {
  where: SubmissionWhereUniqueInput!
  update: SubmissionUpdateWithoutTagsDataInput!
  create: SubmissionCreateWithoutTagsInput!
}

input SubmissionUpsertWithWhereUniqueWithoutUserInput {
  where: SubmissionWhereUniqueInput!
  update: SubmissionUpdateWithoutUserDataInput!
  create: SubmissionCreateWithoutUserInput!
}

input SubmissionWhereInput {
  id: ID
  id_not: ID
  id_in: [ID!]
  id_not_in: [ID!]
  id_lt: ID
  id_lte: ID
  id_gt: ID
  id_gte: ID
  id_contains: ID
  id_not_contains: ID
  id_starts_with: ID
  id_not_starts_with: ID
  id_ends_with: ID
  id_not_ends_with: ID
  createdAt: DateTime
  createdAt_not: DateTime
  createdAt_in: [DateTime!]
  createdAt_not_in: [DateTime!]
  createdAt_lt: DateTime
  createdAt_lte: DateTime
  createdAt_gt: DateTime
  createdAt_gte: DateTime
  updatedAt: DateTime
  updatedAt_not: DateTime
  updatedAt_in: [DateTime!]
  updatedAt_not_in: [DateTime!]
  updatedAt_lt: DateTime
  updatedAt_lte: DateTime
  updatedAt_gt: DateTime
  updatedAt_gte: DateTime
  name: String
  name_not: String
  name_in: [String!]
  name_not_in: [String!]
  name_lt: String
  name_lte: String
  name_gt: String
  name_gte: String
  name_contains: String
  name_not_contains: String
  name_starts_with: String
  name_not_starts_with: String
  name_ends_with: String
  name_not_ends_with: String
  position: PositionWhereInput
  tags_every: TagWhereInput
  tags_some: TagWhereInput
  tags_none: TagWhereInput
  user: UserWhereInput
  AND: [SubmissionWhereInput!]
  OR: [SubmissionWhereInput!]
  NOT: [SubmissionWhereInput!]
}

input SubmissionWhereUniqueInput {
  id: ID
}

type Subscription {
  position(where: PositionSubscriptionWhereInput): PositionSubscriptionPayload
  submission(where: SubmissionSubscriptionWhereInput): SubmissionSubscriptionPayload
  tag(where: TagSubscriptionWhereInput): TagSubscriptionPayload
  topic(where: TopicSubscriptionWhereInput): TopicSubscriptionPayload
  transition(where: TransitionSubscriptionWhereInput): TransitionSubscriptionPayload
  user(where: UserSubscriptionWhereInput): UserSubscriptionPayload
}

type Tag {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  submissions(where: SubmissionWhereInput, orderBy: SubmissionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Submission!]
  transitions(where: TransitionWhereInput, orderBy: TransitionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Transition!]
  user: User!
}

type TagConnection {
  pageInfo: PageInfo!
  edges: [TagEdge]!
  aggregate: AggregateTag!
}

input TagCreateInput {
  name: String!
  submissions: SubmissionCreateManyWithoutTagsInput
  transitions: TransitionCreateManyWithoutTagsInput
  user: UserCreateOneWithoutTagsInput!
}

input TagCreateManyWithoutSubmissionsInput {
  create: [TagCreateWithoutSubmissionsInput!]
  connect: [TagWhereUniqueInput!]
}

input TagCreateManyWithoutTransitionsInput {
  create: [TagCreateWithoutTransitionsInput!]
  connect: [TagWhereUniqueInput!]
}

input TagCreateManyWithoutUserInput {
  create: [TagCreateWithoutUserInput!]
  connect: [TagWhereUniqueInput!]
}

input TagCreateWithoutSubmissionsInput {
  name: String!
  transitions: TransitionCreateManyWithoutTagsInput
  user: UserCreateOneWithoutTagsInput!
}

input TagCreateWithoutTransitionsInput {
  name: String!
  submissions: SubmissionCreateManyWithoutTagsInput
  user: UserCreateOneWithoutTagsInput!
}

input TagCreateWithoutUserInput {
  name: String!
  submissions: SubmissionCreateManyWithoutTagsInput
  transitions: TransitionCreateManyWithoutTagsInput
}

type TagEdge {
  node: Tag!
  cursor: String!
}

enum TagOrderByInput {
  id_ASC
  id_DESC
  createdAt_ASC
  createdAt_DESC
  updatedAt_ASC
  updatedAt_DESC
  name_ASC
  name_DESC
}

type TagPreviousValues {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
}

type TagSubscriptionPayload {
  mutation: MutationType!
  node: Tag
  updatedFields: [String!]
  previousValues: TagPreviousValues
}

input TagSubscriptionWhereInput {
  mutation_in: [MutationType!]
  updatedFields_contains: String
  updatedFields_contains_every: [String!]
  updatedFields_contains_some: [String!]
  node: TagWhereInput
  AND: [TagSubscriptionWhereInput!]
  OR: [TagSubscriptionWhereInput!]
  NOT: [TagSubscriptionWhereInput!]
}

input TagUpdateInput {
  name: String
  submissions: SubmissionUpdateManyWithoutTagsInput
  transitions: TransitionUpdateManyWithoutTagsInput
  user: UserUpdateOneWithoutTagsInput
}

input TagUpdateManyWithoutSubmissionsInput {
  create: [TagCreateWithoutSubmissionsInput!]
  delete: [TagWhereUniqueInput!]
  connect: [TagWhereUniqueInput!]
  disconnect: [TagWhereUniqueInput!]
  update: [TagUpdateWithWhereUniqueWithoutSubmissionsInput!]
  upsert: [TagUpsertWithWhereUniqueWithoutSubmissionsInput!]
}

input TagUpdateManyWithoutTransitionsInput {
  create: [TagCreateWithoutTransitionsInput!]
  delete: [TagWhereUniqueInput!]
  connect: [TagWhereUniqueInput!]
  disconnect: [TagWhereUniqueInput!]
  update: [TagUpdateWithWhereUniqueWithoutTransitionsInput!]
  upsert: [TagUpsertWithWhereUniqueWithoutTransitionsInput!]
}

input TagUpdateManyWithoutUserInput {
  create: [TagCreateWithoutUserInput!]
  delete: [TagWhereUniqueInput!]
  connect: [TagWhereUniqueInput!]
  disconnect: [TagWhereUniqueInput!]
  update: [TagUpdateWithWhereUniqueWithoutUserInput!]
  upsert: [TagUpsertWithWhereUniqueWithoutUserInput!]
}

input TagUpdateWithoutSubmissionsDataInput {
  name: String
  transitions: TransitionUpdateManyWithoutTagsInput
  user: UserUpdateOneWithoutTagsInput
}

input TagUpdateWithoutTransitionsDataInput {
  name: String
  submissions: SubmissionUpdateManyWithoutTagsInput
  user: UserUpdateOneWithoutTagsInput
}

input TagUpdateWithoutUserDataInput {
  name: String
  submissions: SubmissionUpdateManyWithoutTagsInput
  transitions: TransitionUpdateManyWithoutTagsInput
}

input TagUpdateWithWhereUniqueWithoutSubmissionsInput {
  where: TagWhereUniqueInput!
  data: TagUpdateWithoutSubmissionsDataInput!
}

input TagUpdateWithWhereUniqueWithoutTransitionsInput {
  where: TagWhereUniqueInput!
  data: TagUpdateWithoutTransitionsDataInput!
}

input TagUpdateWithWhereUniqueWithoutUserInput {
  where: TagWhereUniqueInput!
  data: TagUpdateWithoutUserDataInput!
}

input TagUpsertWithWhereUniqueWithoutSubmissionsInput {
  where: TagWhereUniqueInput!
  update: TagUpdateWithoutSubmissionsDataInput!
  create: TagCreateWithoutSubmissionsInput!
}

input TagUpsertWithWhereUniqueWithoutTransitionsInput {
  where: TagWhereUniqueInput!
  update: TagUpdateWithoutTransitionsDataInput!
  create: TagCreateWithoutTransitionsInput!
}

input TagUpsertWithWhereUniqueWithoutUserInput {
  where: TagWhereUniqueInput!
  update: TagUpdateWithoutUserDataInput!
  create: TagCreateWithoutUserInput!
}

input TagWhereInput {
  id: ID
  id_not: ID
  id_in: [ID!]
  id_not_in: [ID!]
  id_lt: ID
  id_lte: ID
  id_gt: ID
  id_gte: ID
  id_contains: ID
  id_not_contains: ID
  id_starts_with: ID
  id_not_starts_with: ID
  id_ends_with: ID
  id_not_ends_with: ID
  createdAt: DateTime
  createdAt_not: DateTime
  createdAt_in: [DateTime!]
  createdAt_not_in: [DateTime!]
  createdAt_lt: DateTime
  createdAt_lte: DateTime
  createdAt_gt: DateTime
  createdAt_gte: DateTime
  updatedAt: DateTime
  updatedAt_not: DateTime
  updatedAt_in: [DateTime!]
  updatedAt_not_in: [DateTime!]
  updatedAt_lt: DateTime
  updatedAt_lte: DateTime
  updatedAt_gt: DateTime
  updatedAt_gte: DateTime
  name: String
  name_not: String
  name_in: [String!]
  name_not_in: [String!]
  name_lt: String
  name_lte: String
  name_gt: String
  name_gte: String
  name_contains: String
  name_not_contains: String
  name_starts_with: String
  name_not_starts_with: String
  name_ends_with: String
  name_not_ends_with: String
  submissions_every: SubmissionWhereInput
  submissions_some: SubmissionWhereInput
  submissions_none: SubmissionWhereInput
  transitions_every: TransitionWhereInput
  transitions_some: TransitionWhereInput
  transitions_none: TransitionWhereInput
  user: UserWhereInput
  AND: [TagWhereInput!]
  OR: [TagWhereInput!]
  NOT: [TagWhereInput!]
}

input TagWhereUniqueInput {
  id: ID
}

type Topic {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  notes: [String!]!
  user: User!
}

type TopicConnection {
  pageInfo: PageInfo!
  edges: [TopicEdge]!
  aggregate: AggregateTopic!
}

input TopicCreateInput {
  name: String!
  notes: TopicCreatenotesInput
  user: UserCreateOneWithoutTopicsInput!
}

input TopicCreateManyWithoutUserInput {
  create: [TopicCreateWithoutUserInput!]
  connect: [TopicWhereUniqueInput!]
}

input TopicCreatenotesInput {
  set: [String!]
}

input TopicCreateWithoutUserInput {
  name: String!
  notes: TopicCreatenotesInput
}

type TopicEdge {
  node: Topic!
  cursor: String!
}

enum TopicOrderByInput {
  id_ASC
  id_DESC
  createdAt_ASC
  createdAt_DESC
  updatedAt_ASC
  updatedAt_DESC
  name_ASC
  name_DESC
}

type TopicPreviousValues {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  notes: [String!]!
}

type TopicSubscriptionPayload {
  mutation: MutationType!
  node: Topic
  updatedFields: [String!]
  previousValues: TopicPreviousValues
}

input TopicSubscriptionWhereInput {
  mutation_in: [MutationType!]
  updatedFields_contains: String
  updatedFields_contains_every: [String!]
  updatedFields_contains_some: [String!]
  node: TopicWhereInput
  AND: [TopicSubscriptionWhereInput!]
  OR: [TopicSubscriptionWhereInput!]
  NOT: [TopicSubscriptionWhereInput!]
}

input TopicUpdateInput {
  name: String
  notes: TopicUpdatenotesInput
  user: UserUpdateOneWithoutTopicsInput
}

input TopicUpdateManyWithoutUserInput {
  create: [TopicCreateWithoutUserInput!]
  delete: [TopicWhereUniqueInput!]
  connect: [TopicWhereUniqueInput!]
  disconnect: [TopicWhereUniqueInput!]
  update: [TopicUpdateWithWhereUniqueWithoutUserInput!]
  upsert: [TopicUpsertWithWhereUniqueWithoutUserInput!]
}

input TopicUpdatenotesInput {
  set: [String!]
}

input TopicUpdateWithoutUserDataInput {
  name: String
  notes: TopicUpdatenotesInput
}

input TopicUpdateWithWhereUniqueWithoutUserInput {
  where: TopicWhereUniqueInput!
  data: TopicUpdateWithoutUserDataInput!
}

input TopicUpsertWithWhereUniqueWithoutUserInput {
  where: TopicWhereUniqueInput!
  update: TopicUpdateWithoutUserDataInput!
  create: TopicCreateWithoutUserInput!
}

input TopicWhereInput {
  id: ID
  id_not: ID
  id_in: [ID!]
  id_not_in: [ID!]
  id_lt: ID
  id_lte: ID
  id_gt: ID
  id_gte: ID
  id_contains: ID
  id_not_contains: ID
  id_starts_with: ID
  id_not_starts_with: ID
  id_ends_with: ID
  id_not_ends_with: ID
  createdAt: DateTime
  createdAt_not: DateTime
  createdAt_in: [DateTime!]
  createdAt_not_in: [DateTime!]
  createdAt_lt: DateTime
  createdAt_lte: DateTime
  createdAt_gt: DateTime
  createdAt_gte: DateTime
  updatedAt: DateTime
  updatedAt_not: DateTime
  updatedAt_in: [DateTime!]
  updatedAt_not_in: [DateTime!]
  updatedAt_lt: DateTime
  updatedAt_lte: DateTime
  updatedAt_gt: DateTime
  updatedAt_gte: DateTime
  name: String
  name_not: String
  name_in: [String!]
  name_not_in: [String!]
  name_lt: String
  name_lte: String
  name_gt: String
  name_gte: String
  name_contains: String
  name_not_contains: String
  name_starts_with: String
  name_not_starts_with: String
  name_ends_with: String
  name_not_ends_with: String
  user: UserWhereInput
  AND: [TopicWhereInput!]
  OR: [TopicWhereInput!]
  NOT: [TopicWhereInput!]
}

input TopicWhereUniqueInput {
  id: ID
}

type Transition {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  steps: [String!]!
  notes: [String!]!
  startPosition: Position!
  endPosition: Position!
  tags(where: TagWhereInput, orderBy: TagOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Tag!]
  user: User!
}

type TransitionConnection {
  pageInfo: PageInfo!
  edges: [TransitionEdge]!
  aggregate: AggregateTransition!
}

input TransitionCreateInput {
  name: String!
  steps: TransitionCreatestepsInput
  notes: TransitionCreatenotesInput
  startPosition: PositionCreateOneWithoutTransitionsFromInput!
  endPosition: PositionCreateOneWithoutTransitionsToInput!
  tags: TagCreateManyWithoutTransitionsInput
  user: UserCreateOneWithoutTransitionsInput!
}

input TransitionCreateManyWithoutEndPositionInput {
  create: [TransitionCreateWithoutEndPositionInput!]
  connect: [TransitionWhereUniqueInput!]
}

input TransitionCreateManyWithoutStartPositionInput {
  create: [TransitionCreateWithoutStartPositionInput!]
  connect: [TransitionWhereUniqueInput!]
}

input TransitionCreateManyWithoutTagsInput {
  create: [TransitionCreateWithoutTagsInput!]
  connect: [TransitionWhereUniqueInput!]
}

input TransitionCreateManyWithoutUserInput {
  create: [TransitionCreateWithoutUserInput!]
  connect: [TransitionWhereUniqueInput!]
}

input TransitionCreatenotesInput {
  set: [String!]
}

input TransitionCreatestepsInput {
  set: [String!]
}

input TransitionCreateWithoutEndPositionInput {
  name: String!
  steps: TransitionCreatestepsInput
  notes: TransitionCreatenotesInput
  startPosition: PositionCreateOneWithoutTransitionsFromInput!
  tags: TagCreateManyWithoutTransitionsInput
  user: UserCreateOneWithoutTransitionsInput!
}

input TransitionCreateWithoutStartPositionInput {
  name: String!
  steps: TransitionCreatestepsInput
  notes: TransitionCreatenotesInput
  endPosition: PositionCreateOneWithoutTransitionsToInput!
  tags: TagCreateManyWithoutTransitionsInput
  user: UserCreateOneWithoutTransitionsInput!
}

input TransitionCreateWithoutTagsInput {
  name: String!
  steps: TransitionCreatestepsInput
  notes: TransitionCreatenotesInput
  startPosition: PositionCreateOneWithoutTransitionsFromInput!
  endPosition: PositionCreateOneWithoutTransitionsToInput!
  user: UserCreateOneWithoutTransitionsInput!
}

input TransitionCreateWithoutUserInput {
  name: String!
  steps: TransitionCreatestepsInput
  notes: TransitionCreatenotesInput
  startPosition: PositionCreateOneWithoutTransitionsFromInput!
  endPosition: PositionCreateOneWithoutTransitionsToInput!
  tags: TagCreateManyWithoutTransitionsInput
}

type TransitionEdge {
  node: Transition!
  cursor: String!
}

enum TransitionOrderByInput {
  id_ASC
  id_DESC
  createdAt_ASC
  createdAt_DESC
  updatedAt_ASC
  updatedAt_DESC
  name_ASC
  name_DESC
}

type TransitionPreviousValues {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  name: String!
  steps: [String!]!
  notes: [String!]!
}

type TransitionSubscriptionPayload {
  mutation: MutationType!
  node: Transition
  updatedFields: [String!]
  previousValues: TransitionPreviousValues
}

input TransitionSubscriptionWhereInput {
  mutation_in: [MutationType!]
  updatedFields_contains: String
  updatedFields_contains_every: [String!]
  updatedFields_contains_some: [String!]
  node: TransitionWhereInput
  AND: [TransitionSubscriptionWhereInput!]
  OR: [TransitionSubscriptionWhereInput!]
  NOT: [TransitionSubscriptionWhereInput!]
}

input TransitionUpdateInput {
  name: String
  steps: TransitionUpdatestepsInput
  notes: TransitionUpdatenotesInput
  startPosition: PositionUpdateOneWithoutTransitionsFromInput
  endPosition: PositionUpdateOneWithoutTransitionsToInput
  tags: TagUpdateManyWithoutTransitionsInput
  user: UserUpdateOneWithoutTransitionsInput
}

input TransitionUpdateManyWithoutEndPositionInput {
  create: [TransitionCreateWithoutEndPositionInput!]
  delete: [TransitionWhereUniqueInput!]
  connect: [TransitionWhereUniqueInput!]
  disconnect: [TransitionWhereUniqueInput!]
  update: [TransitionUpdateWithWhereUniqueWithoutEndPositionInput!]
  upsert: [TransitionUpsertWithWhereUniqueWithoutEndPositionInput!]
}

input TransitionUpdateManyWithoutStartPositionInput {
  create: [TransitionCreateWithoutStartPositionInput!]
  delete: [TransitionWhereUniqueInput!]
  connect: [TransitionWhereUniqueInput!]
  disconnect: [TransitionWhereUniqueInput!]
  update: [TransitionUpdateWithWhereUniqueWithoutStartPositionInput!]
  upsert: [TransitionUpsertWithWhereUniqueWithoutStartPositionInput!]
}

input TransitionUpdateManyWithoutTagsInput {
  create: [TransitionCreateWithoutTagsInput!]
  delete: [TransitionWhereUniqueInput!]
  connect: [TransitionWhereUniqueInput!]
  disconnect: [TransitionWhereUniqueInput!]
  update: [TransitionUpdateWithWhereUniqueWithoutTagsInput!]
  upsert: [TransitionUpsertWithWhereUniqueWithoutTagsInput!]
}

input TransitionUpdateManyWithoutUserInput {
  create: [TransitionCreateWithoutUserInput!]
  delete: [TransitionWhereUniqueInput!]
  connect: [TransitionWhereUniqueInput!]
  disconnect: [TransitionWhereUniqueInput!]
  update: [TransitionUpdateWithWhereUniqueWithoutUserInput!]
  upsert: [TransitionUpsertWithWhereUniqueWithoutUserInput!]
}

input TransitionUpdatenotesInput {
  set: [String!]
}

input TransitionUpdatestepsInput {
  set: [String!]
}

input TransitionUpdateWithoutEndPositionDataInput {
  name: String
  steps: TransitionUpdatestepsInput
  notes: TransitionUpdatenotesInput
  startPosition: PositionUpdateOneWithoutTransitionsFromInput
  tags: TagUpdateManyWithoutTransitionsInput
  user: UserUpdateOneWithoutTransitionsInput
}

input TransitionUpdateWithoutStartPositionDataInput {
  name: String
  steps: TransitionUpdatestepsInput
  notes: TransitionUpdatenotesInput
  endPosition: PositionUpdateOneWithoutTransitionsToInput
  tags: TagUpdateManyWithoutTransitionsInput
  user: UserUpdateOneWithoutTransitionsInput
}

input TransitionUpdateWithoutTagsDataInput {
  name: String
  steps: TransitionUpdatestepsInput
  notes: TransitionUpdatenotesInput
  startPosition: PositionUpdateOneWithoutTransitionsFromInput
  endPosition: PositionUpdateOneWithoutTransitionsToInput
  user: UserUpdateOneWithoutTransitionsInput
}

input TransitionUpdateWithoutUserDataInput {
  name: String
  steps: TransitionUpdatestepsInput
  notes: TransitionUpdatenotesInput
  startPosition: PositionUpdateOneWithoutTransitionsFromInput
  endPosition: PositionUpdateOneWithoutTransitionsToInput
  tags: TagUpdateManyWithoutTransitionsInput
}

input TransitionUpdateWithWhereUniqueWithoutEndPositionInput {
  where: TransitionWhereUniqueInput!
  data: TransitionUpdateWithoutEndPositionDataInput!
}

input TransitionUpdateWithWhereUniqueWithoutStartPositionInput {
  where: TransitionWhereUniqueInput!
  data: TransitionUpdateWithoutStartPositionDataInput!
}

input TransitionUpdateWithWhereUniqueWithoutTagsInput {
  where: TransitionWhereUniqueInput!
  data: TransitionUpdateWithoutTagsDataInput!
}

input TransitionUpdateWithWhereUniqueWithoutUserInput {
  where: TransitionWhereUniqueInput!
  data: TransitionUpdateWithoutUserDataInput!
}

input TransitionUpsertWithWhereUniqueWithoutEndPositionInput {
  where: TransitionWhereUniqueInput!
  update: TransitionUpdateWithoutEndPositionDataInput!
  create: TransitionCreateWithoutEndPositionInput!
}

input TransitionUpsertWithWhereUniqueWithoutStartPositionInput {
  where: TransitionWhereUniqueInput!
  update: TransitionUpdateWithoutStartPositionDataInput!
  create: TransitionCreateWithoutStartPositionInput!
}

input TransitionUpsertWithWhereUniqueWithoutTagsInput {
  where: TransitionWhereUniqueInput!
  update: TransitionUpdateWithoutTagsDataInput!
  create: TransitionCreateWithoutTagsInput!
}

input TransitionUpsertWithWhereUniqueWithoutUserInput {
  where: TransitionWhereUniqueInput!
  update: TransitionUpdateWithoutUserDataInput!
  create: TransitionCreateWithoutUserInput!
}

input TransitionWhereInput {
  id: ID
  id_not: ID
  id_in: [ID!]
  id_not_in: [ID!]
  id_lt: ID
  id_lte: ID
  id_gt: ID
  id_gte: ID
  id_contains: ID
  id_not_contains: ID
  id_starts_with: ID
  id_not_starts_with: ID
  id_ends_with: ID
  id_not_ends_with: ID
  createdAt: DateTime
  createdAt_not: DateTime
  createdAt_in: [DateTime!]
  createdAt_not_in: [DateTime!]
  createdAt_lt: DateTime
  createdAt_lte: DateTime
  createdAt_gt: DateTime
  createdAt_gte: DateTime
  updatedAt: DateTime
  updatedAt_not: DateTime
  updatedAt_in: [DateTime!]
  updatedAt_not_in: [DateTime!]
  updatedAt_lt: DateTime
  updatedAt_lte: DateTime
  updatedAt_gt: DateTime
  updatedAt_gte: DateTime
  name: String
  name_not: String
  name_in: [String!]
  name_not_in: [String!]
  name_lt: String
  name_lte: String
  name_gt: String
  name_gte: String
  name_contains: String
  name_not_contains: String
  name_starts_with: String
  name_not_starts_with: String
  name_ends_with: String
  name_not_ends_with: String
  startPosition: PositionWhereInput
  endPosition: PositionWhereInput
  tags_every: TagWhereInput
  tags_some: TagWhereInput
  tags_none: TagWhereInput
  user: UserWhereInput
  AND: [TransitionWhereInput!]
  OR: [TransitionWhereInput!]
  NOT: [TransitionWhereInput!]
}

input TransitionWhereUniqueInput {
  id: ID
}

type User {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  email: String!
  password: String!
  positions(where: PositionWhereInput, orderBy: PositionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Position!]
  submissions(where: SubmissionWhereInput, orderBy: SubmissionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Submission!]
  transitions(where: TransitionWhereInput, orderBy: TransitionOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Transition!]
  topics(where: TopicWhereInput, orderBy: TopicOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Topic!]
  tags(where: TagWhereInput, orderBy: TagOrderByInput, skip: Int, after: String, before: String, first: Int, last: Int): [Tag!]
}

type UserConnection {
  pageInfo: PageInfo!
  edges: [UserEdge]!
  aggregate: AggregateUser!
}

input UserCreateInput {
  email: String!
  password: String!
  positions: PositionCreateManyWithoutUserInput
  submissions: SubmissionCreateManyWithoutUserInput
  transitions: TransitionCreateManyWithoutUserInput
  topics: TopicCreateManyWithoutUserInput
  tags: TagCreateManyWithoutUserInput
}

input UserCreateOneWithoutPositionsInput {
  create: UserCreateWithoutPositionsInput
  connect: UserWhereUniqueInput
}

input UserCreateOneWithoutSubmissionsInput {
  create: UserCreateWithoutSubmissionsInput
  connect: UserWhereUniqueInput
}

input UserCreateOneWithoutTagsInput {
  create: UserCreateWithoutTagsInput
  connect: UserWhereUniqueInput
}

input UserCreateOneWithoutTopicsInput {
  create: UserCreateWithoutTopicsInput
  connect: UserWhereUniqueInput
}

input UserCreateOneWithoutTransitionsInput {
  create: UserCreateWithoutTransitionsInput
  connect: UserWhereUniqueInput
}

input UserCreateWithoutPositionsInput {
  email: String!
  password: String!
  submissions: SubmissionCreateManyWithoutUserInput
  transitions: TransitionCreateManyWithoutUserInput
  topics: TopicCreateManyWithoutUserInput
  tags: TagCreateManyWithoutUserInput
}

input UserCreateWithoutSubmissionsInput {
  email: String!
  password: String!
  positions: PositionCreateManyWithoutUserInput
  transitions: TransitionCreateManyWithoutUserInput
  topics: TopicCreateManyWithoutUserInput
  tags: TagCreateManyWithoutUserInput
}

input UserCreateWithoutTagsInput {
  email: String!
  password: String!
  positions: PositionCreateManyWithoutUserInput
  submissions: SubmissionCreateManyWithoutUserInput
  transitions: TransitionCreateManyWithoutUserInput
  topics: TopicCreateManyWithoutUserInput
}

input UserCreateWithoutTopicsInput {
  email: String!
  password: String!
  positions: PositionCreateManyWithoutUserInput
  submissions: SubmissionCreateManyWithoutUserInput
  transitions: TransitionCreateManyWithoutUserInput
  tags: TagCreateManyWithoutUserInput
}

input UserCreateWithoutTransitionsInput {
  email: String!
  password: String!
  positions: PositionCreateManyWithoutUserInput
  submissions: SubmissionCreateManyWithoutUserInput
  topics: TopicCreateManyWithoutUserInput
  tags: TagCreateManyWithoutUserInput
}

type UserEdge {
  node: User!
  cursor: String!
}

enum UserOrderByInput {
  id_ASC
  id_DESC
  createdAt_ASC
  createdAt_DESC
  updatedAt_ASC
  updatedAt_DESC
  email_ASC
  email_DESC
  password_ASC
  password_DESC
}

type UserPreviousValues {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  email: String!
  password: String!
}

type UserSubscriptionPayload {
  mutation: MutationType!
  node: User
  updatedFields: [String!]
  previousValues: UserPreviousValues
}

input UserSubscriptionWhereInput {
  mutation_in: [MutationType!]
  updatedFields_contains: String
  updatedFields_contains_every: [String!]
  updatedFields_contains_some: [String!]
  node: UserWhereInput
  AND: [UserSubscriptionWhereInput!]
  OR: [UserSubscriptionWhereInput!]
  NOT: [UserSubscriptionWhereInput!]
}

input UserUpdateInput {
  email: String
  password: String
  positions: PositionUpdateManyWithoutUserInput
  submissions: SubmissionUpdateManyWithoutUserInput
  transitions: TransitionUpdateManyWithoutUserInput
  topics: TopicUpdateManyWithoutUserInput
  tags: TagUpdateManyWithoutUserInput
}

input UserUpdateOneWithoutPositionsInput {
  create: UserCreateWithoutPositionsInput
  update: UserUpdateWithoutPositionsDataInput
  upsert: UserUpsertWithoutPositionsInput
  delete: Boolean
  connect: UserWhereUniqueInput
}

input UserUpdateOneWithoutSubmissionsInput {
  create: UserCreateWithoutSubmissionsInput
  update: UserUpdateWithoutSubmissionsDataInput
  upsert: UserUpsertWithoutSubmissionsInput
  delete: Boolean
  connect: UserWhereUniqueInput
}

input UserUpdateOneWithoutTagsInput {
  create: UserCreateWithoutTagsInput
  update: UserUpdateWithoutTagsDataInput
  upsert: UserUpsertWithoutTagsInput
  delete: Boolean
  connect: UserWhereUniqueInput
}

input UserUpdateOneWithoutTopicsInput {
  create: UserCreateWithoutTopicsInput
  update: UserUpdateWithoutTopicsDataInput
  upsert: UserUpsertWithoutTopicsInput
  delete: Boolean
  connect: UserWhereUniqueInput
}

input UserUpdateOneWithoutTransitionsInput {
  create: UserCreateWithoutTransitionsInput
  update: UserUpdateWithoutTransitionsDataInput
  upsert: UserUpsertWithoutTransitionsInput
  delete: Boolean
  connect: UserWhereUniqueInput
}

input UserUpdateWithoutPositionsDataInput {
  email: String
  password: String
  submissions: SubmissionUpdateManyWithoutUserInput
  transitions: TransitionUpdateManyWithoutUserInput
  topics: TopicUpdateManyWithoutUserInput
  tags: TagUpdateManyWithoutUserInput
}

input UserUpdateWithoutSubmissionsDataInput {
  email: String
  password: String
  positions: PositionUpdateManyWithoutUserInput
  transitions: TransitionUpdateManyWithoutUserInput
  topics: TopicUpdateManyWithoutUserInput
  tags: TagUpdateManyWithoutUserInput
}

input UserUpdateWithoutTagsDataInput {
  email: String
  password: String
  positions: PositionUpdateManyWithoutUserInput
  submissions: SubmissionUpdateManyWithoutUserInput
  transitions: TransitionUpdateManyWithoutUserInput
  topics: TopicUpdateManyWithoutUserInput
}

input UserUpdateWithoutTopicsDataInput {
  email: String
  password: String
  positions: PositionUpdateManyWithoutUserInput
  submissions: SubmissionUpdateManyWithoutUserInput
  transitions: TransitionUpdateManyWithoutUserInput
  tags: TagUpdateManyWithoutUserInput
}

input UserUpdateWithoutTransitionsDataInput {
  email: String
  password: String
  positions: PositionUpdateManyWithoutUserInput
  submissions: SubmissionUpdateManyWithoutUserInput
  topics: TopicUpdateManyWithoutUserInput
  tags: TagUpdateManyWithoutUserInput
}

input UserUpsertWithoutPositionsInput {
  update: UserUpdateWithoutPositionsDataInput!
  create: UserCreateWithoutPositionsInput!
}

input UserUpsertWithoutSubmissionsInput {
  update: UserUpdateWithoutSubmissionsDataInput!
  create: UserCreateWithoutSubmissionsInput!
}

input UserUpsertWithoutTagsInput {
  update: UserUpdateWithoutTagsDataInput!
  create: UserCreateWithoutTagsInput!
}

input UserUpsertWithoutTopicsInput {
  update: UserUpdateWithoutTopicsDataInput!
  create: UserCreateWithoutTopicsInput!
}

input UserUpsertWithoutTransitionsInput {
  update: UserUpdateWithoutTransitionsDataInput!
  create: UserCreateWithoutTransitionsInput!
}

input UserWhereInput {
  id: ID
  id_not: ID
  id_in: [ID!]
  id_not_in: [ID!]
  id_lt: ID
  id_lte: ID
  id_gt: ID
  id_gte: ID
  id_contains: ID
  id_not_contains: ID
  id_starts_with: ID
  id_not_starts_with: ID
  id_ends_with: ID
  id_not_ends_with: ID
  createdAt: DateTime
  createdAt_not: DateTime
  createdAt_in: [DateTime!]
  createdAt_not_in: [DateTime!]
  createdAt_lt: DateTime
  createdAt_lte: DateTime
  createdAt_gt: DateTime
  createdAt_gte: DateTime
  updatedAt: DateTime
  updatedAt_not: DateTime
  updatedAt_in: [DateTime!]
  updatedAt_not_in: [DateTime!]
  updatedAt_lt: DateTime
  updatedAt_lte: DateTime
  updatedAt_gt: DateTime
  updatedAt_gte: DateTime
  email: String
  email_not: String
  email_in: [String!]
  email_not_in: [String!]
  email_lt: String
  email_lte: String
  email_gt: String
  email_gte: String
  email_contains: String
  email_not_contains: String
  email_starts_with: String
  email_not_starts_with: String
  email_ends_with: String
  email_not_ends_with: String
  password: String
  password_not: String
  password_in: [String!]
  password_not_in: [String!]
  password_lt: String
  password_lte: String
  password_gt: String
  password_gte: String
  password_contains: String
  password_not_contains: String
  password_starts_with: String
  password_not_starts_with: String
  password_ends_with: String
  password_not_ends_with: String
  positions_every: PositionWhereInput
  positions_some: PositionWhereInput
  positions_none: PositionWhereInput
  submissions_every: SubmissionWhereInput
  submissions_some: SubmissionWhereInput
  submissions_none: SubmissionWhereInput
  transitions_every: TransitionWhereInput
  transitions_some: TransitionWhereInput
  transitions_none: TransitionWhereInput
  topics_every: TopicWhereInput
  topics_some: TopicWhereInput
  topics_none: TopicWhereInput
  tags_every: TagWhereInput
  tags_some: TagWhereInput
  tags_none: TagWhereInput
  AND: [UserWhereInput!]
  OR: [UserWhereInput!]
  NOT: [UserWhereInput!]
}

input UserWhereUniqueInput {
  id: ID
  email: String
}
`
      }
    