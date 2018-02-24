module Main exposing (main)

import Navigation exposing (Location)
import Task
import Types exposing (Model, Msg(UrlChange, WindowSize))
import Update exposing (update)
import Utils exposing (appendCmd, emptyModel)
import View exposing (view)
import Window


main : Program String Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , subscriptions = always <| Window.resizes WindowSize
        , update = update
        , view = view
        }


init : String -> Location -> ( Model, Cmd Msg )
init token =
    UrlChange
        >> flip update { emptyModel | token = token }
        >> appendCmd (Task.perform WindowSize Window.size)
