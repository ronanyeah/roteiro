module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Editable exposing (Editable)
import Element.Input exposing (SelectMsg, SelectWith)
import Http
import Window


type Msg
    = Cancel
    | CbData (Result GcError AllData)
    | CbPosition (Result GcError Position)
    | CbPositionDelete (Result GcError Id)
    | CbSubmission (Result GcError Submission)
    | CbSubmissionDelete (Result GcError Submission)
    | CbTopic (Result GcError Topic)
    | CbTopicDelete (Result GcError Id)
    | CbTransition (Result GcError Transition)
    | CbTransitionDelete (Result GcError Transition)
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
    | EditPosition Position
    | EditTopic Topic
    | EditTransition Transition
    | Save
    | SelectStartPosition (SelectMsg Position)
    | SetRoute Route
    | TokenEdit (Maybe String)
    | Update Form
    | WindowSize Window.Size


type View
    = ViewAll
    | ViewCreatePosition Form
    | ViewCreateSubmission Form
    | ViewCreateTopic Form
    | ViewCreateTransition Form
    | ViewPosition (Editable Position)
    | ViewPositions
    | ViewSubmission (Editor Submission)
    | ViewSubmissions
    | ViewTopics
    | ViewTopic (Editable Topic)
    | ViewTransition (Editable Transition)
    | ViewTransitions


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
    | Icon
    | Line
    | Link
    | MattIcon
    | None
    | Picker
    | PickerCancel
    | SetBox
    | Subtitle
    | Topics


type Variations
    = Small


type Id
    = Id String


type Editor a
    = Editing Form a
    | ReadOnly a


type alias Model =
    { view : View
    , positions : Dict String Position
    , transitions : Dict String Transition
    , submissions : Dict String Submission
    , topics : Dict String Topic
    , url : String
    , device : Device
    , url : String
    , token : String
    , tokenForm : Maybe String
    , confirm : Maybe Msg
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
    | T Id
    | To Id
    | Top
    | Trs
    | NotFound


type GcError
    = HttpError Http.Error
    | GcError (List { code : Int, message : String })


type alias Topic =
    { id : Id
    , name : String
    , notes : Array String
    }


type alias Position =
    { id : Id
    , name : String
    , notes : Array String
    }


type alias Submission =
    { id : Id
    , name : String
    , steps : Array String
    , notes : Array String
    , when : Maybe String
    , position : Id
    }


type alias Form =
    { name : String
    , startTest : SelectWith Position Msg
    , startPosition : Maybe Position
    , endPosition : Maybe Position
    , notes : Array String
    , steps : Array String
    , when : String
    }


type alias Transition =
    { id : Id
    , name : String
    , startPosition : Id
    , endPosition : Id
    , notes : Array String
    , steps : Array String
    }


type alias AllData =
    { transitions : List Transition
    , positions : List Position
    , submissions : List Submission
    , topics : List Topic
    }
