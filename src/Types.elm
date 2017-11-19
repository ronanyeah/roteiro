module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Editable exposing (Editable)
import GraphQL.Client.Http as GQLH
import Window


type Msg
    = Cancel
    | CancelPicker
    | CbData (Result GQLH.Error AllData)
    | CbPosition (Result GQLH.Error Position)
    | CbPositionDelete (Result GQLH.Error Id)
    | CbSubmission (Result GQLH.Error Submission)
    | CbSubmissionDelete (Result GQLH.Error Submission)
    | CbTopic (Result GQLH.Error Topic)
    | CbTopicDelete (Result GQLH.Error Id)
    | CbTransition (Result GQLH.Error Transition)
    | CbTransitionDelete (Result GQLH.Error Transition)
    | ChoosePosition (Position -> Msg)
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
    | FormUpdate Form
    | Save
    | SetRoute Route
    | TokenEdit (Maybe String)
    | WindowSize Window.Size


type View
    = ViewAll
    | ViewCreatePosition Form
    | ViewCreateSubmission Form
    | ViewCreateTopic Form
    | ViewCreateTransition Form
    | ViewPosition (Editable Position)
    | ViewPositions
    | ViewSubmission (Editable Submission)
    | ViewSubmissions
    | ViewTopics
    | ViewTopic (Editable Topic)
    | ViewTransition (Editable Transition)
    | ViewTransitions


type Styles
    = BigIcon
    | Body
    | Button
    | Choice
    | ChooseBox
    | Dot
    | Field
    | Header
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


type alias Model =
    { view : View
    , positions : Dict String Position
    , transitions : Dict String Transition
    , submissions : Dict String Submission
    , topics : Dict String Topic
    , url : String
    , choosingPosition : Maybe (Position -> Msg)
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
    , position : Id
    }


type alias Form =
    { name : String
    , startPosition : Maybe Position
    , endPosition : Maybe Position
    , notes : Array String
    , steps : Array String
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
