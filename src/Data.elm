module Data exposing (..)

import Array exposing (Array)
import GraphQL.Request.Builder as GQLB
import GraphQL.Request.Builder.Arg as Arg
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


createPosition : FormCreatePosition -> GQLB.Request GQLB.Mutation Position
createPosition { name, notes } =
    position
        |> GQLB.field "createPosition"
            [ ( "name", Arg.string name )
            , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string notes )
            ]
        |> GQLB.extract
        |> GQLB.mutationDocument
        |> GQLB.request ()


createTransition : FormCreateTransition -> GQLB.Request GQLB.Mutation Transition
createTransition { name, steps, notes, startPosition, endPosition } =
    let
        (Id startId) =
            startPosition.id

        (Id endId) =
            case endPosition of
                Picked a ->
                    a.id

                Waiting ->
                    Id ""

                Picking ->
                    Id ""
    in
        transition
            |> GQLB.field "createTransition"
                [ ( "name", Arg.string name )
                , ( "startPositionId", Arg.string startId )
                , ( "endPositionId", Arg.string endId )
                , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string notes )
                , ( "steps", Arg.list <| Array.toList <| Array.map Arg.string steps )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()


updateTransition : Transition -> GQLB.Request GQLB.Mutation Transition
updateTransition t =
    let
        (Id id) =
            t.id
    in
        transition
            |> GQLB.field "updateTransition"
                [ ( "id", Arg.string id )
                , ( "name", Arg.string t.name )
                , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string t.notes )
                , ( "steps", Arg.list <| Array.toList <| Array.map Arg.string t.steps )
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
                , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string p.notes )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()


topic : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Topic vars
topic =
    GQLB.object Topic
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "content" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))


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
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string))
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string))
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
