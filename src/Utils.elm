module Utils exposing (..)

import Array
import Dict exposing (Dict)
import Element exposing (Attribute, Element, el, empty)
import Element.Attributes exposing (class)
import Regex exposing (Regex)
import RemoteData
import Types exposing (Device(Desktop), FaIcon(..), Form, GcData, Id(..), Model, Picker(..), View(..))
import Window


appendCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
appendCmd newCmd =
    Tuple.mapSecond
        (List.singleton >> (::) newCmd >> Cmd.batch)


isPicking : Picker a -> Bool
isPicking p =
    case p of
        Picking _ ->
            True

        Picked _ ->
            False

        Pending ->
            False


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

                Waiting ->
                    "fa-refresh"

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
        ViewCreatePosition ->
            False

        ViewCreateSubmission ->
            False

        ViewCreateTopic ->
            False

        ViewCreateTransition ->
            False

        ViewEditPosition ->
            False

        ViewEditSubmission ->
            False

        ViewEditTopic ->
            False

        ViewEditTransition ->
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


remoteUnwrap : a -> (b -> a) -> GcData b -> a
remoteUnwrap default fn =
    RemoteData.map fn
        >> RemoteData.withDefault default


unwrap : b -> (a -> b) -> Maybe a -> b
unwrap default fn =
    Maybe.map fn
        >> Maybe.withDefault default


logError : GcData a -> Cmd msg
logError data =
    case data of
        RemoteData.Failure err ->
            log err

        _ ->
            Cmd.none


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
            case r.id of
                Id idStr ->
                    Dict.insert idStr r
        )
        Dict.empty


filterEmpty : List String -> List String
filterEmpty =
    List.filter (String.isEmpty >> not)


emptyModel : Model
emptyModel =
    { view = ViewStart
    , previousView = ViewStart
    , positions = RemoteData.NotAsked
    , url = ""
    , token = ""
    , device = Desktop
    , size = Window.Size 0 0
    , tokenForm = Nothing
    , confirm = Nothing
    , form = emptyForm
    }


emptyForm : Form
emptyForm =
    { name = ""
    , id = Id ""
    , errors = []
    , startPosition = Pending
    , endPosition = Pending
    , steps = Array.empty
    , notes = Array.empty
    }


matchLink : Regex
matchLink =
    Regex.regex
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$"


matchDomain : Regex
matchDomain =
    Regex.regex
        "(?:[-a-zA-Z0-9@:%_\\+~.#=]{2,256}\\.)?([-a-zA-Z0-9@:%_\\+~#=]*)\\.[a-z]{2,6}\\b(?:[-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)"
