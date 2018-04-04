port module Ports exposing (..)

import Json.Decode exposing (Value)


port saveAuth : Value -> Cmd msg


port clearAuth : () -> Cmd msg


port log : String -> Cmd msg
