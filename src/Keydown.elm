module Keydown exposing (..)

import Element exposing (Attribute, htmlAttribute)
import Html
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)


matchKey : String -> msg -> Decoder msg
matchKey keyToMatch msg =
    key
        |> Decode.andThen
            (\currentKey ->
                if currentKey == keyToMatch then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


key : Decoder String
key =
    Decode.field "key" Decode.string


onKeydown : List (Decoder msg) -> Attribute msg
onKeydown decoders =
    Decode.value
        |> Decode.andThen
            (\val ->
                let
                    matchKeydown ds =
                        case ds of
                            decoder :: tail ->
                                val
                                    |> Decode.decodeValue decoder
                                    |> Result.map Decode.succeed
                                    |> Result.withDefault (matchKeydown tail)

                            [] ->
                                Decode.fail ""
                in
                matchKeydown decoders
            )
        |> on "keydown"
        |> htmlAttribute


onEnter : msg -> Decoder msg
onEnter =
    matchKey "Enter"
