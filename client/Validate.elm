module Validate exposing (emptyNameField, endPositionMissing, position, startPositionMissing, submission, tag, topic, transition)

import Api.Scalar exposing (Id(..))
import Array
import Types exposing (Form)
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


position : Form -> Result (List String) ( String, List String )
position { name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]

    else
        Ok ( name, notes |> Array.toList |> filterEmpty )


submission : Form -> Result (List String) ( ( String, Id, List String ), ( List String, List Id ) )
submission { name, startPosition, steps, notes, tags } =
    case ( name, startPosition ) of
        ( "", Nothing ) ->
            Err [ emptyNameField, startPositionMissing ]

        ( "", Just _ ) ->
            Err [ emptyNameField ]

        ( _, Nothing ) ->
            Err [ startPositionMissing ]

        ( str, Just { id } ) ->
            Ok
                ( ( str
                  , id
                  , steps |> Array.toList |> filterEmpty
                  )
                , ( notes |> Array.toList |> filterEmpty
                  , tags |> Array.toList |> List.map .id
                  )
                )


tag : Form -> Result (List String) String
tag { name } =
    if String.isEmpty name then
        Err [ emptyNameField ]

    else
        Ok name


topic : Form -> Result (List String) ( String, List String )
topic { name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]

    else
        Ok ( name, notes |> Array.toList |> filterEmpty )


transition : Form -> Result (List String) ( ( String, Id, Id ), ( List String, List String, List Id ) )
transition { name, startPosition, endPosition, tags, steps, notes } =
    [ if String.isEmpty name then
        Just emptyNameField

      else
        Nothing
    , case startPosition of
        Just _ ->
            Nothing

        Nothing ->
            Just startPositionMissing
    , case endPosition of
        Just _ ->
            Nothing

        Nothing ->
            Just endPositionMissing
    ]
        |> List.filterMap identity
        |> (\errs ->
                if List.isEmpty errs then
                    case ( startPosition, endPosition ) of
                        ( Just start, Just end ) ->
                            Ok
                                ( ( name
                                  , start.id
                                  , end.id
                                  )
                                , ( steps |> Array.toList |> filterEmpty
                                  , notes |> Array.toList |> filterEmpty
                                  , tags |> Array.toList |> List.map .id
                                  )
                                )

                        _ ->
                            Err [ "oops" ]

                else
                    Err errs
           )
