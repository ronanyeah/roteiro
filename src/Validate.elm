module Validate exposing (..)

import Types exposing (Form, Id(..), Info, Picker(..), Position, Submission, Topic, Transition)


submission : Id -> Form -> Result (List String) Submission
submission id { startPosition, steps, name, notes } =
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


transition : Id -> Form -> Result (List String) Transition
transition id { startPosition, endPosition, steps, name, notes } =
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


topic : Id -> Form -> Result (List String) Topic
topic id { name, notes } =
    Ok
        { id = id
        , name = name
        , notes = notes
        }


position : Id -> Form -> Result (List String) Position
position id { name, notes } =
    Ok
        { id = id
        , name = name
        , notes = notes
        , submissions = []
        , transitions = []
        }
