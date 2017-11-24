module Validate exposing (..)

import Types exposing (Id(..), Editor(..), Form, Submission)


submission : Id -> Form -> Result (List String) Submission
submission id { startPosition, steps, name, notes, when } =
    startPosition
        |> Maybe.map
            (\p ->
                { id = id
                , position = p.id
                , steps = steps
                , notes = notes
                , name = name
                , when = Just when
                }
            )
        |> Result.fromMaybe []
