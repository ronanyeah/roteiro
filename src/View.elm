module View exposing (..)

import Array exposing (Array)
import Dict
import Editable
import Element exposing (Element, column, el, empty, header, paragraph, row, text, viewport, when)
import Element.Attributes exposing (center, class, fill, height, maxWidth, padding, px, spacing, verticalCenter, width)
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
                        ++ [ plus CreatePosition
                           , el Line [ width <| px 100, height <| px 2 ] empty
                           , el Topics
                                [ padding 10
                                , onClick <| SelectTopics
                                , class "fa fa-book"
                                ]
                                empty
                           ]

                ViewCreateTopic form ->
                    [ el Title [ center ] <| text "CREATE TOPIC"
                    , textEdit form.name
                        (\str ->
                            FormUpdate { form | name = str }
                        )
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewCreateTransition ({ name, startPosition, endPosition } as form) ->
                    [ textEdit name
                        (\str ->
                            FormUpdate { form | name = str }
                        )
                    , case startPosition of
                        Waiting ->
                            el None [ onClick <| FormUpdate { form | startPosition = Picking } ] <| text "Select A Position"

                        Picked endP ->
                            el None [ onClick <| FormUpdate { form | startPosition = Picking } ] <| text <| "Start Position: " ++ endP.name

                        Picking ->
                            model.positions
                                |> Dict.values
                                |> List.map
                                    (\p ->
                                        el None [ onClick <| FormUpdate { form | startPosition = Picked p } ] <| text p.name
                                    )
                                |> column None []
                    , case endPosition of
                        Waiting ->
                            el None [ onClick <| FormUpdate { form | endPosition = Picking } ] <| text "Select A Position"

                        Picked endP ->
                            el None [ onClick <| FormUpdate { form | endPosition = Picking } ] <| text <| "End Position: " ++ endP.name

                        Picking ->
                            model.positions
                                |> Dict.values
                                |> List.map
                                    (\p ->
                                        el None [ onClick <| FormUpdate { form | endPosition = Picked p } ] <| text p.name
                                    )
                                |> column None []
                    , stepsEditor form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewCreateSubmission form ->
                    [ textEdit form.name
                        (\str ->
                            FormUpdate { form | name = str }
                        )
                    , stepsEditor form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewCreatePosition form ->
                    [ textEdit form.name
                        (\str ->
                            FormUpdate { form | name = str }
                        )
                    , stepsEditor form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewEditTopic topic ->
                    [ el Title [ center ] <| text "EDIT TOPIC"
                    , textEdit topic.name
                        (\str ->
                            EditTopic { topic | name = str }
                        )
                    , notesEditor topic EditTopic
                    , saveCancel
                    ]

                ViewPosition data ->
                    case data of
                        Editable.Editable _ position ->
                            [ textEdit
                                position.name
                                (\str ->
                                    EditChange <|
                                        ViewPosition <|
                                            Editable.map
                                                (\r ->
                                                    { r | name = str }
                                                )
                                            <|
                                                data
                                )
                            , notesEditor position
                                (\r ->
                                    EditChange <|
                                        ViewPosition <|
                                            Editable.map (always r) <|
                                                data
                                )
                            , saveCancel
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
                                [ editButton
                                , el None [] <| text name
                                , viewNotes notes
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

                ViewSubmission data ->
                    case data of
                        Editable.ReadOnly { name, steps, position, notes } ->
                            get position model.positions
                                |> unwrap oopsView
                                    (\p ->
                                        [ row None
                                            []
                                            [ text (name ++ " from ")
                                            , el Link [ onClick <| SelectPosition p ] <| text p.name
                                            ]
                                        , viewSteps steps
                                        , viewNotes notes
                                        ]
                                    )

                        Editable.Editable _ submission ->
                            [ textEdit
                                submission.name
                                (\str ->
                                    EditChange <|
                                        ViewSubmission <|
                                            Editable.map (\r -> { r | name = str }) <|
                                                data
                                )
                            , notesEditor submission
                                (\r ->
                                    EditChange <|
                                        ViewSubmission <|
                                            Editable.map (always r) <|
                                                data
                                )
                            , stepsEditor submission
                                (\r ->
                                    EditChange <|
                                        ViewSubmission <|
                                            Editable.map (always r) <|
                                                data
                                )
                            , saveCancel
                            ]

                ViewTransition data ->
                    case data of
                        Editable.Editable _ transition ->
                            [ textEdit
                                transition.name
                                (\str ->
                                    EditChange <|
                                        ViewTransition <|
                                            Editable.map (\r -> { r | name = str }) <|
                                                data
                                )
                            , notesEditor transition
                                (\r ->
                                    EditChange <|
                                        ViewTransition <|
                                            Editable.map (always r) <|
                                                data
                                )
                            , stepsEditor transition
                                (\r ->
                                    EditChange <|
                                        ViewTransition <|
                                            Editable.map (always r) <|
                                                data
                                )
                            , saveCancel
                            ]

                        Editable.ReadOnly { name, steps, startPosition, endPosition, notes } ->
                            unwrap2 oopsView
                                (get startPosition model.positions)
                                (get endPosition model.positions)
                                (\start end ->
                                    [ editButton
                                    , row None
                                        []
                                        [ text (name ++ " from ")
                                        , el Link [ onClick <| SelectPosition start ] <| text start.name
                                        ]
                                    , viewSteps steps
                                    , viewNotes notes
                                    , row None
                                        []
                                        [ text "Transitions to: "
                                        , el Link [ onClick <| SelectPosition end ] <|
                                            text end.name
                                        ]
                                    ]
                                )

                ViewTopics ->
                    model.topics
                        |> Dict.values
                        |> List.map viewTopic
                        |> (::) (plus CreateTopic)

        roteiro =
            header None [] <| el Header [ center, onClick Reset ] <| text "ROTEIRO"
    in
        viewport styling <|
            column Body [ height fill, center, width fill, spacing 30, padding 30 ] (roteiro :: content)


textEdit : String -> (String -> msg) -> Element Styles vs msg
textEdit value msg =
    Input.text
        None
        [ maxWidth <| px 300, center ]
        { onChange = msg
        , value = value
        , label = Input.labelAbove <| el Title [ center ] <| text "NAME"
        , options = []
        }


plus : msg -> Element Styles vs msg
plus msg =
    el Icon
        [ padding 10
        , onClick msg
        , class "fa fa-plus"
        ]
        empty


minus : msg -> Element Styles vs msg
minus msg =
    el Icon
        [ padding 10
        , onClick msg
        , class "fa fa-minus"
        ]
        empty


saveCancel : Element Styles vs Msg
saveCancel =
    row None
        []
        [ el Icon
            [ padding 10
            , onClick Save
            , class "fa fa-check"
            ]
            empty
        , el Icon
            [ padding 10
            , onClick Cancel
            , class "fa fa-times"
            ]
            empty
        ]


stepsEditor : { r | steps : Array String } -> ({ r | steps : Array String } -> Msg) -> Element Styles vs Msg
stepsEditor form msg =
    let
        title =
            el Title [ center ] <| text "STEPS"

        steps =
            column None
                [ spacing 10 ]
                (form.steps
                    |> Array.indexedMap
                        (\i v ->
                            Input.multiline
                                None
                                []
                                { onChange = \str -> msg { form | steps = Array.set i str form.steps }
                                , value = v
                                , label = Input.hiddenLabel ""
                                , options = []
                                }
                        )
                    |> Array.toList
                )

        buttons =
            row None
                [ center ]
                [ plus (msg { form | steps = Array.push "" form.steps })
                , when (not <| Array.isEmpty form.steps) <|
                    minus (msg { form | steps = Array.slice 0 -1 form.steps })
                ]
    in
        column None
            []
            [ title
            , steps
            , buttons
            ]


notesEditor : { r | notes : Array String } -> ({ r | notes : Array String } -> Msg) -> Element Styles vs Msg
notesEditor form msg =
    let
        title =
            el Title [ center ] <| text "NOTES"

        notes =
            column None
                [ spacing 10 ]
                (form.notes
                    |> Array.indexedMap
                        (\i v ->
                            Input.multiline
                                None
                                []
                                { onChange = \str -> msg { form | notes = Array.set i str form.notes }
                                , value = v
                                , label = Input.hiddenLabel ""
                                , options = []
                                }
                        )
                    |> Array.toList
                )

        buttons =
            row None
                [ center ]
                [ plus (msg { form | notes = Array.push "" form.notes })
                , when (not <| Array.isEmpty form.notes) <|
                    minus (msg { form | notes = Array.slice 0 -1 form.notes })
                ]
    in
        column None
            []
            [ title
            , notes
            , buttons
            ]


editButton : Element Styles vs Msg
editButton =
    el Button
        [ padding 10
        , onClick Edit
        , class "fa fa-edit"
        ]
        empty


oopsView : List (Element Styles vs Msg)
oopsView =
    [ text "oops!" ]


viewTopic : Topic -> Element Styles vs Msg
viewTopic ({ name, notes } as topic) =
    column None
        [ center, maxWidth <| px 500 ]
        [ row None
            [ spacing 50, verticalCenter ]
            [ el Subtitle [] <| text name
            , el Icon [ padding 10, class "fa fa-edit", onClick <| EditTopic topic ] empty
            ]
        , column None [] <| List.map ((++) "- " >> text >> List.singleton >> paragraph None []) <| Array.toList notes
        ]


viewSteps : Array String -> Element Styles vs Msg
viewSteps steps =
    when (not (Array.isEmpty steps)) <|
        (steps
            |> Array.toList
            |> List.indexedMap
                (\i step ->
                    paragraph None
                        []
                        [ Element.bold <| (toString (i + 1) ++ ".")
                        , text <| " " ++ step
                        ]
                )
            |> (::) (el Title [] <| text "STEPS")
            |> column None [ maxWidth <| px 700 ]
        )


viewNotes : Array String -> Element Styles vs Msg
viewNotes notes =
    when (not (Array.isEmpty notes)) <|
        column None
            [ center, maxWidth <| px 500 ]
            [ el Title [] <| text "NOTES"
            , column None [] <|
                List.map ((++) "- " >> text >> List.singleton >> paragraph None [])
                    (notes |> Array.toList)
            ]


viewTechList : String -> ({ r | name : String } -> Msg) -> List { r | name : String } -> Element Styles vs Msg
viewTechList title msg techs =
    when (not (List.isEmpty techs)) <|
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
