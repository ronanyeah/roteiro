module Validate exposing (..)

import Array
import Types exposing (Form, Id(..), Info, Picker(..), Submission, Topic, Transition)
import Utils exposing (filterEmpty)


emptyNameField : String
emptyNameField =
    "Name field is empty."


endPositionMissing : String
endPositionMissing =
    "End position missing."


startPositionMissing : String
startPositionMissing =
    "Start position missing."


createPosition : Form -> Result (List String) ( String, List String )
createPosition { name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]
    else
        Ok ( name, notes |> Array.toList |> filterEmpty )


updatePosition : Form -> Result (List String) ( Id, String, List String )
updatePosition { id, name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]
    else
        Ok ( id, name, notes |> Array.toList |> filterEmpty )


createSubmission : Form -> Result (List String) ( String, Id, List String, List String )
createSubmission { name, startPosition, steps, notes } =
    case ( name, startPosition ) of
        ( "", Pending ) ->
            Err [ emptyNameField, startPositionMissing ]

        ( "", Picking _ ) ->
            Err [ emptyNameField, startPositionMissing ]

        ( "", Picked _ ) ->
            Err [ emptyNameField ]

        ( _, Pending ) ->
            Err [ startPositionMissing ]

        ( _, Picking _ ) ->
            Err [ startPositionMissing ]

        ( str, Picked { id } ) ->
            Ok
                ( str
                , id
                , steps |> Array.toList |> filterEmpty
                , notes |> Array.toList |> filterEmpty
                )


updateSubmission : Form -> Result (List String) ( Id, String, Id, List String, List String )
updateSubmission { id, name, startPosition, steps, notes } =
    case ( name, startPosition ) of
        ( "", Pending ) ->
            Err [ emptyNameField, startPositionMissing ]

        ( "", Picking _ ) ->
            Err [ emptyNameField, startPositionMissing ]

        ( "", Picked _ ) ->
            Err [ emptyNameField ]

        ( _, Pending ) ->
            Err [ startPositionMissing ]

        ( _, Picking _ ) ->
            Err [ startPositionMissing ]

        ( str, Picked position ) ->
            Ok
                ( id
                , str
                , position.id
                , steps |> Array.toList |> filterEmpty
                , notes |> Array.toList |> filterEmpty
                )


createTopic : Form -> Result (List String) ( String, List String )
createTopic { name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]
    else
        Ok ( name, notes |> Array.toList |> filterEmpty )


updateTopic : Form -> Result (List String) ( Id, String, List String )
updateTopic { id, name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]
    else
        Ok ( id, name, notes |> Array.toList |> filterEmpty )


createTransition : Form -> Result (List String) ( String, Id, Id, List String, List String )
createTransition { name, startPosition, endPosition, steps, notes } =
    [ if String.isEmpty name then
        Just emptyNameField
      else
        Nothing
    , case startPosition of
        Picked _ ->
            Nothing

        _ ->
            Just startPositionMissing
    , case endPosition of
        Picked _ ->
            Nothing

        _ ->
            Just endPositionMissing
    ]
        |> List.filterMap identity
        |> (\errs ->
                if List.isEmpty errs then
                    case ( startPosition, endPosition ) of
                        ( Picked start, Picked end ) ->
                            Ok
                                ( name
                                , start.id
                                , end.id
                                , steps |> Array.toList |> filterEmpty
                                , notes |> Array.toList |> filterEmpty
                                )

                        _ ->
                            Err [ "oops" ]
                else
                    Err errs
           )


updateTransition : Form -> Result (List String) ( Id, String, Id, Id, List String, List String )
updateTransition { id, name, startPosition, endPosition, steps, notes } =
    [ if String.isEmpty name then
        Just emptyNameField
      else
        Nothing
    , case startPosition of
        Picked _ ->
            Nothing

        _ ->
            Just startPositionMissing
    , case endPosition of
        Picked _ ->
            Nothing

        _ ->
            Just endPositionMissing
    ]
        |> List.filterMap identity
        |> (\errs ->
                if List.isEmpty errs then
                    case ( startPosition, endPosition ) of
                        ( Picked start, Picked end ) ->
                            Ok
                                ( id
                                , name
                                , start.id
                                , end.id
                                , steps |> Array.toList |> filterEmpty
                                , notes |> Array.toList |> filterEmpty
                                )

                        _ ->
                            Err [ "oops" ]
                else
                    Err errs
           )
