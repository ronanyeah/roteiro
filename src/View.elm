module View exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Editable exposing (Editable)
import Element exposing (Element, column, el, empty, paragraph, row, text, viewport, when)
import Element.Attributes exposing (center, class, fill, height, maxWidth, padding, px, spacing, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import Html exposing (Html)
import Styling exposing (styling)
import Types exposing (..)
import Utils exposing (get, unwrap, unwrap2)


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
                                , onClick <| SelectTopics
                                ]
                             <|
                                text "Notes"
                           , el Button
                                [ padding 10
                                , onClick <| CreatePosition
                                ]
                             <|
                                text "Add Position"
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
                                    , onClick <| CreateTransition p
                                    ]
                                  <|
                                    text "Add Transition"
                                , viewTechList "Submissions" SelectSubmission submissions
                                , el Button
                                    [ padding 10
                                    , onClick <| CreateSubmission p
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

                ViewTopics maybeEdit ->
                    case maybeEdit of
                        Just topic ->
                            [ Input.text
                                None
                                []
                                { onChange =
                                    \str ->
                                        InputTopic { topic | name = str }
                                , value = topic.name
                                , label = Input.labelAbove <| text "Name:"
                                , options = []
                                }
                            ]
                                ++ (notesEditor topic InputTopic)

                        Nothing ->
                            model.topics
                                |> Array.map viewTopic
                                |> Array.toList
                                |> (::) resetButton

                ViewCreateTransition ({ notes, steps, name, startPosition, endPosition } as form) ->
                    [ Input.text
                        None
                        []
                        { onChange =
                            \str ->
                                InputCreateTransition { form | name = str }
                        , value = name
                        , label = Input.labelAbove <| text "Name:"
                        , options = []
                        }
                    , text <| "Start Position: " ++ startPosition.name
                    , case endPosition of
                        Waiting ->
                            el None [ onClick <| InputCreateTransition { form | endPosition = Picking } ] <| text "Select A Position"

                        Picked endP ->
                            el None [ onClick <| InputCreateTransition { form | endPosition = Picking } ] <| text <| "End Position: " ++ endP.name

                        Picking ->
                            model.positions
                                |> Dict.values
                                |> List.map
                                    (\p ->
                                        el None [ onClick <| InputCreateTransition { form | endPosition = Picked p } ] <| text p.name
                                    )
                                |> column None []
                    ]
                        ++ (notesEditor form InputCreateTransition)
                        ++ (stepsEditor form InputCreateTransition)
                        ++ [ saveButton
                           , cancelButton
                           ]

                ViewCreateSubmission ({ notes, steps, name, position } as form) ->
                    [ text "Name:"
                    , Input.text
                        None
                        []
                        { onChange =
                            \str ->
                                InputCreateSubmission { form | name = str }
                        , value = name
                        , label = Input.labelAbove <| text "Name:"
                        , options = []
                        }
                    ]
                        ++ notesEditor form InputCreateSubmission
                        ++ stepsEditor form InputCreateSubmission
                        ++ [ saveButton
                           , cancelButton
                           ]

                ViewCreatePosition form ->
                    [ Input.text
                        None
                        []
                        { onChange =
                            \str ->
                                InputCreatePosition { form | name = str }
                        , value = form.name
                        , label = Input.labelAbove <| text "Name:"
                        , options = []
                        }
                    ]
                        ++ notesEditor form InputCreatePosition
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
viewTopic { name, notes } =
    column None
        [ center, maxWidth <| px 500 ]
        [ row None [] [ el None [] <| text <| name ++ ":", el None [ class "fa fa-edit" ] empty ]
        , column None [] <| List.map ((++) "- " >> text >> List.singleton >> paragraph None []) <| Array.toList notes
        ]


viewSteps : List String -> Element Styles vs Msg
viewSteps =
    List.indexedMap
        (\i step ->
            paragraph None
                []
                [ Element.bold <| (toString (i + 1) ++ ".")
                , text <| " " ++ step
                ]
        )
        >> column None [ maxWidth <| px 700 ]


viewList : String -> List String -> Element Styles vs Msg
viewList title notes =
    when (not (List.isEmpty notes)) <|
        column None
            [ center, maxWidth <| px 500 ]
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
