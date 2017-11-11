module Data exposing (..)

import Array
import GraphQL.Request.Builder as GQLB
import GraphQL.Request.Builder.Arg as Arg
import Utils exposing (filterEmpty)
import Types exposing (..)


fetchData : GQLB.Request GQLB.Query AllData
fetchData =
    GQLB.object AllData
        |> GQLB.with (GQLB.field "allTransitions" [] (GQLB.list transition))
        |> GQLB.with (GQLB.field "allPositions" [] (GQLB.list position))
        |> GQLB.with (GQLB.field "allSubmissions" [] (GQLB.list submission))
        |> GQLB.with (GQLB.field "allTopics" [] (GQLB.list topic))
        |> GQLB.queryDocument
        |> GQLB.request ()



-- CREATE


createPosition : Form -> GQLB.Request GQLB.Mutation Position
createPosition { name, notes } =
    position
        |> GQLB.field "createPosition"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
            ]
        |> GQLB.extract
        |> GQLB.mutationDocument
        |> GQLB.request ()


createTopic : String -> List String -> GQLB.Request GQLB.Mutation Topic
createTopic name notes =
    topic
        |> GQLB.field "createTopic"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty notes )
            ]
        |> GQLB.extract
        |> GQLB.mutationDocument
        |> GQLB.request ()


createTransition : String -> List String -> List String -> Id -> Id -> GQLB.Request GQLB.Mutation Transition
createTransition name steps notes (Id startId) (Id endId) =
    transition
        |> GQLB.field "createTransition"
            [ ( "name", Arg.string name )
            , ( "startPositionId", Arg.string startId )
            , ( "endPositionId", Arg.string endId )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty notes )
            , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty steps )
            ]
        |> GQLB.extract
        |> GQLB.mutationDocument
        |> GQLB.request ()


createSubmission : String -> List String -> List String -> Id -> GQLB.Request GQLB.Mutation Submission
createSubmission name steps notes (Id startId) =
    submission
        |> GQLB.field "createSubmission"
            [ ( "name", Arg.string name )
            , ( "positionId", Arg.string startId )
            , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty notes )
            , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty steps )
            ]
        |> GQLB.extract
        |> GQLB.mutationDocument
        |> GQLB.request ()



-- UPDATE


updateTransition : Transition -> GQLB.Request GQLB.Mutation Transition
updateTransition t =
    case ( t.id, t.startPosition, t.endPosition ) of
        ( Id id, Id startId, Id endId ) ->
            transition
                |> GQLB.field "updateTransition"
                    [ ( "id", Arg.string id )
                    , ( "name", Arg.string t.name )
                    , ( "startPositionId", Arg.string startId )
                    , ( "endPositionId", Arg.string endId )
                    , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList t.notes )
                    , ( "steps", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList t.steps )
                    ]
                |> GQLB.extract
                |> GQLB.mutationDocument
                |> GQLB.request ()


updatePosition : Position -> GQLB.Request GQLB.Mutation Position
updatePosition p =
    let
        (Id id) =
            p.id
    in
        position
            |> GQLB.field "updatePosition"
                [ ( "id", Arg.string id )
                , ( "name", Arg.string p.name )
                , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList p.notes )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()


updateTopic : Topic -> GQLB.Request GQLB.Mutation Topic
updateTopic { id, name, notes } =
    let
        (Id idStr) =
            id
    in
        topic
            |> GQLB.field "updateTopic"
                [ ( "id", Arg.string idStr )
                , ( "name", Arg.string name )
                , ( "notes", Arg.list <| List.map Arg.string <| filterEmpty <| Array.toList notes )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()



-- SELECTIONS


topic : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Topic vars
topic =
    GQLB.object Topic
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))


position : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Position vars
position =
    GQLB.object Position
        |> GQLB.with (GQLB.field "id" [] (GQLB.id |> GQLB.map Id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))


submission : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Submission vars
submission =
    GQLB.object Submission
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))
        |> GQLB.with
            (GQLB.field "position"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )


transition : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Transition vars
transition =
    GQLB.object Transition
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with
            (GQLB.field "startPosition"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )
        |> GQLB.with
            (GQLB.field "endPosition"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))
