module Utils exposing (addErrors, arrayRemove, authDecoder, classifyDevice, clearErrors, del, emptyForm, emptyModel, filterEmpty, formatErrors, formatHttpError, get, goTo, icon, isJust, isPositionView, isSubmissionView, isTagView, isTopicView, isTransitionView, listRemove, listToDict, map, matchDomain, matchLink, noLabel, notEditing, set, setWaiting, sort, unwrap, when, whenJust)

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
import Svg
import Svg.Attributes as SA
import Types exposing (AppView(..), Auth, Device(..), Form, Icon(..), Model, Route(..), Size, Status(..), View(..))
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


formatHttpError : Http.Error -> List String
formatHttpError e =
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


formatErrors : Graphql.Http.Error a -> List String
formatErrors err =
    case err of
        Graphql.Http.HttpError e ->
            formatHttpError e

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

        ViewPosition ->
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
    , position = RemoteData.NotAsked
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


map : Element msg
map =
    Svg.svg
        [ SA.version "1.1", SA.viewBox "0 0 64 64", SA.enableBackground "new 0 0 64 64" ]
        [ Svg.g [ SA.transform "matrix(1 0 0 1 0 0)" ]
            [ Svg.g []
                [ Svg.g []
                    [ Svg.path
                        [ SA.d """
m63.976,
9.878c-0.009-0.069-0.018-0.135-0.041-0.201-0.02-0.059-0.049-0.111-0.079-0.164-0.033-0.059-0.067-0.114-0.112-0.166-0.041-0.047-0.088-0.084-0.138-0.122-0.036-0.029-0.061-0.067-0.102-0.091l-13.88-8.912c-0.024-0.019-0.049-0.031-0.074-0.048l-.063-.04c-0.01-0.006-0.021-0.005-0.031-0.011-0.041-0.021-0.08-0.041-0.124-0.056-0.052-0.018-0.104-0.03-0.158-0.039-0.039-0.008-0.077-0.014-0.117-0.016-0.02-0.002-0.037-0.012-0.057-0.012s-0.037,
0.01-0.057, 0.011c-0.04, 0.003-0.077, 0.009-0.117, 0.016-0.055, 0.009-0.106,
0.021-0.158, 0.039-0.044, 0.016-0.083, 0.035-0.124, 0.056-0.01, 0.005-0.021,
0.005-0.031, 0.011l-16.513,
8.734-16.513-8.733c-0.01-0.006-0.021-0.005-0.031-0.011-0.041-0.021-0.08-0.041-0.124-0.056-0.052-0.018-0.104-0.03-0.158-0.039-0.04-0.008-0.077-0.014-0.117-0.016-0.02-0.002-0.037-0.012-0.057-0.012s-0.037,
0.01-0.057, 0.011c-0.04, 0.003-0.077, 0.009-0.117, 0.016-0.055, 0.009-0.106,
0.021-0.158, 0.039-0.044, 0.016-0.083, 0.035-0.124, 0.056-0.01, 0.005-0.021,
0.005-0.031, 0.011l-.063, .04c-0.025, 0.016-0.05, 0.029-0.074, 0.047l-13.88,
8.914c-0.041, 0.024-0.066, 0.062-0.102, 0.091-0.05, 0.039-0.096, 0.075-0.137,
0.122-0.046, 0.052-0.079, 0.107-0.113, 0.166-0.03, 0.053-0.059, 0.105-0.079,
0.163-0.022, 0.067-0.032, 0.133-0.04, 0.202-0.006, 0.042-0.025, 0.079-0.025,
0.122v53c0, 0.021 0.011, 0.039 0.012, 0.06 0.004, 0.067 0.022, 0.13 0.039,
0.195 0.017, 0.065 0.033, 0.127 0.062, 0.186 0.009, 0.019 0.009, 0.04 0.02,
0.059 0.023, 0.04 0.06, 0.065 0.088, 0.101 0.039, 0.051 0.076, 0.099 0.124,
0.141 0.054, 0.048 0.112, 0.083 0.174, 0.118 0.049, 0.028 0.095, 0.054 0.149,
0.073 0.07, 0.025 0.141, 0.035 0.215, 0.043 0.04, 0.005 0.076, 0.024 0.117,
0.024 0.02, 0 0.037-0.01 0.057-0.011 0.058-0.004 0.113-0.02 0.171-0.034
0.08-0.019 0.157-0.04 0.228-0.077 0.01-0.005 0.021-0.005
0.031-0.011l13.562-8.708 16.464, 8.708c0.01, 0.006 0.021, 0.005 0.031, 0.011
0.041, 0.021 0.08, 0.041 0.124, 0.056 0.052, 0.018 0.104, 0.03 0.158, 0.039
0.04, 0.008 0.077, 0.014 0.117, 0.016 0.02, 0.001 0.037, 0.011 0.057,
0.011s0.037-0.01 0.057-0.011c0.04-0.003 0.077-0.009 0.117-0.016 0.055-0.009
0.106-0.021 0.158-0.039 0.044-0.016 0.083-0.035 0.124-0.056 0.01-0.005
0.021-0.005 0.031-0.011l16.464-8.708 13.562, 8.708c0.01, 0.006 0.021, 0.005
0.031, 0.011 0.071, 0.037 0.148, 0.058 0.228, 0.077 0.058, 0.014 0.113, 0.031
0.171, 0.034 0.02, 0.001 0.037, 0.011 0.057, 0.011 0.042, 0 0.077-0.019
0.117-0.024 0.074-0.008 0.144-0.018 0.215-0.043 0.054-0.019 0.1-0.046
0.149-0.073 0.062-0.034 0.12-0.07 0.174-0.118 0.048-0.042 0.085-0.091
0.124-0.141 0.028-0.036 0.065-0.06 0.088-0.101 0.011-0.019 0.01-0.04 0.02-0.059
0.029-0.059 0.045-0.122 0.062-0.186 0.017-0.066 0.036-0.128 0.039-0.195
0.001-0.021 0.012-0.039 0.012-0.06v-53c0-0.043-0.019-0.08-0.024-0.122zm-49.976,
43.585l-12, 7.705v-50.631l12-7.705v50.631zm17-23.932l-2.704, 2.704c-0.406,
0.406-0.406, 1.064 0, 1.469 0.406, 0.406 1.064, 0.406 1.469,
0l1.235-1.235v28.869l-15-7.933v-50.744l15, 7.933v18.937zm17, 23.874l-15,
7.933v-31.265c0.001-0.029 0.001-0.056
0-0.085v-19.393l15-7.933v50.743zm14-27.901l-2.226-2.225c-0.405-0.405-1.06-0.405-1.465,
0s-0.405, 1.061 0, 1.465l2.93, 2.93c0.21, 0.21 0.486, 0.306 0.76,
0.298v33.197l-12-7.705v-50.632l12, 7.705v14.967zm-42.678, 17.174c0.408, 0.408
1.07, 0.408 1.478, 0l2.217-2.217 2.217, 2.217c0.408, 0.408 1.07, 0.408 1.478, 0
0.408-0.408 0.408-1.07 0-1.478l-2.217-2.217 2.216-2.216c0.408-0.408 0.408-1.07
0-1.478-0.408-0.408-1.07-0.408-1.478, 0l-2.216,
2.216-2.216-2.216c-0.408-0.408-1.07-0.408-1.478, 0-0.408, 0.408-0.408, 1.07 0,
1.478l2.216, 2.216-2.217, 2.217c-0.408, 0.408-0.408, 1.07 0,
1.478zm17.444-14.974l2.939-2.939c0.406-0.406 0.406-1.064
0-1.469-0.406-0.406-1.064-0.406-1.469, 0l-2.939, 2.939c-0.406, 0.406-0.406,
1.064 0, 1.469 0.406, 0.406 1.064, 0.406 1.469, 0zm6-6l2.939-2.939c0.406-0.406
0.406-1.064 0-1.469-0.406-0.406-1.064-0.406-1.469, 0l-2.939, 2.939c-0.406,
0.406-0.406, 1.064 0, 1.469 0.406, 0.406 1.064, 0.406 1.469,
0zm12.492-.013c0.405, 0.405 1.061, 0.405 1.465, 0 0.405-0.405 0.405-1.061
0-1.465l-2.93-2.93c-0.405-0.405-1.061-0.405-1.465, 0s-0.405, 1.061 0,
1.465l2.93, 2.93z
"""
                        , SA.class "active-path"
                        , SA.fill "#E7BF7A"
                        ]
                        []
                    ]
                ]
            ]
        ]
        |> html
