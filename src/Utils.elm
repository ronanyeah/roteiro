module Utils exposing (..)

import Array
import Dict exposing (Dict)
import Element exposing (Attribute, Element, el, empty, html)
import Element.Input as Input exposing (Label)
import Html
import Html.Attributes
import Regex exposing (Regex)
import RemoteData
import Task exposing (Task)
import Types exposing (ApiError(..), Device(Desktop, Mobile), FaIcon(..), Form, GcData, GcError(..), Id(..), Model, View(..))
import Window


noLabel : Label msg
noLabel =
    Input.labelAbove [] empty


when : Bool -> Element msg -> Element msg
when b elem =
    if b then
        elem
    else
        empty


whenJust : (a -> Element msg) -> Maybe a -> Element msg
whenJust =
    unwrap empty


classifyDevice : Window.Size -> Device
classifyDevice { width } =
    if width <= 600 then
        Mobile
    else
        Desktop


taskToGcData : (GcData a -> msg) -> Task GcError a -> Cmd msg
taskToGcData msg =
    RemoteData.asCmd
        >> Cmd.map msg


formatErrors : GcError -> List String
formatErrors err =
    case err of
        HttpError _ ->
            [ "Some HTTP bullshit." ]

        GcError errs ->
            errs
                |> List.map
                    (\e ->
                        case e of
                            InsufficientPermissions ->
                                "Not authorised."

                            RelationIsRequired ->
                                "Can't delete, other data depends on this."

                            Other str ->
                                str
                    )


addErrors : List String -> Form -> Form
addErrors errs f =
    { f | errors = errs }


clearErrors : Form -> Form
clearErrors f =
    { f | errors = [] }


appendCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
appendCmd newCmd =
    Tuple.mapSecond
        (List.singleton >> (::) newCmd >> Cmd.batch)


icon : FaIcon -> List (Attribute msg) -> Element msg
icon fa attrs =
    let
        faClass =
            (case fa of
                Flag ->
                    "fa-flag-checkered"

                Arrow ->
                    "fa-long-arrow-alt-right"

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

                Home ->
                    "fa-home"

                Minus ->
                    "fa-minus"

                Notes ->
                    "fa-sticky-note"

                Cross ->
                    "fa-times"

                Waiting ->
                    "fa-spinner fa-pulse"

                Warning ->
                    "fa-exclamation"

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

                Bars ->
                    "fa-bars"
            )
                |> (++) "fas "
                |> Html.Attributes.class
    in
    el attrs <| html <| Html.span [ faClass ] []


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
    , token = ""
    , device = Desktop
    , size = Window.Size 0 0
    , tokenForm = Nothing
    , confirm = Nothing
    , form = emptyForm
    , sidebarOpen = False
    , selectingStartPosition = False
    , selectingEndPosition = False
    }


emptyForm : Form
emptyForm =
    { name = ""
    , id = Id ""
    , errors = []
    , startPosition = Nothing
    , endPosition = Nothing
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
