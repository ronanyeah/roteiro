module Validate exposing (..)

import Array
import Types exposing (Form, Id(..))
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


submission : Form -> Result (List String) ( String, Id, List String, List String )
submission { name, startPosition, steps, notes } =
    case ( name, startPosition ) of
        ( "", Nothing ) ->
            Err [ emptyNameField, startPositionMissing ]

        ( "", Just _ ) ->
            Err [ emptyNameField ]

        ( _, Nothing ) ->
            Err [ startPositionMissing ]

        ( str, Just { id } ) ->
            Ok
                ( str
                , id
                , steps |> Array.toList |> filterEmpty
                , notes |> Array.toList |> filterEmpty
                )


topic : Form -> Result (List String) ( String, List String )
topic { name, notes } =
    if String.isEmpty name then
        Err [ emptyNameField ]
    else
        Ok ( name, notes |> Array.toList |> filterEmpty )


transition : Form -> Result (List String) ( String, Id, Id, List String, List String )
transition { name, startPosition, endPosition, steps, notes } =
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
