module Utils exposing (..)

import Array
import Dict exposing (Dict)
import Element exposing (Attribute, Element, el, empty)
import Element.Attributes exposing (class)
import Types exposing (Device(Desktop), FaIcon(..), Form, Id(..), Model, Picker(..), View(..))


icon : FaIcon -> s -> List (Attribute vs msg) -> Element s vs msg
icon fa s attrs =
    let
        faClass =
            (case fa of
                Flag ->
                    "fa-flag-checkered"

                Arrow ->
                    "fa-long-arrow-right"

                Bolt ->
                    "fa-bolt"

                Lock ->
                    "fa-lock"

                Book ->
                    "fa-book"

                Plus ->
                    "fa-plus"

                Globe ->
                    "fa-globe"

                Minus ->
                    "fa-minus"

                Notes ->
                    "fa-sticky-note-o"

                Cross ->
                    "fa-times"

                Tick ->
                    "fa-check"

                Question ->
                    "fa-question"

                Trash ->
                    "fa-trash"

                Write ->
                    "fa-edit"

                Cogs ->
                    "fa-cogs"
            )
                |> (++) "fa "
                |> class
    in
    el s (faClass :: attrs) empty


sort : List { r | name : String } -> List { r | name : String }
sort =
    List.sortBy (.name >> String.toLower)


notEditing : View -> Bool
notEditing view =
    case view of
        ViewPosition True _ ->
            False

        ViewSubmission True _ ->
            False

        ViewTopic True _ ->
            False

        ViewTransition True _ ->
            False

        _ ->
            True


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
    , form = emptyForm
    }


emptyForm : Form
emptyForm =
    { name = ""
    , startPosition = Pending
    , endPosition = Pending
    , steps = Array.empty
    , notes = Array.empty
    }
