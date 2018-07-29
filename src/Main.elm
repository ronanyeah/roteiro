module Main exposing (main)

import Json.Decode
import Navigation exposing (Location)
import Types exposing (Flags, Model, Msg(..))
import Update exposing (update)
import Utils exposing (authDecoder, emptyModel, goTo, unwrap)
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
init { maybeAuth, size } location =
    let
        startModel =
            { emptyModel
                | device = size |> Utils.classifyDevice
                , size = size
            }
    in
    maybeAuth
        |> Maybe.andThen
            (Json.Decode.decodeString authDecoder >> Result.toMaybe)
        |> unwrap
            ( startModel
            , goTo Types.Login
            )
            (\auth ->
                update (UrlChange location)
                    { startModel | auth = Just auth }
            )
