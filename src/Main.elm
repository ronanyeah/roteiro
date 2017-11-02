module Main exposing (main)

import Array
import Data exposing (fetchData)
import Dict
import GraphQL.Client.Http exposing (sendQuery)
import Html
import Task
import Types exposing (..)
import Update exposing (update)
import View exposing (view)


main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


init : String -> ( Model, Cmd Msg )
init url =
    ( { view = ViewAll
      , positions = Dict.empty
      , transitions = Dict.empty
      , submissions = Dict.empty
      , topics = Array.empty
      , url = url
      }
    , Task.attempt CbData <| sendQuery url fetchData
    )
