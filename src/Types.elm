module Types exposing (..)

import Array exposing (Array)
import Http
import Navigation exposing (Location)
import RemoteData exposing (RemoteData)
import Window


type Msg
    = AddTag Info
    | Cancel
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
    | NavigateTo String
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
    | SidebarNavigate String
    | ToggleEndPosition
    | ToggleSidebar
    | ToggleStartPosition
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
    | Other String


type alias Info =
    { id : Id
    , name : String
    }


type alias Model =
    { view : View
    , previousView : View
    , positions : GcData (List Info)
    , tags : GcData (List Info)
    , device : Device
    , size : Window.Size
    , token : String
    , tokenForm : Maybe String
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
    | Start
    | TagRoute Id
    | TagsRoute
    | TopicRoute Id
    | Topics
    | TransitionRoute Id
    | Transitions


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
