module Api exposing (auth, fetch, login, mutation, position, positionInfo, signUp, submission, submissionInfo, tag, tagInfo, topic, topicInfo, transition, transitionInfo)

import Api.Mutation
import Api.Object
import Api.Object.AuthResponse
import Api.Object.Position
import Api.Object.Submission
import Api.Object.Tag
import Api.Object.Topic
import Api.Object.Transition
import Api.Query
import Api.Scalar exposing (Id(..))
import Array
import Graphql.Field
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Types exposing (ApiUrl(..), Auth, Form, GqlResult, Info, Msg(..), Position, Submission, Tag, Token(..), Topic, Transition)
import Utils exposing (addErrors, arrayRemove, clearErrors, emptyForm, formatErrors, goTo, unwrap)


topicInfo : SelectionSet Info Api.Object.Topic
topicInfo =
    Api.Object.Topic.selection Info
        |> with Api.Object.Topic.id
        |> with Api.Object.Topic.name


topic : SelectionSet Topic Api.Object.Topic
topic =
    Api.Object.Topic.selection Topic
        |> with Api.Object.Topic.id
        |> with Api.Object.Topic.name
        |> with (Api.Object.Topic.notes |> Graphql.Field.map (unwrap Array.empty Array.fromList))


positionInfo : SelectionSet Info Api.Object.Position
positionInfo =
    Api.Object.Position.selection Info
        |> with Api.Object.Position.id
        |> with Api.Object.Position.name


position : SelectionSet Position Api.Object.Position
position =
    Api.Object.Position.selection Position
        |> with Api.Object.Position.id
        |> with Api.Object.Position.name
        |> with (Api.Object.Position.notes |> Graphql.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Position.submissions identity submissionInfo |> Graphql.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Position.transitionsFrom identity transition |> Graphql.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Position.transitionsTo identity transition |> Graphql.Field.map (Maybe.withDefault []))


transition : SelectionSet Transition Api.Object.Transition
transition =
    Api.Object.Transition.selection Transition
        |> with Api.Object.Transition.id
        |> with Api.Object.Transition.name
        |> with (Api.Object.Transition.startPosition identity positionInfo)
        |> with (Api.Object.Transition.endPosition identity positionInfo)
        |> with (Api.Object.Transition.notes |> Graphql.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Transition.steps |> Graphql.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Transition.tags identity tagInfo |> Graphql.Field.map (Maybe.withDefault []))


transitionInfo : SelectionSet Info Api.Object.Transition
transitionInfo =
    Api.Object.Transition.selection Info
        |> with Api.Object.Transition.id
        |> with Api.Object.Transition.name


submissionInfo : SelectionSet Info Api.Object.Submission
submissionInfo =
    Api.Object.Submission.selection Info
        |> with Api.Object.Submission.id
        |> with Api.Object.Submission.name


submission : SelectionSet Submission Api.Object.Submission
submission =
    Api.Object.Submission.selection Submission
        |> with Api.Object.Submission.id
        |> with Api.Object.Submission.name
        |> with (Api.Object.Submission.steps |> Graphql.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Submission.notes |> Graphql.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Submission.position identity positionInfo)
        |> with (Api.Object.Submission.tags identity tagInfo |> Graphql.Field.map (Maybe.withDefault []))


tagInfo : SelectionSet Info Api.Object.Tag
tagInfo =
    Api.Object.Tag.selection Info
        |> with Api.Object.Tag.id
        |> with Api.Object.Tag.name


tag : SelectionSet Tag Api.Object.Tag
tag =
    Api.Object.Tag.selection Tag
        |> with Api.Object.Tag.id
        |> with Api.Object.Tag.name
        |> with (Api.Object.Tag.submissions identity submissionInfo |> Graphql.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Tag.transitions identity transitionInfo |> Graphql.Field.map (Maybe.withDefault []))


auth : SelectionSet Auth Api.Object.AuthResponse
auth =
    Api.Object.AuthResponse.selection
        (\id email token ->
            { token = Token token
            , id = id
            , email = email
            }
        )
        |> with Api.Object.AuthResponse.id
        |> with Api.Object.AuthResponse.email
        |> with Api.Object.AuthResponse.token


fetch : ApiUrl -> Token -> Graphql.Field.Field a RootQuery -> (GqlResult a -> Msg) -> Cmd Msg
fetch (ApiUrl apiUrl) (Token token) sel msg =
    Api.Query.selection identity
        |> with sel
        |> Graphql.Http.queryRequest apiUrl
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphql.Http.send msg


mutation : ApiUrl -> Token -> Graphql.Field.Field a RootMutation -> (GqlResult a -> Msg) -> Cmd Msg
mutation (ApiUrl apiUrl) (Token token) sel msg =
    Api.Mutation.selection identity
        |> with sel
        |> Graphql.Http.mutationRequest apiUrl
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphql.Http.send msg


login : ApiUrl -> Form -> Cmd Msg
login (ApiUrl apiUrl) form =
    Api.Mutation.selection identity
        |> Graphql.SelectionSet.with
            (Api.Mutation.authenticateUser
                { email = form.email
                , password = form.password
                }
                auth
            )
        |> Graphql.Http.mutationRequest apiUrl
        |> Graphql.Http.send CbAuth


signUp : ApiUrl -> Form -> Cmd Msg
signUp (ApiUrl apiUrl) form =
    Api.Mutation.selection identity
        |> Graphql.SelectionSet.with
            (Api.Mutation.signUpUser
                { email = form.email
                , password = form.password
                }
                auth
            )
        |> Graphql.Http.mutationRequest apiUrl
        |> Graphql.Http.send CbAuth
