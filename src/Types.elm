module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Editable exposing (Editable)
import GraphQL.Client.Http as GQLH


type Msg
    = SelectPosition Position
    | SelectSubmission Submission
    | SelectTransition Transition
    | SelectNotes
    | Reset
    | CbData (Result GQLH.Error AllData)
    | Edit
    | EditChange View
    | Save
    | Cancel
    | SavePosition (Result GQLH.Error Position)
    | SaveTransition (Result GQLH.Error Transition)
    | AddTransition Position
    | AddSubmission Position
    | NewTransitionInput NewTransitionForm
    | AddSubmissionInput AddSubmissionForm
    | NotesInput Topic


type View
    = ViewAll
    | ViewPosition (Editable Position)
    | ViewSubmission Submission
    | ViewTransition (Editable Transition)
    | ViewNotes (Maybe Topic)
    | ViewNewPosition NewPositionForm
    | ViewAddSubmission AddSubmissionForm
    | ViewNewTransition NewTransitionForm


type Styles
    = None
    | SetBox
    | Body
    | Button
    | Link
    | Line


type Id
    = Id String


type alias Model =
    { view : View
    , positions : Dict String Position
    , transitions : Dict String Transition
    , submissions : Dict String Submission
    , topics : Array Topic
    , url : String
    }


type alias Topic =
    { name : String
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
    , steps : List String
    , notes : List String
    , position : Id
    }


type Picker a
    = Waiting
    | Picking
    | Picked a


type alias NewTransitionForm =
    { name : String
    , startPosition : Position
    , endPosition : Picker Position
    , notes : Array String
    , steps : Array String
    }


type alias NewPositionForm =
    { name : String
    , notes : Array String
    }


type alias AddSubmissionForm =
    { name : String
    , position : Position
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
