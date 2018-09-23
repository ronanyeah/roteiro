module Types exposing (ApiUrl(..), AppView(..), Auth, Device(..), Flags, Form, GqlRemote, GqlResult, Icon(..), Info, Model, Msg(..), Position, Route(..), Size, Status(..), Submission, Tag, Token(..), Topic, Transition, User, View(..))

import Api.Scalar exposing (Id)
import Array exposing (Array)
import Browser
import Browser.Navigation exposing (Key)
import Graphql.Http
import List.Nonempty exposing (Nonempty(..))
import RemoteData exposing (RemoteData, WebData)
import Url exposing (Url)


type ApiUrl
    = ApiUrl String


type Token
    = Token String


type Status
    = Ready
    | Waiting
    | Errors (Nonempty String)


type alias Flags =
    { maybeAuth : Maybe String
    , size : Size
    , apiUrl : String
    }


type alias GqlResult a =
    Result (Graphql.Http.Error a) a


type alias GqlRemote a =
    RemoteData (Graphql.Http.Error a) a


type Msg
    = AddTag Info
    | Cancel
    | CbAuth (GqlResult Auth)
      -- TODO: Replace Bool with ()
    | CbChangePassword (GqlResult Bool)
    | CbCreateOrUpdatePosition (GqlResult Position)
    | CbCreateOrUpdateSubmission (GqlResult Submission)
    | CbCreateOrUpdateTag (GqlResult Tag)
    | CbCreateOrUpdateTopic (GqlResult Topic)
    | CbCreateOrUpdateTransition (GqlResult Transition)
    | CbDeletePosition (GqlResult Id)
    | CbDeleteSubmission (GqlResult Id)
    | CbDeleteTag (GqlResult Id)
    | CbDeleteTopic (GqlResult Id)
    | CbDeleteTransition (GqlResult Id)
    | CbPosition (GqlResult (Maybe Position))
    | CbPositions (GqlResult (List Info))
    | CbSubmission (GqlResult (Maybe Submission))
    | CbSubmissions (GqlResult (List Submission))
    | CbTag (GqlResult (Maybe Tag))
    | CbTags (GqlResult (List Info))
    | CbTopic (GqlResult (Maybe Topic))
    | CbTopics (GqlResult (List Info))
    | CbTransition (GqlResult (Maybe Transition))
    | CbTransitions (GqlResult (List Transition))
    | ChangePasswordSubmit
    | Confirm (Maybe Msg)
    | DeletePosition Id
    | DeleteSubmission Id
    | DeleteTag Id
    | DeleteTopic Id
    | DeleteTransition Id
    | LoginSubmit
    | Logout
    | NavigateTo Route
    | RemoveTag Int
    | SaveCreatePosition
    | SaveCreateSubmission
    | SaveCreateTag
    | SaveCreateTopic
    | SaveCreateTransition
    | SaveEditPosition
    | SaveEditSubmission
    | SaveEditTag
    | SaveEditTopic
    | SaveEditTransition
    | SetRouteThenNavigate Route Route
    | SidebarNavigate Route
    | SidebarSignOut
    | SignUpSubmit
    | ToggleEndPosition
    | ToggleSidebar
    | ToggleStartPosition
    | UpdateEmail String
    | UpdateEndPosition Info
    | UpdateForm Form
    | UpdatePassword String
    | UpdateConfirmPassword String
    | UpdateStartPosition Info
    | UrlChange Url
    | UrlRequest Browser.UrlRequest
    | WindowSize Int Int


type View
    = ViewApp AppView
    | ViewLogin
    | ViewSignUp


type AppView
    = ViewCreatePosition
    | ViewCreateSubmission
    | ViewCreateTag
    | ViewCreateTopic
    | ViewCreateTransition
    | ViewEditPosition Position
    | ViewEditSubmission Submission
    | ViewEditTag Tag
    | ViewEditTopic Topic
    | ViewEditTransition Transition
    | ViewPosition
    | ViewPositions
    | ViewSettings
    | ViewStart
    | ViewSubmission (WebData Submission)
    | ViewSubmissions
    | ViewTag (WebData Tag)
    | ViewTags
    | ViewTopic (WebData Topic)
    | ViewTopics
    | ViewTransition (WebData Transition)
    | ViewTransitions


type Icon
    = Flag
    | Arrow
    | ArrowDown
    | Write
    | Trash
    | Cross
    | Tick
    | Bolt
    | Lock
    | Email
    | SignIn
    | SignOut
    | Spinner
    | Home
    | Book
    | Notes
    | Plus
    | NewUser
    | Minus
    | Question
    | Globe
    | Cogs
    | Bars
    | Warning
    | Tags


type alias Info =
    { id : Id
    , name : String
    }


type alias Model =
    { view : View
    , apiUrl : ApiUrl
    , auth : Maybe Auth
    , previousRoute : Maybe Route
    , positions : GqlRemote (List Info)
    , position : GqlRemote Position
    , topics : GqlRemote (List Info)
    , tags : GqlRemote (List Info)
    , submissions : GqlRemote (List Submission)
    , transitions : GqlRemote (List Transition)
    , device : Device
    , size : Size
    , confirm : Maybe Msg
    , form : Form
    , sidebarOpen : Bool
    , selectingEndPosition : Bool
    , selectingStartPosition : Bool
    , key : Key
    }


type alias Size =
    { height : Int
    , width : Int
    }


type Device
    = Desktop
    | Mobile


type Route
    = NotFound
    | CreatePositionRoute
    | CreateSubmissionRoute
    | CreateTagRoute
    | CreateTopicRoute
    | CreateTransitionRoute
    | EditPositionRoute Id
    | EditSubmissionRoute Id
    | EditTagRoute Id
    | EditTopicRoute Id
    | EditTransitionRoute Id
    | PositionRoute Id
    | Positions
    | SettingsRoute
    | SubmissionRoute Id
    | Submissions
    | Login
    | SignUp
    | Start
    | TagRoute Id
    | TagsRoute
    | TopicRoute Id
    | Topics
    | TransitionRoute Id
    | Transitions


type alias Auth =
    { id : Id
    , email : String
    , token : Token
    }


type alias User =
    { id : Id
    , email : String
    }


type alias Tag =
    { id : Id
    , name : String
    , submissions : List Info
    , transitions : List Info
    }


type alias Topic =
    { id : Id
    , name : String
    , notes : Array String
    }


type alias Position =
    { id : Id
    , name : String
    , notes : Array String
    , submissions : List Info
    , transitionsFrom : List Transition
    , transitionsTo : List Transition
    }


type alias Submission =
    { id : Id
    , name : String
    , steps : Array String
    , notes : Array String
    , position : Info
    , tags : List Info
    }


type alias Form =
    { name : String
    , id : Id
    , status : Status
    , startPosition : Maybe Info
    , endPosition : Maybe Info
    , notes : Array String
    , steps : Array String
    , tags : Array Info
    , email : String
    , password : String
    , confirmPassword : String
    }


type alias Transition =
    { id : Id
    , name : String
    , startPosition : Info
    , endPosition : Info
    , notes : Array String
    , steps : Array String
    , tags : List Info
    }
