module Types exposing (..)

import Array exposing (Array)
import Http
import Navigation exposing (Location)
import RemoteData exposing (RemoteData)
import Window


type Msg
    = AddTag Info
    | AppInit String Location (Result GcError User)
    | Cancel
    | CbAuth (Result GcError Auth)
    | CbCreateOrUpdatePosition (Result GcError Position)
    | CbCreateOrUpdateSubmission (Result GcError Submission)
    | CbCreateOrUpdateTag (Result GcError Tag)
    | CbCreateOrUpdateTopic (Result GcError Topic)
    | CbCreateOrUpdateTransition (Result GcError Transition)
    | CbDeletePosition (Result GcError Id)
    | CbDeleteSubmission (Result GcError Id)
    | CbDeleteTag (Result GcError Id)
    | CbDeleteTopic (Result GcError Id)
    | CbDeleteTransition (Result GcError Id)
    | CbPosition (GcData Position)
    | CbPositions (GcData (List Info))
    | CbSubmission (GcData Submission)
    | CbSubmissions (GcData (List Submission))
    | CbTag (GcData Tag)
    | CbTags (GcData (List Info))
    | CbTopic (GcData Topic)
    | CbTopics (GcData (List Info))
    | CbTransition (GcData Transition)
    | CbTransitions (GcData (List Transition))
    | Confirm (Maybe Msg)
    | CreatePosition
    | CreateSubmission (Maybe Position)
    | CreateTag
    | CreateTopic
    | CreateTransition (Maybe Position)
    | DeletePosition Id
    | DeleteSubmission Id
    | DeleteTag Id
    | DeleteTopic Id
    | DeleteTransition Id
    | EditPosition Position
    | EditSubmission Submission
    | EditTag Tag
    | EditTopic Topic
    | EditTransition Transition
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
    | UpdateStartPosition Info
    | UrlChange Location
    | WindowSize Window.Size


type View
    = ViewApp AppView
    | ViewLogin
    | ViewSignUp
    | ViewWaiting


type AppView
    = ViewCreatePosition
    | ViewCreateSubmission
    | ViewCreateTag
    | ViewCreateTopic
    | ViewCreateTransition
    | ViewEditPosition
    | ViewEditSubmission
    | ViewEditTag
    | ViewEditTopic
    | ViewEditTransition
    | ViewPosition (GcData Position)
    | ViewPositions
    | ViewStart
    | ViewSubmission (GcData Submission)
    | ViewSubmissions (GcData (List Submission))
    | ViewTag (GcData Tag)
    | ViewTags
    | ViewTopic (GcData Topic)
    | ViewTopics (GcData (List Info))
    | ViewTransition (GcData Transition)
    | ViewTransitions (GcData (List Transition))


type FaIcon
    = Flag
    | Arrow
    | Write
    | Trash
    | Cross
    | Tick
    | Bolt
    | Lock
    | Email
    | SignIn
    | SignOut
    | Waiting
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


type Id
    = Id String


type alias GcData a =
    RemoteData GcError a


{-| An error from Graphcool.
-}
type GcError
    = HttpError Http.Error
    | GcError (List ApiError)


{-| <https://www.graph.cool/docs/reference/graphql-api/error-handling-aecou7haj9>
-}
type ApiError
    = InsufficientPermissions
    | RelationIsRequired
    | FunctionExecutionError String
    | ApiError Int String
    | Other String


type alias Info =
    { id : Id
    , name : String
    }


type alias Model =
    { view : View
    , auth : Maybe Auth
    , previousView : View
    , positions : GcData (List Info)
    , tags : GcData (List Info)
    , device : Device
    , size : Window.Size
    , confirm : Maybe Msg
    , form : Form
    , sidebarOpen : Bool
    , selectingEndPosition : Bool
    , selectingStartPosition : Bool
    }


type Device
    = Desktop
    | Mobile


type Route
    = NotFound
    | PositionRoute Id
    | Positions
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


type alias Flags =
    { auth : Maybe Auth
    , isOnline : Bool
    }


type alias Auth =
    { id : Id
    , email : String
    , token : String
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
    , errors : List String
    , startPosition : Maybe Info
    , endPosition : Maybe Info
    , notes : Array String
    , steps : Array String
    , tags : Array Info
    , email : String
    , password : String
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


type alias AllData =
    { transitions : List Transition
    , positions : List Position
    , submissions : List Submission
    , topics : List Topic
    }
