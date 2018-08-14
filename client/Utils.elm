module Utils exposing (..)

import Api.Scalar exposing (Id(..))
import Array exposing (Array)
import Dict exposing (Dict)
import Element exposing (Attribute, Element, el, html, none)
import Element.Input as Input exposing (Label)
import Graphqelm.Http
import Html
import Html.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import Navigation
import Ports
import Regex exposing (Regex)
import RemoteData
import Types exposing (AppView(..), Auth, Device(Desktop, Mobile), FaIcon(..), Form, Model, Route(..), View(..))
import Window


authDecoder : Decoder Auth
authDecoder =
    Decode.map3 Auth
        (Decode.field "id" (Decode.map Id Decode.string))
        (Decode.field "email" Decode.string)
        (Decode.field "token" (Decode.map Types.Token Decode.string))


listRemove : Int -> List a -> List a
listRemove i xs =
    List.take i xs ++ List.drop (i + 1) xs


arrayRemove : Int -> Array a -> Array a
arrayRemove i =
    Array.toList
        >> listRemove i
        >> Array.fromList


goTo : Route -> Cmd msg
goTo route =
    (case route of
        CreatePositionRoute ->
            "/positions/new"

        CreateSubmissionRoute ->
            "/submissions/new"

        CreateTagRoute ->
            "/tags/new"

        CreateTopicRoute ->
            "/topics/new"

        CreateTransitionRoute ->
            "/transitions/new"

        EditPositionRoute (Id id) ->
            "/positions/" ++ id ++ "/edit"

        EditSubmissionRoute (Id id) ->
            "/submissions/" ++ id ++ "/edit"

        EditTransitionRoute (Id id) ->
            "/transitions/" ++ id ++ "/edit"

        EditTagRoute (Id id) ->
            "/tags/" ++ id ++ "/edit"

        EditTopicRoute (Id id) ->
            "/topics/" ++ id ++ "/edit"

        NotFound ->
            "/start"

        PositionRoute (Id id) ->
            "/positions/" ++ id

        Positions ->
            "/positions"

        SubmissionRoute (Id id) ->
            "/submissions/" ++ id

        Submissions ->
            "/submissions"

        Login ->
            "/login"

        SettingsRoute ->
            "/settings"

        SignUp ->
            "/sign-up"

        Start ->
            "/start"

        TagRoute (Id id) ->
            "/tags/" ++ id

        TagsRoute ->
            "/tags"

        TopicRoute (Id id) ->
            "/topics/" ++ id

        Topics ->
            "/topics"

        TransitionRoute (Id id) ->
            "/transitions/" ++ id

        Transitions ->
            "/transitions"
    )
        |> (++) "/app"
        |> Navigation.newUrl


isJust : Maybe a -> Bool
isJust =
    unwrap False <| always True


noLabel : Label msg
noLabel =
    Input.labelAbove [] none


when : Bool -> Element msg -> Element msg
when b elem =
    if b then
        elem
    else
        none


whenJust : (a -> Element msg) -> Maybe a -> Element msg
whenJust =
    unwrap none


classifyDevice : Window.Size -> Device
classifyDevice { width } =
    if width <= 600 then
        Mobile
    else
        Desktop


formatErrors : Graphqelm.Http.Error a -> List String
formatErrors err =
    case err of
        Graphqelm.Http.HttpError e ->
            case e of
                Http.BadStatus { status } ->
                    [ "Http Code: " ++ toString status.code
                    , "Message: " ++ status.message
                    ]

                Http.BadPayload _ _ ->
                    [ "Bad Payload" ]

                Http.BadUrl _ ->
                    [ "Bad Url" ]

                Http.NetworkError ->
                    [ "Network Error" ]

                Http.Timeout ->
                    [ "Timeout" ]

        Graphqelm.Http.GraphqlError _ errs ->
            errs
                |> List.map .message


addErrors : List String -> Form -> Form
addErrors errs f =
    { f | errors = Just errs }


clearErrors : Form -> Form
clearErrors f =
    { f | errors = Nothing }


isPositionView : AppView -> Bool
isPositionView view =
    case view of
        ViewPositions ->
            True

        ViewPosition _ ->
            True

        ViewCreatePosition ->
            True

        ViewEditPosition _ ->
            True

        _ ->
            False


isSubmissionView : AppView -> Bool
isSubmissionView view =
    case view of
        ViewSubmissions _ ->
            True

        ViewSubmission _ ->
            True

        ViewCreateSubmission ->
            True

        ViewEditSubmission _ ->
            True

        _ ->
            False


isTagView : AppView -> Bool
isTagView view =
    case view of
        ViewTags ->
            True

        ViewTag _ ->
            True

        ViewCreateTag ->
            True

        ViewEditTag _ ->
            True

        _ ->
            False


isTopicView : AppView -> Bool
isTopicView view =
    case view of
        ViewTopics _ ->
            True

        ViewTopic _ ->
            True

        ViewCreateTopic ->
            True

        ViewEditTopic _ ->
            True

        _ ->
            False


isTransitionView : AppView -> Bool
isTransitionView view =
    case view of
        ViewTransitions _ ->
            True

        ViewTransition _ ->
            True

        ViewCreateTransition ->
            True

        ViewEditTransition _ ->
            True

        _ ->
            False


icon : FaIcon -> List (Attribute msg) -> Element msg
icon fa attrs =
    let
        faClass =
            (case fa of
                Flag ->
                    "fa-flag-checkered"

                Arrow ->
                    "fa-long-arrow-alt-right"

                ArrowDown ->
                    "fa-long-arrow-alt-down"

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

                Email ->
                    "fa-at"

                SignIn ->
                    "fa-sign-in-alt"

                SignOut ->
                    "fa-sign-out-alt"

                Home ->
                    "fa-home"

                Minus ->
                    "fa-minus"

                Notes ->
                    "fa-sticky-note"

                NewUser ->
                    "fa-user-plus"

                Cross ->
                    "fa-times"

                Waiting ->
                    "fa-circle-notch"

                Warning ->
                    "fa-exclamation"

                Tags ->
                    "fa-tags"

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
                |> (++) "fas fa-fw "
                |> Html.Attributes.class
    in
    el attrs <| html <| Html.span [ faClass ] []


sort : List { r | name : String } -> List { r | name : String }
sort =
    List.sortBy (.name >> String.toLower)


notEditing : AppView -> Bool
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

        ViewEditPosition _ ->
            False

        ViewEditSubmission _ ->
            False

        ViewEditTopic _ ->
            False

        ViewEditTransition _ ->
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
log =
    toString >> Ports.log


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
    { view = ViewLogin
    , apiUrl = Types.Url ""
    , auth = Nothing
    , previousRoute = Nothing
    , positions = RemoteData.NotAsked
    , tags = RemoteData.NotAsked
    , device = Desktop
    , size = Window.Size 0 0
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
    , errors = Just []
    , startPosition = Nothing
    , endPosition = Nothing
    , steps = Array.empty
    , notes = Array.empty
    , tags = Array.empty
    , email = ""
    , password = ""
    , confirmPassword = ""
    }


matchLink : Regex
matchLink =
    Regex.regex
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$"


matchDomain : Regex
matchDomain =
    Regex.regex
        "(?:[-a-zA-Z0-9@:%_\\+~.#=]{2,256}\\.)?([-a-zA-Z0-9@:%_\\+~#=]*)\\.[a-z]{2,6}\\b(?:[-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)"