module Main exposing (main)

import Data exposing (query)
import Json.Decode exposing (Value)
import Navigation exposing (Location)
import Task
import Types exposing (Model, Msg(..))
import Update exposing (update)
import Utils exposing (appendCmd, emptyModel, flagsDecoder, goTo, log)
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
            |> Json.Decode.decodeValue flagsDecoder
    of
        Ok { auth, isOnline } ->
            case ( auth, isOnline ) of
                ( Just auth, True ) ->
                    ( emptyModel
                    , Cmd.batch
                        [ Data.currentUser
                            |> query auth.token
                            |> Task.attempt (AppInit auth.token location)
                        , Task.perform WindowSize Window.size
                        ]
                    )

                ( Just auth, False ) ->
                    update (UrlChange location) { emptyModel | auth = Just auth }
                        |> appendCmd (Task.perform WindowSize Window.size)

                ( Nothing, _ ) ->
                    ( emptyModel
                    , Cmd.batch
                        [ Task.perform WindowSize Window.size
                        , goTo Types.Login
                        ]
                    )

        Err err ->
            ( emptyModel
            , Cmd.batch
                [ Task.perform WindowSize Window.size
                , goTo Types.Login
                , log err
                ]
            )
