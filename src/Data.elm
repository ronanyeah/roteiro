module Data exposing (..)

import Array exposing (Array)
import GraphQL.Client.Http exposing (customSendMutationRaw, customSendQueryRaw)
import GraphQL.Request.Builder as B
import GraphQL.Request.Builder.Arg as Arg
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData
import Task exposing (Task)
import Types exposing (..)
import Utils exposing (filterEmpty)


decodeGcError : Decoder { code : Int, message : String }
decodeGcError =
    Decode.map2 (\c m -> { code = c, message = m })
        (Decode.field "code" Decode.int)
        (Decode.field "message" Decode.string)


queryTask : String -> String -> B.Request B.Query a -> Task GcError a
queryTask url token request =
    customSendQueryRaw
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = url
        , timeout = Nothing
        , withCredentials = False
        }
        request
        |> convert (B.responseDataDecoder request)


query : String -> String -> (GcData a -> msg) -> B.Request B.Query a -> Cmd msg
query url token msg request =
    queryTask url token request
        |> RemoteData.asCmd
        |> Cmd.map msg


mutationTask : String -> String -> B.Request B.Mutation a -> Task GcError a
mutationTask url token request =
    customSendMutationRaw
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = url
        , timeout = Nothing
        , withCredentials = False
        }
        request
        |> convert (B.responseDataDecoder request)


mutation : String -> String -> (GcData a -> msg) -> B.Request B.Mutation a -> Cmd msg
mutation url token msg request =
    mutationTask url token request
        |> RemoteData.asCmd
        |> Cmd.map msg


convert : Decoder a -> Task GraphQL.Client.Http.Error (Http.Response String) -> Task GcError a
convert resDecoder =
    Task.mapError
        (\e ->
            case e of
                GraphQL.Client.Http.HttpError err ->
                    HttpError err

                GraphQL.Client.Http.GraphQLError xs ->
                    xs
                        |> List.map
                            (\{ message } ->
                                { code = 999
                                , message = message
                                }
                            )
                        |> GcError
        )
        >> Task.andThen
            (\response ->
                let
                    decoder =
                        Decode.map2 (,)
                            (Decode.maybe <| Decode.field "errors" <| Decode.list decodeGcError)
                            (Decode.maybe <| Decode.field "data" resDecoder)
                in
                case Decode.decodeString decoder response.body of
                    Err err ->
                        Task.fail <| HttpError <| Http.BadPayload err response

                    Ok result ->
                        case result of
                            ( Just [], Just d ) ->
                                Task.succeed d

                            ( Just errs, Just _ ) ->
                                Task.fail
                                    (GcError
                                        ({ code = 999
                                         , message = "data returned with errors"
                                         }
                                            :: errs
                                        )
                                    )

                            ( Nothing, Just d ) ->
                                Task.succeed d

                            ( Just errs, Nothing ) ->
                                Task.fail (GcError errs)

                            ( Nothing, Nothing ) ->
                                Task.fail <| HttpError <| Http.BadPayload "f'kd payload" response
            )


fetchPosition : Id -> B.Request B.Query Position
fetchPosition (Id id) =
    position
        |> B.field "Position" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchInfo : String -> B.Request B.Query (List Info)
fetchInfo field =
    B.list info
        |> B.field field []
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchPositions : B.Request B.Query (List Position)
fetchPositions =
    B.list position
        |> B.field "allPositions" []
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchSubmissions : B.Request B.Query (List Submission)
fetchSubmissions =
    B.list submission
        |> B.field "allSubmissions" []
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchTopics : B.Request B.Query (List Info)
fetchTopics =
    fetchInfo "allTopics"


fetchTransitions : B.Request B.Query (List Transition)
fetchTransitions =
    B.list transition
        |> B.field "allTransitions" []
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchSubmission : Id -> B.Request B.Query Submission
fetchSubmission (Id id) =
    submission
        |> B.field "Submission" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchTopic : Id -> B.Request B.Query Topic
fetchTopic (Id id) =
    topic
        |> B.field "Topic" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchTransition : Id -> B.Request B.Query Transition
fetchTransition (Id id) =
    transition
        |> B.field "Transition" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()



-- CREATE


createPosition : String -> Array String -> B.Request B.Mutation Position
createPosition name notes =
    position
        |> B.field "createPosition"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createTopic : String -> Array String -> B.Request B.Mutation Topic
createTopic name notes =
    topic
        |> B.field "createTopic"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createTransition : String -> Array String -> Array String -> Id -> Id -> B.Request B.Mutation Transition
createTransition name steps notes (Id startId) (Id endId) =
    transition
        |> B.field "createTransition"
            [ ( "name", Arg.string name )
            , ( "startPositionId", Arg.string startId )
            , ( "endPositionId", Arg.string endId )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
            , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList steps )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createSubmission : String -> Array String -> Array String -> Id -> B.Request B.Mutation Submission
createSubmission name steps notes (Id startId) =
    submission
        |> B.field "createSubmission"
            [ ( "name", Arg.string name )
            , ( "positionId", Arg.string startId )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
            , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList steps )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()



-- UPDATE


updateSubmission : Submission -> B.Request B.Mutation Submission
updateSubmission s =
    case ( s.id, s.position.id ) of
        ( Id id, Id positionId ) ->
            submission
                |> B.field "updateSubmission"
                    [ ( "id", Arg.string id )
                    , ( "name", Arg.string s.name )
                    , ( "positionId", Arg.string positionId )
                    , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList s.notes )
                    , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList s.steps )
                    ]
                |> B.extract
                |> B.mutationDocument
                |> B.request ()


updateTransition : Transition -> B.Request B.Mutation Transition
updateTransition t =
    case ( t.id, t.startPosition.id, t.endPosition.id ) of
        ( Id id, Id startId, Id endId ) ->
            transition
                |> B.field "updateTransition"
                    [ ( "id", Arg.string id )
                    , ( "name", Arg.string t.name )
                    , ( "startPositionId", Arg.string startId )
                    , ( "endPositionId", Arg.string endId )
                    , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList t.notes )
                    , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList t.steps )
                    ]
                |> B.extract
                |> B.mutationDocument
                |> B.request ()


updatePosition : Position -> B.Request B.Mutation Position
updatePosition p =
    let
        (Id id) =
            p.id
    in
    position
        |> B.field "updatePosition"
            [ ( "id", Arg.string id )
            , ( "name", Arg.string p.name )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList p.notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


updateTopic : Topic -> B.Request B.Mutation Topic
updateTopic { id, name, notes } =
    case id of
        Id idStr ->
            topic
                |> B.field "updateTopic"
                    [ ( "id", Arg.string idStr )
                    , ( "name", Arg.string name )
                    , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
                    ]
                |> B.extract
                |> B.mutationDocument
                |> B.request ()



-- DELETE


deletePosition : Id -> B.Request B.Mutation Id
deletePosition (Id id) =
    B.id
        |> B.map Id
        |> B.field "id" []
        |> B.extract
        |> B.field "deletePosition"
            [ ( "id", Arg.string id )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


deleteSubmission : Id -> B.Request B.Mutation Id
deleteSubmission (Id id) =
    B.id
        |> B.map Id
        |> B.field "id" []
        |> B.extract
        |> B.field "deleteSubmission"
            [ ( "id", Arg.string id )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


deleteTopic : Id -> B.Request B.Mutation Id
deleteTopic (Id id) =
    B.id
        |> B.map Id
        |> B.field "id" []
        |> B.extract
        |> B.field "deleteTopic"
            [ ( "id", Arg.string id )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


deleteTransition : Id -> B.Request B.Mutation Id
deleteTransition (Id id) =
    B.id
        |> B.map Id
        |> B.field "id" []
        |> B.extract
        |> B.field "deleteTransition"
            [ ( "id", Arg.string id )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()



-- SELECTIONS


info : B.ValueSpec B.NonNull B.ObjectType Info vars
info =
    B.object Info
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)


topic : B.ValueSpec B.NonNull B.ObjectType Topic vars
topic =
    B.object Topic
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))


position : B.ValueSpec B.NonNull B.ObjectType Position vars
position =
    B.object Position
        |> B.with (B.field "id" [] (B.id |> B.map Id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "submissions" [] (B.list info))
        |> B.with (B.field "transitionsFrom" [] (B.list info))


submission : B.ValueSpec B.NonNull B.ObjectType Submission vars
submission =
    B.object Submission
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "steps" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "position" [] info)


transition : B.ValueSpec B.NonNull B.ObjectType Transition vars
transition =
    B.object Transition
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "startPosition" [] info)
        |> B.with (B.field "endPosition" [] info)
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "steps" [] (B.list B.string |> B.map Array.fromList))
