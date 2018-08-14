port module Ports exposing (..)


port saveAuth : String -> Cmd msg


port clearAuth : () -> Cmd msg


port log : String -> Cmd msg
