port module Ports exposing (..)


port saveToken : String -> Cmd msg


port clearToken : () -> Cmd msg


port log : String -> Cmd msg
