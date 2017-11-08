module Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Editable exposing (Editable)
import GraphQL.Client.Http as GQLH


type Msg
    = Cancel
    | CbData (Result GQLH.Error AllData)
    | CbPosition (Result GQLH.Error Position)
    | CbSubmission (Result GQLH.Error Submission)
    | CbTopic (Result GQLH.Error Topic)
    | CbTransition (Result GQLH.Error Transition)
    | CreatePosition
    | CreateSubmission Position
    | CreateTopic
    | CreateTransition Position
    | Edit
    | EditChange View
    | EditTopic Topic
    | FormUpdate Form
    | Reset
    | Save
    | SelectPosition Position
    | SelectSubmission Submission
    | SelectTopics
    | SelectTransition Transition


type View
    = ViewAll
    | ViewCreatePosition Form
    | ViewCreateSubmission Form
    | ViewCreateTopic Form
    | ViewCreateTransition Form
    | ViewEditTopic Topic
    | ViewPosition (Editable Position)
    | ViewSubmission (Editable Submission)
    | ViewTopics
    | ViewTransition (Editable Transition)


type Styles
    = Body
    | Button
    | Header
    | Icon
    | Line
    | Link
    | None
    | SetBox
    | Subtitle
    | Title
    | Topics


type Id
    = Id String


type alias Model =
    { view : View
    , positions : Dict String Position
    , transitions : Dict String Transition
    , submissions : Dict String Submission
    , topics : Dict String Topic
    , url : String
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
    }


type alias Submission =
    { id : Id
    , name : String
    , steps : Array String
    , notes : Array String
    , position : Id
    }


{-| REPLACE THIS WITH EDITABLE?
-}
type Picker a
    = Waiting
    | Picking
    | Picked a


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
