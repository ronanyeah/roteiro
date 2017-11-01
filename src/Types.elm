module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Editable exposing (Editable)
import GraphQL.Client.Http as GQLH


type Msg
    = Cancel
    | CbData (Result GQLH.Error AllData)
    | CbPosition (Result GQLH.Error Position)
    | CbTransition (Result GQLH.Error Transition)
    | CreateSubmission Position
    | CreateTransition Position
    | Edit
    | EditChange View
    | InputCreatePosition FormCreatePosition
    | InputCreateSubmission FormCreateSubmission
    | InputCreateTransition FormCreateTransition
    | InputTopic Topic
    | Reset
    | Save
    | SelectPosition Position
    | SelectSubmission Submission
    | SelectTopics
    | SelectTransition Transition


type View
    = ViewAll
    | ViewCreatePosition FormCreatePosition
    | ViewCreateSubmission FormCreateSubmission
    | ViewCreateTransition FormCreateTransition
    | ViewPosition (Editable Position)
    | ViewSubmission Submission
    | ViewTopics (Maybe Topic)
    | ViewTransition (Editable Transition)


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


type alias FormCreateTransition =
    { name : String
    , startPosition : Position
    , endPosition : Picker Position
    , notes : Array String
    , steps : Array String
    }


type alias FormCreatePosition =
    { name : String
    , notes : Array String
    }


type alias FormCreateSubmission =
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
