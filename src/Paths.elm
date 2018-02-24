module Paths exposing (..)

import Types exposing (Id(Id))


position : Id -> String
position (Id id) =
    positions ++ "/" ++ id


submission : Id -> String
submission (Id id) =
    submissions ++ "/" ++ id


tag : Id -> String
tag (Id id) =
    tags ++ "/" ++ id


topic : Id -> String
topic (Id id) =
    topics ++ "/" ++ id


transition : Id -> String
transition (Id id) =
    transitions ++ "/" ++ id


positions : String
positions =
    "positions"


submissions : String
submissions =
    "submissions"


tags : String
tags =
    "tags"


topics : String
topics =
    "topics"


transitions : String
transitions =
    "transitions"


start : String
start =
    "start"
