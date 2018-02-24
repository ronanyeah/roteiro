module Data exposing (..)

import Array
import GraphQL.Client.Http exposing (customSendMutationRaw, customSendQueryRaw)
import GraphQL.Request.Builder as B
import GraphQL.Request.Builder.Arg as Arg
import Http
import Json.Decode as Decode exposing (Decoder)
import Task exposing (Task)
import Types exposing (..)


decodeGcError : Decoder ApiError
decodeGcError =
    Decode.oneOf
        [ Decode.field "code" Decode.int
            |> Decode.map
                (\code ->
                    case code of
                        3032 ->
                            RelationIsRequired

                        3008 ->
                            InsufficientPermissions

                        3016 ->
                            Other "Missing project!"

                        n ->
                            Other <| "GraphCool Error Code: " ++ toString n
                )
        , Decode.field "message" Decode.string
            |> Decode.map Other
        ]


query : String -> B.Request B.Query a -> Task GcError a
query token request =
    customSendQueryRaw
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = "/api"
        , timeout = Nothing
        , withCredentials = False
        }
        request
        |> convert (B.responseDataDecoder request)


mutation : String -> B.Request B.Mutation a -> Task GcError a
mutation token request =
    customSendMutationRaw
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = "/api"
        , timeout = Nothing
        , withCredentials = False
        }
        request
        |> convert (B.responseDataDecoder request)


convert : Decoder a -> Task GraphQL.Client.Http.Error (Http.Response String) -> Task GcError a
convert resDecoder =
    Task.mapError
        (\e ->
            case e of
                GraphQL.Client.Http.HttpError err ->
                    HttpError err

                GraphQL.Client.Http.GraphQLError xs ->
                    xs
                        |> List.map (.message >> Other)
                        |> GcError
        )
        >> Task.andThen
            (\response ->
                let
                    decoders =
                        Decode.oneOf
                            [ Decode.list decodeGcError
                                |> Decode.field "errors"
                                |> Decode.map (GcError >> Task.fail)
                            , decodeGcError
                                |> Decode.map (List.singleton >> GcError >> Task.fail)
                            , Decode.field "data" resDecoder
                                |> Decode.map Task.succeed
                            ]
                in
                Decode.decodeString decoders response.body
                    |> Result.withDefault (Task.fail <| GcError [ Other "very bad" ])
            )


fetchInfo : String -> B.Request B.Query (List Info)
fetchInfo field =
    B.list info
        |> B.field field []
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchPosition : Id -> B.Request B.Query (Maybe Position)
fetchPosition (Id id) =
    position
        |> B.nullable
        |> B.field "Position" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchPositions : B.Request B.Query (List Info)
fetchPositions =
    fetchInfo "allPositions"


fetchSubmission : Id -> B.Request B.Query (Maybe Submission)
fetchSubmission (Id id) =
    submission
        |> B.nullable
        |> B.field "Submission" [ ( "id", Arg.string id ) ]
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


fetchTag : Id -> B.Request B.Query (Maybe Tag)
fetchTag (Id id) =
    tag
        |> B.nullable
        |> B.field "Tag" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchTags : B.Request B.Query (List Info)
fetchTags =
    fetchInfo "allTags"


fetchTopic : Id -> B.Request B.Query (Maybe Topic)
fetchTopic (Id id) =
    topic
        |> B.nullable
        |> B.field "Topic" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchTopics : B.Request B.Query (List Info)
fetchTopics =
    fetchInfo "allTopics"


fetchTransition : Id -> B.Request B.Query (Maybe Transition)
fetchTransition (Id id) =
    transition
        |> B.nullable
        |> B.field "Transition" [ ( "id", Arg.string id ) ]
        |> B.extract
        |> B.queryDocument
        |> B.request ()


fetchTransitions : B.Request B.Query (List Transition)
fetchTransitions =
    B.list transition
        |> B.field "allTransitions" []
        |> B.extract
        |> B.queryDocument
        |> B.request ()



-- CREATE


createPosition : String -> List String -> B.Request B.Mutation Position
createPosition name notes =
    position
        |> B.field "createPosition"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string <| notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createSubmission : String -> Id -> List String -> List String -> B.Request B.Mutation Submission
createSubmission name (Id startId) steps notes =
    submission
        |> B.field "createSubmission"
            [ ( "name", Arg.string name )
            , ( "positionId", Arg.string startId )
            , ( "notes", Arg.list <| List.map Arg.string notes )
            , ( "steps", Arg.list <| List.map Arg.string steps )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createTag : String -> B.Request B.Mutation Tag
createTag name =
    tag
        |> B.field "createTag"
            [ ( "name", Arg.string name )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createTopic : String -> List String -> B.Request B.Mutation Topic
createTopic name notes =
    topic
        |> B.field "createTopic"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


createTransition : String -> Id -> Id -> List String -> List String -> B.Request B.Mutation Transition
createTransition name (Id startId) (Id endId) steps notes =
    transition
        |> B.field "createTransition"
            [ ( "name", Arg.string name )
            , ( "startPositionId", Arg.string startId )
            , ( "endPositionId", Arg.string endId )
            , ( "steps", Arg.list <| List.map Arg.string steps )
            , ( "notes", Arg.list <| List.map Arg.string notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()



-- UPDATE


updatePosition : Id -> String -> List String -> B.Request B.Mutation Position
updatePosition (Id id) name notes =
    position
        |> B.field "updatePosition"
            [ ( "id", Arg.string id )
            , ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


updateSubmission : Id -> String -> Id -> List String -> List String -> List Info -> B.Request B.Mutation Submission
updateSubmission (Id id) name (Id positionId) steps notes tags =
    submission
        |> B.field "updateSubmission"
            [ ( "id", Arg.string id )
            , ( "name", Arg.string name )
            , ( "positionId", Arg.string positionId )
            , ( "steps", Arg.list <| List.map Arg.string steps )
            , ( "notes", Arg.list <| List.map Arg.string notes )
            , ( "tagsIds"
              , Arg.list <|
                    List.map
                        (.id
                            >> (\(Id x) ->
                                    x
                               )
                            >> Arg.string
                        )
                        tags
              )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


updateTag : Id -> String -> B.Request B.Mutation Tag
updateTag (Id id) name =
    tag
        |> B.field "updateTag"
            [ ( "id", Arg.string id )
            , ( "name", Arg.string name )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


updateTopic : Id -> String -> List String -> B.Request B.Mutation Topic
updateTopic (Id id) name notes =
    topic
        |> B.field "updateTopic"
            [ ( "id", Arg.string id )
            , ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string notes )
            ]
        |> B.extract
        |> B.mutationDocument
        |> B.request ()


updateTransition : Id -> String -> Id -> Id -> List String -> List String -> B.Request B.Mutation Transition
updateTransition (Id id) name (Id startId) (Id endId) steps notes =
    transition
        |> B.field "updateTransition"
            [ ( "id", Arg.string id )
            , ( "name", Arg.string name )
            , ( "startPositionId", Arg.string startId )
            , ( "endPositionId", Arg.string endId )
            , ( "steps", Arg.list <| List.map Arg.string steps )
            , ( "notes", Arg.list <| List.map Arg.string notes )
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


deleteTag : Id -> B.Request B.Mutation Id
deleteTag (Id id) =
    B.id
        |> B.map Id
        |> B.field "id" []
        |> B.extract
        |> B.field "deleteTag"
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


position : B.ValueSpec B.NonNull B.ObjectType Position vars
position =
    B.object Position
        |> B.with (B.field "id" [] (B.id |> B.map Id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "submissions" [] (B.list info))
        |> B.with (B.field "transitionsFrom" [] (B.list transition))
        |> B.with (B.field "transitionsTo" [] (B.list transition))


submission : B.ValueSpec B.NonNull B.ObjectType Submission vars
submission =
    B.object Submission
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "steps" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "position" [] info)
        |> B.with (B.field "tags" [] (B.list info))


tag : B.ValueSpec B.NonNull B.ObjectType Tag vars
tag =
    B.object Tag
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "submissions" [] (B.list info))
        |> B.with (B.field "transitions" [] (B.list info))


topic : B.ValueSpec B.NonNull B.ObjectType Topic vars
topic =
    B.object Topic
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))


transition : B.ValueSpec B.NonNull B.ObjectType Transition vars
transition =
    B.object Transition
        |> B.with (B.field "id" [] (B.map Id B.id))
        |> B.with (B.field "name" [] B.string)
        |> B.with (B.field "startPosition" [] info)
        |> B.with (B.field "endPosition" [] info)
        |> B.with (B.field "notes" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "steps" [] (B.list B.string |> B.map Array.fromList))
        |> B.with (B.field "tags" [] (B.list info))
