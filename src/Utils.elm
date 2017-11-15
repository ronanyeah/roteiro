module Utils exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Types exposing (Id(..), Device(Desktop), Form, Model, View(..))


singleton : a -> Array a
singleton =
    List.singleton >> Array.fromList


set : { r | id : Id } -> Dict String { r | id : Id } -> Dict String { r | id : Id }
set ({ id } as r) =
    let
        (Id idStr) =
            id
    in
        Dict.insert idStr r


get : Id -> Dict String { r | id : Id } -> Maybe { r | id : Id }
get (Id id) =
    Dict.get id


unwrap : b -> (a -> b) -> Maybe a -> b
unwrap default fn =
    Maybe.map fn
        >> Maybe.withDefault default


unwrap2 : c -> Maybe a -> Maybe b -> (a -> b -> c) -> c
unwrap2 c maybeA maybeB fn =
    Maybe.map2 fn maybeA maybeB
        |> Maybe.withDefault c


log : a -> Cmd msg
log a =
    let
        _ =
            Debug.log "Log" a
    in
        Cmd.none


listToDict : List { r | id : Id } -> Dict String { r | id : Id }
listToDict =
    List.foldl
        (\r ->
            let
                (Id id) =
                    r.id
            in
                Dict.insert id r
        )
        Dict.empty


filterEmpty : List String -> List String
filterEmpty =
    List.filter (String.isEmpty >> not)


emptyModel : Model
emptyModel =
    { view = ViewAll
    , positions = Dict.empty
    , transitions = Dict.empty
    , submissions = Dict.empty
    , topics = Dict.empty
    , url = ""
    , token = ""
    , choosingPosition = Nothing
    , device = Desktop
    , tokenForm = Nothing
    }


emptyForm : Form
emptyForm =
    { name = ""
    , startPosition = Nothing
    , endPosition = Nothing
    , steps = Array.empty
    , notes = Array.empty
    }
