module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Element.Input exposing (SelectMsg, SelectWith)
import Http
import RemoteData exposing (RemoteData)
import Window


type Msg
    = Cancel
    | CbDelete (Result GcError Id)
    | CbPosition (GcData Position)
    | CbPositions (GcData (List Position))
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
    | Edit
    | Save
    | SetRoute Route
    | TokenEdit (Maybe String)
    | UpdateEndPosition (SelectMsg Info)
    | UpdateForm Form
    | UpdateStartPosition (SelectMsg Info)
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


type Styles
    = Ball
    | BallIcon
    | BigIcon
    | Body
    | Button
    | Choice
    | ChooseBox
    | Dot
    | Field
    | Header
    | Home
    | Line
    | Link
    | MattIcon
    | None
    | Picker
    | Subtitle
    | ActionIcon


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
    | Book
    | Notes
    | Plus
    | Minus
    | Question
    | Globe
    | Cogs


type Variations
    = Small


type Id
    = Id String


type Picker a
    = Picking (SelectWith a Msg)
    | Picked a
    | Pending


type alias GcData a =
    RemoteData GcError a


{-| An error from Graphcool.
-}
type GcError
    = HttpError Http.Error
    | GcError (List ApiError)


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
    , positions : GcData (Dict String Position)
    , url : String
    , device : Device
    , url : String
    , token : String
    , tokenForm : Maybe String
    , confirm : Maybe Msg
    , form : Form
    }


type Device
    = Desktop
    | Mobile


type Route
    = Ps
    | P Id
    | Ts
    | S Id
    | Ss
    | Start
    | T Id
    | To Id
    | Top
    | Trs
    | NotFound


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
    , transitions : List Info
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
