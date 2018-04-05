module Main exposing (main)

import Json.Decode exposing (Value)
import Navigation exposing (Location)
import Ports
import Task
import Types exposing (Model, Msg(..))
import Update exposing (update)
import Utils exposing (appendCmd, authDecoder, emptyModel, goTo, log, unwrap)
import View exposing (view)
import Window


main : Program Value Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , subscriptions = always <| Window.resizes WindowSize
        , update = update
        , view = view
        }


init : Value -> Location -> ( Model, Cmd Msg )
init flags location =
    case
        flags
            |> Json.Decode.decodeValue
                (Json.Decode.field "auth" (Json.Decode.nullable authDecoder))
    of
        Ok maybeAuth ->
            maybeAuth
                |> unwrap
                    ( emptyModel
                    , Cmd.batch
                        [ Task.perform WindowSize Window.size
                        , goTo Types.Login
                        ]
                    )
                    (\auth ->
                        update (UrlChange location) { emptyModel | auth = Just auth }
                            |> appendCmd (Task.perform WindowSize Window.size)
                    )

        Err err ->
            ( emptyModel
            , Cmd.batch
                [ Task.perform WindowSize Window.size
                , goTo Types.Login
                , log err
                , Ports.clearAuth ()
                ]
            )
