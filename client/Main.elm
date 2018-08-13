module Main exposing (main)

import Json.Decode
import Navigation exposing (Location)
import Router exposing (router)
import Types exposing (Flags, Model, Msg(..), Url(Url))
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
init { maybeAuth, size, apiUrl } location =
    let
        startModel =
            { emptyModel
                | device = size |> Utils.classifyDevice
                , size = size
                , apiUrl = Url apiUrl
            }
    in
    maybeAuth
        |> Maybe.andThen
            (Json.Decode.decodeString authDecoder >> Result.toMaybe)
        |> unwrap
            ( startModel
            , (case router location of
                Types.SignUp ->
                    Types.SignUp

                _ ->
                    Types.Login
              )
                |> goTo
            )
            (\auth ->
                update (UrlChange location)
                    { startModel | auth = Just auth }
            )
