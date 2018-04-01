module Utils exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Element exposing (Attribute, Element, centerX, centerY, el, empty, html)
import Element.Input as Input exposing (Label)
import Html
import Html.Attributes
import Navigation
import Ports
import Regex exposing (Regex)
import RemoteData
import Task exposing (Task)
import Types exposing (ApiError(..), AppView(..), Device(Desktop, Mobile), FaIcon(..), Form, GcData, GcError(..), Id(..), Model, Route(..), View(..))
import Window


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
        |> Navigation.newUrl


isJust : Maybe a -> Bool
isJust =
    unwrap False <| always True


removeNull : GcData (Maybe b) -> GcData b
removeNull =
    RemoteData.andThen
        (Maybe.map RemoteData.Success
            >> (Maybe.withDefault <|
                    RemoteData.Failure <|
                        GcError [ Other "Data does not exist" ]
               )
        )


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

                            FunctionExecutionError txt ->
                                txt

                            RelationIsRequired ->
                                "Relation is required!"

                            ApiError code txt ->
                                "Code: " ++ toString code ++ ", Message: " ++ txt

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


isPositionView : AppView -> Bool
isPositionView view =
    case view of
        ViewPositions ->
            True

        ViewPosition _ ->
            True

        ViewCreatePosition ->
            True

        ViewEditPosition ->
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

        ViewEditSubmission ->
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

        ViewEditTag ->
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

        ViewEditTopic ->
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

        ViewEditTransition ->
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
                    "fa-spinner fa-pulse"

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
                |> (++) "fas "
                |> Html.Attributes.class
    in
    el attrs <| el [ centerX, centerY ] <| html <| Html.span [ faClass ] []


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
    { view = ViewWaiting
    , auth = Nothing
    , previousView = ViewWaiting
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
    , errors = []
    , startPosition = Nothing
    , endPosition = Nothing
    , steps = Array.empty
    , notes = Array.empty
    , tags = Array.empty
    , email = ""
    , password = ""
    }


matchLink : Regex
matchLink =
    Regex.regex
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$"


matchDomain : Regex
matchDomain =
    Regex.regex
        "(?:[-a-zA-Z0-9@:%_\\+~.#=]{2,256}\\.)?([-a-zA-Z0-9@:%_\\+~#=]*)\\.[a-z]{2,6}\\b(?:[-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)"
