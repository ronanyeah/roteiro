module Data exposing (..)

import Array exposing (Array)
import GraphQL.Client.Http exposing (Error, customSendQueryRaw, customSendMutationRaw)
import GraphQL.Request.Builder as B
import GraphQL.Request.Builder.Arg as Arg
import Http
import Json.Decode as Decode exposing (Decoder)
import Utils exposing (filterEmpty, unwrap)
import Task exposing (Task)
import Types exposing (..)


decodeGcError : Decoder { code : Int, message : String }
decodeGcError =
    Decode.map2 (\c m -> { code = c, message = m })
        (Decode.field "code" Decode.int)
        (Decode.field "message" Decode.string)


query : String -> String -> B.Request B.Query a -> Task GcError a
query url token request =
    customSendQueryRaw
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = url
        , timeout = Nothing
        , withCredentials = False
        }
        request
        |> convert request


mutate : String -> String -> B.Request B.Mutation a -> Task GcError a
mutate url token request =
    customSendMutationRaw
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = url
        , timeout = Nothing
        , withCredentials = False
        }
        request
        |> convert request


convert : B.Request x a -> Task Error (Http.Response String) -> Task GcError a
convert request =
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
                            (Decode.maybe <| Decode.field "data" <| B.responseDataDecoder request)
                in
                    case Decode.decodeString decoder response.body of
                        Err err ->
                            Task.fail <| HttpError <| Http.BadPayload err response

                        Ok res ->
                            case res of
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


fetchData : B.Request B.Query AllData
fetchData =
    B.object AllData
        |> B.with (B.field "allTransitions" [] (B.list transition))
        |> B.with (B.field "allPositions" [] (B.list position))
        |> B.with (B.field "allSubmissions" [] (B.list submission))
        |> B.with (B.field "allTopics" [] (B.list topic))
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
            , ( "when", Arg.null )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()



-- UPDATE


updateSubmission : Submission -> B.Request B.Mutation Submission
updateSubmission s =
    case ( s.id, s.position ) of
        ( Id id, Id positionId ) ->
            submission
                |> B.field "updateSubmission"
                    [ ( "id", Arg.string id )
                    , ( "name", Arg.string s.name )
                    , ( "positionId", Arg.string positionId )
                    , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList s.notes )
                    , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList s.steps )
                    , ( "when", unwrap Arg.null Arg.string s.when )
                    ]
                |> B.extract
                |> B.mutationDocument
                |> B.request ()


updateTransition : Transition -> B.Request B.Mutation Transition
updateTransition t =
    case ( t.id, t.startPosition, t.endPosition ) of
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


deleteSubmission : Id -> B.Request B.Mutation Submission
deleteSubmission (Id id) =
    submission
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


deleteTransition : Id -> B.Request B.Mutation Transition
deleteTransition (Id id) =
    transition
        |> B.field "deleteTransition"
            [ ( "id", Arg.string id )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()



-- SELECTIONS


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


submission : B.ValueSpec B.NonNull B.ObjectType Submission vars
submission =
    B.object Submission
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "steps" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "when" [] (B.nullable B.string))
        |> B.with
            (B.field "position"
                []
                (B.field "id" [] (B.map Id B.id) |> B.extract)
            )


transition : B.ValueSpec B.NonNull B.ObjectType Transition vars
transition =
    B.object Transition
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with
            (B.field "startPosition"
                []
                (B.field "id" [] (B.map Id B.id) |> B.extract)
            )
        |> B.with
            (B.field "endPosition"
                []
                (B.field "id" [] (B.map Id B.id) |> B.extract)
            )
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "steps" [] (B.list B.string |> B.map Array.fromList))
