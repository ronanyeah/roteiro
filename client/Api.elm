module Api exposing (..)

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
import Graphqelm.Field
import Graphqelm.Http
import Graphqelm.Operation exposing (RootMutation, RootQuery)
import Graphqelm.SelectionSet exposing (SelectionSet, with)
import Types exposing (Auth, Form, GqlResult, Info, Msg(..), Position, Submission, Tag, Token(Token), Topic, Transition, Url(Url))
import Utils exposing (addErrors, arrayRemove, clearErrors, emptyForm, formatErrors, goTo, log, unwrap)


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
        |> with (Api.Object.Topic.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))


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
        |> with (Api.Object.Position.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Position.submissions identity submissionInfo |> Graphqelm.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Position.transitionsFrom identity transition |> Graphqelm.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Position.transitionsTo identity transition |> Graphqelm.Field.map (Maybe.withDefault []))


transition : SelectionSet Transition Api.Object.Transition
transition =
    Api.Object.Transition.selection Transition
        |> with Api.Object.Transition.id
        |> with Api.Object.Transition.name
        |> with (Api.Object.Transition.startPosition identity positionInfo)
        |> with (Api.Object.Transition.endPosition identity positionInfo)
        |> with (Api.Object.Transition.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Transition.steps |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Transition.tags identity tagInfo |> Graphqelm.Field.map (Maybe.withDefault []))


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
        |> with (Api.Object.Submission.steps |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Submission.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Submission.position identity positionInfo)
        |> with (Api.Object.Submission.tags identity tagInfo |> Graphqelm.Field.map (Maybe.withDefault []))


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
        |> with (Api.Object.Tag.submissions identity submissionInfo |> Graphqelm.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Tag.transitions identity transitionInfo |> Graphqelm.Field.map (Maybe.withDefault []))


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


fetch : Url -> Token -> Graphqelm.Field.Field a RootQuery -> (GqlResult a -> Msg) -> Cmd Msg
fetch (Url apiUrl) (Token token) sel msg =
    Api.Query.selection identity
        |> with sel
        |> Graphqelm.Http.queryRequest apiUrl
        |> Graphqelm.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphqelm.Http.send msg


mutation : Url -> Token -> Graphqelm.Field.Field a RootMutation -> (GqlResult a -> Msg) -> Cmd Msg
mutation (Url apiUrl) (Token token) sel msg =
    Api.Mutation.selection identity
        |> with sel
        |> Graphqelm.Http.mutationRequest apiUrl
        |> Graphqelm.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphqelm.Http.send msg


login : Url -> Form -> Cmd Msg
login (Url apiUrl) form =
    Api.Mutation.selection identity
        |> Graphqelm.SelectionSet.with
            (Api.Mutation.authenticateUser
                { email = form.email
                , password = form.password
                }
                auth
            )
        |> Graphqelm.Http.mutationRequest apiUrl
        |> Graphqelm.Http.send CbAuth


signUp : Url -> Form -> Cmd Msg
signUp (Url apiUrl) form =
    Api.Mutation.selection identity
        |> Graphqelm.SelectionSet.with
            (Api.Mutation.signUpUser
                { email = form.email
                , password = form.password
                }
                auth
            )
        |> Graphqelm.Http.mutationRequest apiUrl
        |> Graphqelm.Http.send CbAuth
