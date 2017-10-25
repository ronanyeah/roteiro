module Main exposing (main)

import Array exposing (Array)
import Color exposing (black)
import Dict exposing (Dict)
import Editable exposing (Editable)
import Element exposing (Element, column, el, empty, paragraph, row, text, viewport, when)
import Element.Attributes exposing (center, fill, height, padding, px, spacing, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import GraphQL.Client.Http as GQLH
import GraphQL.Request.Builder as GQLB
import GraphQL.Request.Builder.Arg as Arg
import Html exposing (Html)
import Style exposing (StyleSheet, style, styleSheet)
import Style.Border as Border
import Style.Font as Font
import Style.Color as Color
import Task


main : Program String Model Msg
main =
    Html.programWithFlags
        { init =
            \url ->
                ( { view = ViewAll
                  , positions = Dict.empty
                  , transitions = Dict.empty
                  , submissions = Dict.empty
                  , topics = []
                  , url = url
                  }
                , Task.attempt CbData (GQLH.sendQuery url fetchData)
                )
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }



-- TYPES


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


type View
    = ViewAll
    | ViewPosition (Editable Position)
    | ViewSubmission Submission
    | ViewTransition (Editable Transition)
    | ViewNotes
    | ViewNewTransition NewTransitionForm
    | ViewAddSubmission AddSubmissionForm


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
    , topics : List Topic
    , url : String
    }


type alias Topic =
    { name : String
    , content : List String
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



-- VIEW


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewAll ->
                    (model.positions
                        |> Dict.values
                        |> List.map
                            (\p ->
                                el Button
                                    [ padding 10
                                    , onClick <| SelectPosition p
                                    ]
                                <|
                                    text p.name
                            )
                    )
                        ++ [ el Line [ width <| px 100, height <| px 2 ] empty
                           , el Button
                                [ padding 10
                                , onClick <| SelectNotes
                                ]
                             <|
                                text "Notes"
                           ]

                ViewPosition data ->
                    case data of
                        Editable.Editable _ { name, notes } ->
                            [ Input.text
                                None
                                []
                                { onChange = \str -> EditChange <| ViewPosition <| Editable.map (\r -> { r | name = str }) <| data
                                , value = name
                                , label = Input.hiddenLabel ""
                                , options = []
                                }
                            ]
                                ++ (arrayEditor
                                        (\i str ->
                                            EditChange <|
                                                ViewPosition <|
                                                    Editable.map (\r -> { r | notes = Array.set i str r.notes }) <|
                                                        data
                                        )
                                        notes
                                   )
                                ++ [ el Button
                                        [ padding 10
                                        , onClick <|
                                            EditChange <|
                                                ViewPosition <|
                                                    Editable.map (\r -> { r | notes = Array.push "" r.notes }) <|
                                                        data
                                        ]
                                     <|
                                        text "+"
                                   , el Button
                                        [ padding 10
                                        , onClick <|
                                            EditChange <|
                                                ViewPosition <|
                                                    Editable.map (\r -> { r | notes = Array.slice 0 -1 r.notes }) <|
                                                        data
                                        ]
                                     <|
                                        text "-"
                                   , saveButton
                                   , cancelButton
                                   ]

                        Editable.ReadOnly ({ id, name, notes } as p) ->
                            let
                                transitions =
                                    model.transitions
                                        |> Dict.values
                                        |> List.filter (.startPosition >> (==) id)

                                submissions =
                                    model.submissions
                                        |> Dict.values
                                        |> List.filter (.position >> (==) id)
                            in
                                [ resetButton
                                , editButton
                                , el None [] <| text name
                                , viewList "Notes" <| Array.toList notes
                                , viewTechList "Transitions" SelectTransition transitions
                                , el Button
                                    [ padding 10
                                    , onClick <| AddTransition p
                                    ]
                                  <|
                                    text "Add Transition"
                                , viewTechList "Submissions" SelectSubmission submissions
                                , el Button
                                    [ padding 10
                                    , onClick <| AddSubmission p
                                    ]
                                  <|
                                    text "Add Submission"
                                ]

                ViewSubmission { name, steps, position, notes } ->
                    get position model.positions
                        |> unwrap oopsView
                            (\p ->
                                [ resetButton
                                , row None
                                    []
                                    [ text (name ++ " from ")
                                    , el Link [ onClick <| SelectPosition p ] <| text p.name
                                    ]
                                , viewSteps steps
                                , viewList "Notes" notes
                                ]
                            )

                ViewTransition data ->
                    case data of
                        Editable.Editable _ { name, notes } ->
                            [ Input.text
                                None
                                []
                                { onChange =
                                    \str ->
                                        EditChange <| ViewTransition <| Editable.map (\r -> { r | name = str }) <| data
                                , value = name
                                , label = Input.hiddenLabel ""
                                , options = []
                                }
                            ]
                                ++ (arrayEditor
                                        (\i str ->
                                            EditChange <|
                                                ViewTransition <|
                                                    Editable.map (\r -> { r | notes = Array.set i str r.notes }) <|
                                                        data
                                        )
                                        notes
                                   )

                        Editable.ReadOnly { name, steps, startPosition, endPosition, notes } ->
                            unwrap2 oopsView
                                (get startPosition model.positions)
                                (get endPosition model.positions)
                                (\start end ->
                                    [ resetButton
                                    , editButton
                                    , row None
                                        []
                                        [ text (name ++ " from ")
                                        , el Link [ onClick <| SelectPosition start ] <| text start.name
                                        ]
                                    , viewSteps <| Array.toList steps
                                    , viewList "Notes" <| Array.toList notes
                                    , row None
                                        []
                                        [ text "Transitions to: "
                                        , el Link [ onClick <| SelectPosition end ] <|
                                            text end.name
                                        ]
                                    ]
                                )

                ViewNotes ->
                    model.topics
                        |> List.map viewTopic
                        |> (::) resetButton

                ViewNewTransition ({ notes, steps, name, startPosition, endPosition } as form) ->
                    [ Input.text
                        None
                        []
                        { onChange =
                            \str ->
                                NewTransitionInput { form | name = str }
                        , value = name
                        , label = Input.labelAbove <| text "Name:"
                        , options = []
                        }
                    , text <| "Start Position: " ++ startPosition.name
                    , case endPosition of
                        Waiting ->
                            el None [ onClick <| NewTransitionInput { form | endPosition = Picking } ] <| text "Select A Position"

                        Picked endP ->
                            el None [ onClick <| NewTransitionInput { form | endPosition = Picking } ] <| text <| "End Position: " ++ endP.name

                        Picking ->
                            model.positions
                                |> Dict.values
                                |> List.map
                                    (\p ->
                                        el None [ onClick <| NewTransitionInput { form | endPosition = Picked p } ] <| text p.name
                                    )
                                |> column None []
                    ]
                        ++ (notesEditor form NewTransitionInput)
                        ++ (stepsEditor form NewTransitionInput)
                        ++ [ saveButton
                           , cancelButton
                           ]

                ViewAddSubmission ({ notes, steps, name, position } as form) ->
                    [ text "Name:"
                    , Input.text
                        None
                        []
                        { onChange =
                            \str ->
                                AddSubmissionInput { form | name = str }
                        , value = name
                        , label = Input.labelAbove <| text "Name:"
                        , options = []
                        }
                    ]
                        ++ notesEditor form AddSubmissionInput
                        ++ stepsEditor form AddSubmissionInput
                        ++ [ saveButton
                           , cancelButton
                           ]
    in
        viewport styling <|
            column Body [ center, width fill, spacing 30, padding 15 ] content


arrayEditor : (Int -> String -> Msg) -> Array String -> List (Element Styles vs Msg)
arrayEditor onChange =
    Array.indexedMap
        (\i v ->
            Input.text
                None
                []
                { onChange = onChange i
                , value = v
                , label = Input.hiddenLabel ""
                , options = []
                }
        )
        >> Array.toList


saveButton : Element Styles vs Msg
saveButton =
    el Button
        [ padding 10
        , onClick Save
        ]
    <|
        text "Save"


cancelButton : Element Styles vs Msg
cancelButton =
    el Button
        [ padding 10
        , onClick Cancel
        ]
    <|
        text "Cancel"


stepsEditor : { r | steps : Array String } -> ({ r | steps : Array String } -> Msg) -> List (Element Styles vs Msg)
stepsEditor form msg =
    form.steps
        |> Array.indexedMap
            (\i v ->
                Input.text
                    None
                    []
                    { onChange = \str -> msg { form | steps = Array.set i str form.steps }
                    , value = v
                    , label = Input.hiddenLabel ""
                    , options = []
                    }
            )
        |> Array.toList
        |> (::) (text "Steps:")
        |> flip List.append
            [ el Button
                [ padding 10
                , onClick <| msg { form | steps = Array.push "" form.steps }
                ]
              <|
                text "+"
            , when (not <| Array.isEmpty form.steps) <|
                el Button
                    [ padding 10
                    , onClick <| msg { form | steps = Array.slice 0 -1 form.steps }
                    ]
                <|
                    text "-"
            ]


notesEditor : { r | notes : Array String } -> ({ r | notes : Array String } -> Msg) -> List (Element Styles vs Msg)
notesEditor form msg =
    form.notes
        |> Array.indexedMap
            (\i v ->
                Input.text
                    None
                    []
                    { onChange = \str -> msg { form | notes = Array.set i str form.notes }
                    , value = v
                    , label = Input.hiddenLabel ""
                    , options = []
                    }
            )
        |> Array.toList
        |> (::) (text "Notes:")
        |> flip List.append
            [ el Button
                [ padding 10
                , onClick <| msg { form | notes = Array.push "" form.notes }
                ]
              <|
                text "+"
            , when (not <| Array.isEmpty form.notes) <|
                el Button
                    [ padding 10
                    , onClick <| msg { form | notes = Array.slice 0 -1 form.notes }
                    ]
                <|
                    text "-"
            ]


editButton : Element Styles vs Msg
editButton =
    el Button
        [ padding 10
        , onClick Edit
        ]
    <|
        text "Edit"


resetButton : Element Styles vs Msg
resetButton =
    el Button [ padding 10, onClick Reset ] <| text "Positions"


oopsView : List (Element Styles vs Msg)
oopsView =
    [ resetButton, text "oops!" ]


viewTopic : Topic -> Element Styles vs Msg
viewTopic { name, content } =
    viewList name content


viewSteps : List String -> Element Styles vs Msg
viewSteps =
    List.indexedMap
        (\i step ->
            row None
                []
                [ Element.bold <| (toString (i + 1) ++ ".")
                , text <| " " ++ step
                ]
        )
        >> column None []


viewList : String -> List String -> Element Styles vs Msg
viewList title notes =
    when (not (List.isEmpty notes)) <|
        column None
            [ center ]
            [ el None [] <| text <| title ++ ":"
            , column None [] <| List.map ((++) "- " >> text >> List.singleton >> paragraph None []) notes
            ]


viewTechList : String -> ({ r | name : String } -> Msg) -> List { r | name : String } -> Element Styles vs Msg
viewTechList title msg techs =
    when (List.length techs |> flip (>) 0) <|
        column None
            []
            [ el None [] <| text <| title ++ ":"
            , column None [] <|
                List.map
                    (\t ->
                        row None [] [ text "- ", el Link [ onClick <| msg t ] <| text t.name ]
                    )
                    techs
            ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddSubmissionInput form ->
            ( { model | view = ViewAddSubmission form }, Cmd.none )

        Edit ->
            case model.view of
                ViewPosition s ->
                    ( { model | view = ViewPosition <| Editable.edit s }, Cmd.none )

                ViewTransition t ->
                    ( { model | view = ViewTransition <| Editable.edit t }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        EditChange view ->
            ( { model | view = view }, Cmd.none )

        NewTransitionInput form ->
            ( { model | view = ViewNewTransition form }, Cmd.none )

        SelectPosition p ->
            ( { model | view = ViewPosition (Editable.ReadOnly p) }, Cmd.none )

        SelectSubmission s ->
            ( { model | view = ViewSubmission s }, Cmd.none )

        SelectTransition t ->
            ( { model | view = ViewTransition (Editable.ReadOnly t) }, Cmd.none )

        SelectNotes ->
            ( { model | view = ViewNotes }, Cmd.none )

        Reset ->
            ( { model | view = ViewAll }, Cmd.none )

        CbData res ->
            case res of
                Ok { transitions, positions, submissions, topics } ->
                    ( { model
                        | transitions = listToDict transitions
                        , positions = listToDict positions
                        , submissions = listToDict submissions
                        , topics = topics
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        Save ->
            case model.view of
                ViewPosition p ->
                    if Editable.isDirty p then
                        ( model
                        , Task.attempt SavePosition (GQLH.sendMutation model.url (updatePostition (Editable.value p)))
                        )
                    else
                        ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewTransition t ->
                    if Editable.isDirty t then
                        ( model
                        , Task.attempt SaveTransition (GQLH.sendMutation model.url (updateTransition (Editable.value t)))
                        )
                    else
                        ( { model | view = ViewTransition <| Editable.cancel t }, Cmd.none )

                ViewNewTransition form ->
                    ( model, Task.attempt SaveTransition (GQLH.sendMutation model.url (createTransition form)) )

                _ ->
                    ( model, Cmd.none )

        Cancel ->
            case model.view of
                ViewPosition p ->
                    ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewNewTransition { startPosition } ->
                    ( { model | view = ViewPosition <| Editable.ReadOnly startPosition }, Cmd.none )

                ViewAddSubmission { position } ->
                    ( { model | view = ViewPosition <| Editable.ReadOnly position }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SavePosition res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewPosition <| Editable.ReadOnly data
                        , positions = set data.id data model.positions
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        SaveTransition res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewTransition <| Editable.ReadOnly data
                        , transitions = set data.id data model.transitions
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        AddTransition p ->
            ( { model
                | view =
                    ViewNewTransition
                        { name = ""
                        , startPosition = p
                        , endPosition = Waiting
                        , steps = Array.empty
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        AddSubmission p ->
            ( { model
                | view =
                    ViewAddSubmission
                        { name = ""
                        , position = p
                        , steps = Array.empty
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )



-- STYLING


styling : StyleSheet Styles vs
styling =
    let
        pointer =
            Style.cursor "pointer"
    in
        styleSheet
            [ style None []
            , style SetBox
                [ Border.all 2
                , Border.solid
                ]
            , style Button
                [ Border.all 2
                , Border.solid
                , Border.rounded 15
                , pointer
                ]
            , style Body [ Font.typeface [ Font.font "Cuprum", Font.sansSerif ], Font.size 25 ]
            , style Link [ Font.underline, pointer ]
            , style Line [ Color.background black ]
            ]



-- HELPERS


set : Id -> { r | id : Id } -> Dict String { r | id : Id } -> Dict String { r | id : Id }
set (Id id) =
    Dict.insert id


get : Id -> Dict String { r | id : Id } -> Maybe { r | id : Id }
get (Id id) =
    Dict.get id


unwrap : b -> (a -> b) -> Maybe a -> b
unwrap default fn =
    Maybe.map fn
        >> Maybe.withDefault default


unwrap2 : c -> Maybe a -> Maybe b -> (a -> b -> c) -> c
unwrap2 c maybeA maybeB fn =
    Maybe.map2 fn maybeA maybeB
        |> Maybe.withDefault c


log : a -> Cmd Msg
log a =
    let
        _ =
            Debug.log "Log" a
    in
        Cmd.none


listToDict : List { r | id : Id } -> Dict String { r | id : Id }
listToDict =
    List.foldl
        (\r ->
            let
                (Id id) =
                    r.id
            in
                Dict.insert id r
        )
        Dict.empty



-- DATA


fetchData : GQLB.Request GQLB.Query AllData
fetchData =
    GQLB.object AllData
        |> GQLB.with (GQLB.field "allTransitions" [] (GQLB.list transition))
        |> GQLB.with (GQLB.field "allPositions" [] (GQLB.list position))
        |> GQLB.with (GQLB.field "allSubmissions" [] (GQLB.list submission))
        |> GQLB.with (GQLB.field "allTopics" [] (GQLB.list topic))
        |> GQLB.queryDocument
        |> GQLB.request ()


createTransition : NewTransitionForm -> GQLB.Request GQLB.Mutation Transition
createTransition { name, steps, notes, startPosition, endPosition } =
    let
        (Id startId) =
            startPosition.id

        (Id endId) =
            case endPosition of
                Picked a ->
                    a.id

                Waiting ->
                    Id ""

                Picking ->
                    Id ""
    in
        transition
            |> GQLB.field "createTransition"
                [ ( "name", Arg.string name )
                , ( "startPositionId", Arg.string startId )
                , ( "endPositionId", Arg.string endId )
                , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string notes )
                , ( "steps", Arg.list <| Array.toList <| Array.map Arg.string steps )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()


updateTransition : Transition -> GQLB.Request GQLB.Mutation Transition
updateTransition t =
    let
        (Id id) =
            t.id
    in
        transition
            |> GQLB.field "updateTransition"
                [ ( "id", Arg.string id )
                , ( "name", Arg.string t.name )
                , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string t.notes )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()


updatePostition : Position -> GQLB.Request GQLB.Mutation Position
updatePostition p =
    let
        (Id id) =
            p.id
    in
        position
            |> GQLB.field "updatePosition"
                [ ( "id", Arg.string id )
                , ( "name", Arg.string p.name )
                , ( "notes", Arg.list <| Array.toList <| Array.map Arg.string p.notes )
                ]
            |> GQLB.extract
            |> GQLB.mutationDocument
            |> GQLB.request ()


topic : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Topic vars
topic =
    GQLB.object Topic
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "content" [] (GQLB.list GQLB.string))


position : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Position vars
position =
    GQLB.object Position
        |> GQLB.with (GQLB.field "id" [] (GQLB.id |> GQLB.map Id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))


submission : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Submission vars
submission =
    GQLB.object Submission
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string))
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string))
        |> GQLB.with
            (GQLB.field "position"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )


transition : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Transition vars
transition =
    GQLB.object Transition
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with
            (GQLB.field "startPosition"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )
        |> GQLB.with
            (GQLB.field "endPosition"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string |> GQLB.map Array.fromList))
