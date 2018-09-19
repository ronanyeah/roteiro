module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation exposing (Key)
import Json.Decode
import Router exposing (router)
import Types exposing (ApiUrl(..), Flags, Model, Msg(..))
import Update exposing (update)
import Url exposing (Url)
import Utils exposing (authDecoder, emptyModel, goTo, unwrap)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = always <| Browser.Events.onResize WindowSize
        , update = update
        , view = view
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init { maybeAuth, size, apiUrl } url key =
    let
        startModel =
            emptyModel key
                |> (\m ->
                        { m
                            | device = size |> Utils.classifyDevice
                            , size = size
                            , apiUrl = ApiUrl apiUrl
                        }
                   )
    in
    maybeAuth
        |> Maybe.andThen
            (Json.Decode.decodeString authDecoder >> Result.toMaybe)
        |> unwrap
            ( startModel
            , (case router url of
                Types.SignUp ->
                    Types.SignUp

                _ ->
                    Types.Login
              )
                |> goTo key
            )
            (\auth ->
                update (UrlChange url)
                    { startModel | auth = Just auth }
            )
