module Main exposing (main)

import Data exposing (fetchData)
import Dict
import GraphQL.Client.Http exposing (sendQuery)
import Html
import Navigation exposing (Location)
import Router exposing (parseLocation, router)
import Task
import Types exposing (..)
import Update exposing (update)
import View exposing (view)
import Window


main : Program String Model Msg
main =
    Navigation.programWithFlags (parseLocation >> SetRoute)
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


init : String -> Location -> ( Model, Cmd Msg )
init url location =
    let
        ( model, cmd ) =
            location
                |> parseLocation
                |> router
                    { view = ViewAll
                    , positions = Dict.empty
                    , transitions = Dict.empty
                    , submissions = Dict.empty
                    , topics = Dict.empty
                    , url = url
                    , choosingPosition = Nothing
                    , device = Desktop
                    }
    in
        ( model
        , Cmd.batch
            [ Task.perform WindowSize Window.size
            , Task.attempt CbData <| sendQuery url fetchData
            , cmd
            ]
        )
