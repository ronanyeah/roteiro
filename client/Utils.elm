module Utils exposing (addErrors, arrayRemove, authDecoder, classifyDevice, clearErrors, del, emptyForm, emptyModel, filterEmpty, formatErrors, get, goTo, icon, isJust, isPositionView, isSubmissionView, isTagView, isTopicView, isTransitionView, listRemove, listToDict, log, matchDomain, matchLink, noLabel, notEditing, set, setWaiting, sort, unwrap, when, whenJust)

import Api.Scalar exposing (Id(..))
import Array exposing (Array)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Element exposing (Attribute, Element, el, html, none)
import Element.Input as Input exposing (Label)
import FeatherIcons as F
import Graphql.Http
import Html
import Html.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import List.Nonempty as Ne
import Ports
import Regex exposing (Regex)
import RemoteData
import Types exposing (AppView(..), Auth, Device(..), Icon(..), Form, Model, Route(..), Size, Status(..), View(..))
import Url.Builder exposing (absolute)


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


goTo : Key -> Route -> Cmd msg
goTo key route =
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
        |> Browser.Navigation.pushUrl key


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


classifyDevice : Size -> Device
classifyDevice { width } =
    if width <= 600 then
        Mobile

    else
        Desktop


formatErrors : Graphql.Http.Error a -> List String
formatErrors err =
    case err of
        Graphql.Http.HttpError e ->
            case e of
                Http.BadStatus { status } ->
                    [ "Http Code: " ++ String.fromInt status.code
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

        Graphql.Http.GraphqlError _ errs ->
            errs
                |> List.map .message


addErrors : List String -> Form -> Form
addErrors errs f =
    { f | status = errs |> Ne.fromList |> unwrap Ready Errors }


clearErrors : Form -> Form
clearErrors f =
    { f | status = Ready }


setWaiting : Form -> Form
setWaiting f =
    { f | status = Waiting }


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
        ViewSubmissions ->
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
        ViewTopics ->
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
        ViewTransitions ->
            True

        ViewTransition _ ->
            True

        ViewCreateTransition ->
            True

        ViewEditTransition _ ->
            True

        _ ->
            False


icon : Icon -> List (Attribute msg) -> Element msg
icon i attrs =
    let
        markup =
            (case i of
                Flag ->
                    F.flag

                Arrow ->
                    F.arrowRight

                ArrowDown ->
                    F.arrowDown

                Bolt ->
                    F.zap

                Lock ->
                    F.lock

                Book ->
                    F.book

                Plus ->
                    F.plus

                Globe ->
                    F.globe

                Email ->
                    F.atSign

                SignIn ->
                    F.logIn

                SignOut ->
                    F.logOut

                Home ->
                    F.home

                Minus ->
                    F.minus

                Notes ->
                    F.archive

                NewUser ->
                    F.userPlus

                Cross ->
                    F.x

                Spinner ->
                    F.loader

                Warning ->
                    F.alertCircle

                Tags ->
                    F.tag

                Tick ->
                    F.check

                Question ->
                    F.helpCircle

                Trash ->
                    F.trash2

                Write ->
                    F.edit

                Cogs ->
                    F.settings

                Bars ->
                    F.menu
            )
                |> F.toHtml []
    in
    el attrs <| html markup


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
    Debug.toString >> Ports.log


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


emptyModel : Key -> Model
emptyModel key =
    { view = ViewLogin
    , apiUrl = Types.ApiUrl ""
    , auth = Nothing
    , previousRoute = Nothing
    , positions = RemoteData.NotAsked
    , submissions = RemoteData.NotAsked
    , tags = RemoteData.NotAsked
    , transitions = RemoteData.NotAsked
    , topics = RemoteData.NotAsked
    , device = Desktop
    , size = Size 0 0
    , confirm = Nothing
    , form = emptyForm
    , sidebarOpen = False
    , selectingStartPosition = False
    , selectingEndPosition = False
    , key = key
    }


emptyForm : Form
emptyForm =
    { name = ""
    , id = Id ""
    , status = Ready
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
    Regex.fromString
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$"
        |> Maybe.withDefault Regex.never


matchDomain : Regex
matchDomain =
    Regex.fromString
        "(?:[-a-zA-Z0-9@:%_\\+~.#=]{2,256}\\.)?([-a-zA-Z0-9@:%_\\+~#=]*)\\.[a-z]{2,6}\\b(?:[-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)"
        |> Maybe.withDefault Regex.never
