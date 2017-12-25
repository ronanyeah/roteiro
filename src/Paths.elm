module Paths exposing (..)

import Types exposing (Id(Id))


position : Id -> String
position (Id id) =
    positions ++ "/" ++ id


submission : Id -> String
submission (Id id) =
    submissions ++ "/" ++ id


topic : Id -> String
topic (Id id) =
    topics ++ "/" ++ id


transition : Id -> String
transition (Id id) =
    transitions ++ "/" ++ id


positions : String
positions =
    "/#/positions"


submissions : String
submissions =
    "/#/submissions"


topics : String
topics =
    "/#/topics"


transitions : String
transitions =
    "/#/transitions"


start : String
start =
    "/#/start"
