module Main exposing (main)

import Navigation exposing (Location)
import Router exposing (parseLocation, router)
import Task
import Types exposing (..)
import Update exposing (update)
import Utils exposing (appendCmd, emptyModel)
import View exposing (view)
import Window


main : Program ( String, String ) Model Msg
main =
    Navigation.programWithFlags (parseLocation >> SetRoute)
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


init : ( String, String ) -> Location -> ( Model, Cmd Msg )
init ( url, token ) =
    parseLocation
        >> router { emptyModel | url = url, token = token }
        >> appendCmd (Task.perform WindowSize Window.size)
