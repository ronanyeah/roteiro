module Validate exposing (..)

import Array
import Types exposing (Form, Id(..), Info, Picker(..), Position, Submission, Topic, Transition)
import Utils exposing (filterEmpty)


createPosition : Form -> Result (List String) ( String, List String )
createPosition { name, notes } =
    if String.isEmpty name then
        Err [ "Name field is empty." ]
    else
        Ok ( name, notes |> Array.toList |> filterEmpty )


updatePosition : Form -> Result (List String) Position
updatePosition { id, name, notes } =
    Ok
        { id = id
        , name = name
        , notes = notes
        , submissions = []
        , transitions = []
        }


submission : Form -> Result (List String) Submission
submission { id, startPosition, steps, name, notes } =
    case startPosition of
        Picked p ->
            Ok
                { id = id
                , position = Info p.id p.name
                , steps = steps
                , notes = notes
                , name = name
                }

        _ ->
            Err []


transition : Form -> Result (List String) Transition
transition { id, startPosition, endPosition, steps, name, notes } =
    case ( startPosition, endPosition ) of
        ( Picked start, Picked end ) ->
            Ok
                { id = id
                , startPosition = Info start.id start.name
                , endPosition = Info end.id end.name
                , steps = steps
                , notes = notes
                , name = name
                }

        _ ->
            Err []


topic : Form -> Result (List String) Topic
topic { id, name, notes } =
    Ok
        { id = id
        , name = name
        , notes = notes
        }
