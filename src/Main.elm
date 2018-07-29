module Main exposing (main)

import Json.Decode
import Navigation exposing (Location)
import Task
import Types exposing (Flags, Model, Msg(..))
import Update exposing (update)
import Utils exposing (appendCmd, authDecoder, emptyModel, goTo, unwrap)
import View exposing (view)
import Window


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , subscriptions = always <| Window.resizes WindowSize
        , update = update
        , view = view
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init { auth } location =
    auth
        |> Maybe.andThen
            (Json.Decode.decodeString authDecoder >> Result.toMaybe)
        |> unwrap
            ( emptyModel
            , Cmd.batch
                [ Task.perform WindowSize Window.size
                , goTo Types.Login
                ]
            )
            (\data ->
                update (UrlChange location) { emptyModel | auth = Just data }
                    |> appendCmd (Task.perform WindowSize Window.size)
            )
