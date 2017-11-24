module Utils exposing (..)

import Array
import Dict exposing (Dict)
import Element.Input as Input
import Types exposing (Id(..), Device(Desktop), Editor(..), Form, Model, Msg(SelectStartPosition), Submission, View(..))


validateSubmission : Editor Submission -> Maybe Submission
validateSubmission e =
    case e of
        Editing { startPosition, steps, name, notes, when } { id } ->
            startPosition
                |> Maybe.map
                    (\p ->
                        { id = id
                        , position = p.id
                        , steps = steps
                        , notes = notes
                        , name = name
                        , when = Just when
                        }
                    )

        ReadOnly _ ->
            Nothing


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


del : Id -> Dict String { r | id : Id } -> Dict String { r | id : Id }
del (Id id) =
    Dict.remove id


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
    , device = Desktop
    , tokenForm = Nothing
    , confirm = Nothing
    }


emptyForm : Form
emptyForm =
    { name = ""
    , startTest = Input.autocomplete Nothing SelectStartPosition
    , startPosition = Nothing
    , endPosition = Nothing
    , steps = Array.empty
    , notes = Array.empty
    , when = ""
    }
