module Main exposing (main)

import Data exposing (query)
import Navigation exposing (Location)
import Paths
import Task
import Types exposing (Model, Msg(..))
import Update exposing (update)
import Utils exposing (emptyModel, goTo)
import View exposing (view)
import Window


main : Program (Maybe String) Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , subscriptions = always <| Window.resizes WindowSize
        , update = update
        , view = view
        }


init : Maybe String -> Location -> ( Model, Cmd Msg )
init maybeToken location =
    case maybeToken of
        Just token ->
            ( emptyModel
            , Cmd.batch
                [ Data.currentUser
                    |> query token
                    |> Task.attempt (AppInit token location)
                , Task.perform WindowSize Window.size
                ]
            )

        Nothing ->
            ( emptyModel
            , Cmd.batch
                [ Task.perform WindowSize Window.size
                , goTo Paths.login
                ]
            )
