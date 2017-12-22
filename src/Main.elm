module Main exposing (main)

import Data exposing (fetchData, query)
import Navigation exposing (Location)
import Router exposing (parseLocation, router)
import Task
import Types exposing (..)
import Update exposing (update)
import Utils exposing (emptyModel)
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
init ( url, token ) location =
    let
        ( model, cmd ) =
            location
                |> parseLocation
                |> router { emptyModel | url = url, token = token }
    in
    ( model
    , Cmd.batch
        [ Task.perform WindowSize Window.size
        , fetchData |> query url token CbData
        , cmd
        ]
    )
