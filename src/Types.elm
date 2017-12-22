module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Element.Input exposing (SelectMsg, SelectWith)
import Http
import Window


type Msg
    = Cancel
    | CbData (Result GcError AllData)
    | CbPosition (Result GcError Position)
    | CbPositionDelete (Result GcError Id)
    | CbSubmission (Result GcError Submission)
    | CbSubmissionDelete (Result GcError Id)
    | CbTopic (Result GcError Topic)
    | CbTopicDelete (Result GcError Id)
    | CbTransition (Result GcError Transition)
    | CbTransitionDelete (Result GcError Id)
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
    | Update Form
    | UpdateEndPosition (SelectMsg Position)
    | UpdateStartPosition (SelectMsg Position)
    | WindowSize Window.Size


type View
    = ViewAll
    | ViewCreatePosition
    | ViewCreateSubmission
    | ViewCreateTopic
    | ViewCreateTransition
    | ViewPosition Bool Position
    | ViewPositions
    | ViewSubmission Bool Submission
    | ViewSubmissions
    | ViewTopic Bool Topic
    | ViewTopics
    | ViewTransition Bool Transition
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


{-| An error from Graphcool.
-}
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
    , position : Id
    }


type alias Form =
    { name : String
    , startPosition : Picker Position
    , endPosition : Picker Position
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
