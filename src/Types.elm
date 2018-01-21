module Types exposing (..)

import Array exposing (Array)
import Http
import Navigation exposing (Location)
import RemoteData exposing (RemoteData)
import Window


type Msg
    = Cancel
    | CbCreateOrUpdatePosition (Result GcError Position)
    | CbCreateOrUpdateSubmission (Result GcError Submission)
    | CbCreateOrUpdateTopic (Result GcError Topic)
    | CbCreateOrUpdateTransition (Result GcError Transition)
    | CbDeletePosition (Result GcError Id)
    | CbDeleteSubmission (Result GcError Id)
    | CbDeleteTopic (Result GcError Id)
    | CbDeleteTransition (Result GcError Id)
    | CbPosition (GcData Position)
    | CbPositions (GcData (List Info))
    | CbSubmission (GcData Submission)
    | CbSubmissions (GcData (List Submission))
    | CbTopic (GcData Topic)
    | CbTopics (GcData (List Info))
    | CbTransition (GcData Transition)
    | CbTransitions (GcData (List Transition))
    | Confirm (Maybe Msg)
    | CreatePosition
    | CreateSubmission (Maybe Position)
    | CreateTopic
    | CreateTransition (Maybe Position)
    | DeletePosition Id
    | DeleteSubmission Id
    | DeleteTopic Id
    | DeleteTransition Id
    | EditPosition Position
    | EditSubmission Submission
    | EditTopic Topic
    | EditTransition Transition
    | SaveCreatePosition
    | SaveCreateSubmission
    | SaveCreateTopic
    | SaveCreateTransition
    | SaveEditPosition
    | SaveEditSubmission
    | SaveEditTopic
    | SaveEditTransition
    | SidebarNavigate String
    | ToggleSidebar
    | TokenEdit (Maybe String)
    | UpdateEndPosition Info
    | UpdateForm Form
    | UpdateStartPosition Info
    | UrlChange Location
    | WindowSize Window.Size


type View
    = ViewStart
    | ViewCreatePosition
    | ViewCreateSubmission
    | ViewCreateTopic
    | ViewCreateTransition
    | ViewEditPosition
    | ViewEditSubmission
    | ViewEditTopic
    | ViewEditTransition
    | ViewPosition (GcData Position)
    | ViewPositions
    | ViewSubmission (GcData Submission)
    | ViewSubmissions (GcData (List Submission))
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
    | Waiting
    | Home
    | Book
    | Notes
    | Plus
    | Minus
    | Question
    | Globe
    | Cogs
    | Bars
    | Warning


type Id
    = Id String


type Picker a
    = Picking
    | Picked a
    | Pending


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
    | Other String


type alias Info =
    { id : Id
    , name : String
    }


type alias Model =
    { view : View
    , previousView : View
    , positions : GcData (List Info)
    , device : Device
    , size : Window.Size
    , token : String
    , tokenForm : Maybe String
    , confirm : Maybe Msg
    , form : Form
    , sidebarOpen : Bool
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
    | Start
    | TopicRoute Id
    | Topics
    | TransitionRoute Id
    | Transitions


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
    , transitionsFrom : List Info
    , transitionsTo : List Info
    }


type alias Submission =
    { id : Id
    , name : String
    , steps : Array String
    , notes : Array String
    , position : Info
    }


type alias Form =
    { name : String
    , id : Id
    , errors : List String
    , startPosition : Picker Info
    , endPosition : Picker Info
    , notes : Array String
    , steps : Array String
    }


type alias Transition =
    { id : Id
    , name : String
    , startPosition : Info
    , endPosition : Info
    , notes : Array String
    , steps : Array String
    }


type alias AllData =
    { transitions : List Transition
    , positions : List Position
    , submissions : List Submission
    , topics : List Topic
    }
