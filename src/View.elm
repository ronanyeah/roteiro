module View exposing (..)

import Array exposing (Array)
import Dict
import Editable
import Element exposing (Element, column, el, empty, layout, link, modal, newTab, paragraph, row, text, when, whenJust)
import Element.Attributes exposing (center, class, fill, height, maxWidth, padding, px, spacing, verticalCenter, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import Html exposing (Html)
import Regex exposing (Regex)
import Styling exposing (styling)
import Types exposing (..)
import Utils exposing (get, unwrap, unwrap2)


matchLink : Regex
matchLink =
    Regex.regex
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$"


matchDomain : Regex
matchDomain =
    Regex.regex
        "(?:[-a-zA-Z0-9@:%_\\+~.#=]{2,256}\\.)?([-a-zA-Z0-9@:%_\\+~#=]*)\\.[a-z]{2,6}\\b(?:[-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)"


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewAll ->
                    (case
                        model.positions
                            |> Dict.values
                     of
                        [] ->
                            []

                        xs ->
                            xs
                                |> List.map
                                    (\p ->
                                        case p.id of
                                            Id id ->
                                                link ("/#/p/" ++ id) <|
                                                    el Choice [] <|
                                                        text p.name
                                    )
                                |> flip (++)
                                    [ plus CreatePosition
                                    , el Line [ width <| px 100, height <| px 2 ] empty
                                    ]
                    )
                        ++ [ link "/#/ts" <|
                                el Topics
                                    [ padding 10
                                    , class "fa fa-book"
                                    ]
                                    empty
                           ]

                ViewCreateTopic form ->
                    [ el Title [ center ] <| text "CREATE TOPIC"
                    , nameEdit form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewCreateTransition form ->
                    [ nameEdit form FormUpdate
                    , pickStartPosition form
                    , pickEndPosition form
                    , stepsEditor form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewCreateSubmission form ->
                    [ nameEdit form FormUpdate
                    , pickStartPosition form
                    , stepsEditor form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewCreatePosition form ->
                    [ nameEdit form FormUpdate
                    , notesEditor form FormUpdate
                    , saveCancel
                    ]

                ViewPosition data ->
                    case data of
                        Editable.Editable _ position ->
                            [ deleteButton <| DeletePosition position.id
                            , nameEdit position EditPosition
                            , notesEditor position EditPosition
                            , saveCancel
                            ]

                        Editable.ReadOnly ({ id, notes } as p) ->
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
                                [ editRow p EditPosition
                                , viewNotes notes
                                , el Line [ width <| px 100, height <| px 2 ] empty
                                , el MattIcon
                                    [ class "fa fa-long-arrow-right"
                                    ]
                                    empty
                                , viewTechList "t" transitions
                                , plus <| CreateTransition p
                                , el Line [ width <| px 100, height <| px 2 ] empty
                                , el MattIcon
                                    [ class "fa fa-bolt"
                                    ]
                                    empty
                                , viewTechList "s" submissions
                                , plus <| CreateSubmission p
                                ]

                ViewSubmission data ->
                    case data of
                        Editable.Editable _ submission ->
                            [ deleteButton <| DeleteSubmission submission.id
                            , nameEdit submission EditSubmission
                            , model.positions
                                |> Dict.get (submission.position |> (\(Id id) -> id))
                                |> flip whenJust
                                    (\p ->
                                        row None
                                            [ spacing 10 ]
                                            [ el MattIcon
                                                [ class "fa fa-flag-checkered"
                                                ]
                                                empty
                                            , el None
                                                [ onClick <|
                                                    ChoosePosition
                                                        (\{ id } ->
                                                            EditSubmission { submission | position = id }
                                                        )
                                                ]
                                              <|
                                                text p.name
                                            ]
                                    )
                            , notesEditor submission EditSubmission
                            , stepsEditor submission EditSubmission
                            , saveCancel
                            ]

                        Editable.ReadOnly ({ steps, position, notes } as s) ->
                            get position model.positions
                                |> unwrap oopsView
                                    (\p ->
                                        [ editRow s EditSubmission
                                        , row None
                                            [ spacing 10 ]
                                            [ el MattIcon
                                                [ class "fa fa-bolt"
                                                ]
                                                empty
                                            , link (p.id |> (\(Id id) -> id) |> (++) "/#/ps/") <| el Link [] <| text p.name
                                            ]
                                        , viewSteps steps
                                        , viewNotes notes
                                        ]
                                    )

                ViewTransition data ->
                    case data of
                        Editable.Editable _ transition ->
                            [ nameEdit transition EditTransition
                            , unwrap2 empty
                                (get transition.startPosition model.positions)
                                (get transition.endPosition model.positions)
                                (\start end ->
                                    row None
                                        [ verticalCenter, spacing 10 ]
                                        [ deleteButton <| DeleteTransition transition.id
                                        , el Link
                                            [ onClick <|
                                                ChoosePosition
                                                    (\{ id } ->
                                                        EditTransition { transition | startPosition = id }
                                                    )
                                            ]
                                          <|
                                            text start.name
                                        , el MattIcon
                                            [ class "fa fa-long-arrow-right"
                                            ]
                                            empty
                                        , el Link
                                            [ onClick <|
                                                ChoosePosition
                                                    (\{ id } ->
                                                        EditTransition { transition | endPosition = id }
                                                    )
                                            ]
                                          <|
                                            text end.name
                                        ]
                                )
                            , notesEditor transition EditTransition
                            , stepsEditor transition EditTransition
                            , saveCancel
                            ]

                        Editable.ReadOnly ({ steps, startPosition, endPosition, notes } as t) ->
                            unwrap2 oopsView
                                (get startPosition model.positions)
                                (get endPosition model.positions)
                                (\start end ->
                                    [ editRow t EditTransition
                                    , row None
                                        [ verticalCenter, spacing 10 ]
                                        [ link (start.id |> (\(Id id) -> id) |> (++) "/#/ps/") <| el Link [] <| text start.name
                                        , el MattIcon
                                            [ class "fa fa-long-arrow-right"
                                            ]
                                            empty
                                        , link (end.id |> (\(Id id) -> id) |> (++) "/#/ps/") <|
                                            el Link [] <|
                                                text end.name
                                        ]
                                    , viewSteps steps
                                    , viewNotes notes
                                    ]
                                )

                ViewTopics maybeEdit ->
                    model.topics
                        |> Dict.values
                        |> List.map
                            (\({ id, notes } as topic) ->
                                case
                                    maybeEdit
                                        |> Maybe.andThen
                                            (\e ->
                                                if e.id == id then
                                                    Just e
                                                else
                                                    Nothing
                                            )
                                of
                                    Just edit ->
                                        column None
                                            [ center, maxWidth <| px 500 ]
                                            [ deleteButton <| DeleteTopic id
                                            , nameEdit edit EditTopic
                                            , notesEditor edit EditTopic
                                            , saveCancel
                                            ]

                                    Nothing ->
                                        column None
                                            [ center, maxWidth <| px 500 ]
                                            [ editRow topic EditTopic
                                            , viewNotes notes
                                            ]
                            )
                        |> flip (++) [ plus CreateTopic ]

        roteiro =
            row None
                [ center, spacing 10, verticalCenter ]
                [ link "/#/ps" <| el Header [] <| text "ROTEIRO"
                , el Icon
                    [ padding 10
                    , class "fa fa-lock"
                    , onClick <| TokenEdit <| Just ""
                    ]
                    empty
                ]

        enterToken =
            whenJust model.tokenForm
                (\str ->
                    modal ChooseBox [ center, verticalCenter, padding 10 ] <|
                        column None
                            [ center ]
                            [ Input.text
                                None
                                [ maxWidth <| px 300 ]
                                { onChange = Just >> TokenEdit
                                , value = str
                                , label =
                                    Input.labelAbove <|
                                        el BigIcon
                                            [ class "fa fa-lock"
                                            , center
                                            ]
                                            empty
                                , options = []
                                }
                            , el PickerCancel
                                [ onClick <| TokenEdit Nothing
                                , class "fa fa-times"
                                ]
                                empty
                            ]
                )

        picker =
            case model.choosingPosition of
                Just msg ->
                    case model.device of
                        Mobile ->
                            modal Picker [ width fill ] <|
                                column None
                                    [ center, width fill, spacing 30 ]
                                    (Dict.values model.positions
                                        |> List.map
                                            (\p ->
                                                el Choice [ onClick <| msg p ] <| text p.name
                                            )
                                        |> (::)
                                            (el BigIcon
                                                [ padding 10
                                                , class "fa fa-question"
                                                ]
                                                empty
                                            )
                                        |> flip (++)
                                            [ el PickerCancel
                                                [ onClick CancelPicker
                                                , class "fa fa-times"
                                                ]
                                                empty
                                            , el Line [ width fill, height <| px 3 ] empty
                                            ]
                                    )

                        Desktop ->
                            modal ChooseBox [ center, verticalCenter ] <|
                                column None [ center, width fill, spacing 30, padding 50 ] <|
                                    (Dict.values model.positions
                                        |> List.map
                                            (\p ->
                                                el Choice [ onClick <| msg p ] <| text p.name
                                            )
                                        |> (::)
                                            (el BigIcon
                                                [ padding 10
                                                , class "fa fa-question"
                                                ]
                                                empty
                                            )
                                        |> flip (++)
                                            [ el PickerCancel
                                                [ onClick CancelPicker
                                                , class "fa fa-times"
                                                ]
                                                empty
                                            ]
                                    )

                Nothing ->
                    empty
    in
        Html.div []
            [ Html.node "style"
                []
                [ Html.text """
                    body { background-color: #B63730; }
                    .style-elements .fa { font-family: FontAwesome; }
                  """
                ]
            , layout styling <|
                column Body
                    [ height fill
                    , center
                    , width fill
                    , spacing 30
                    , padding 30
                    ]
                    (enterToken :: picker :: roteiro :: content)
            ]


pickStartPosition : Form -> Element Styles vs Msg
pickStartPosition form =
    case form.startPosition of
        Nothing ->
            el None [ onClick <| ChoosePosition <| \p -> FormUpdate { form | startPosition = Just p } ] <| text "Select A Position"

        Just { name } ->
            el None [ onClick <| ChoosePosition <| \p -> FormUpdate { form | startPosition = Just p } ] <| text <| "Start Position: " ++ name


pickEndPosition : Form -> Element Styles vs Msg
pickEndPosition form =
    case form.endPosition of
        Nothing ->
            el None [ onClick <| ChoosePosition <| \p -> FormUpdate { form | endPosition = Just p } ] <| text "Select A Position"

        Just endP ->
            el None [ onClick <| ChoosePosition <| \p -> FormUpdate { form | endPosition = Just p } ] <| text <| "End Position: " ++ endP.name


editRow : { r | name : String, id : Id } -> ({ r | name : String, id : Id } -> msg) -> Element Styles vs msg
editRow r msg =
    paragraph None
        [ spacing 5, verticalCenter ]
        [ el Subtitle [] <| text r.name
        , el Icon
            [ padding 10
            , class "fa fa-edit"
            , onClick <| msg r
            ]
            empty
        ]


deleteButton : Msg -> Element Styles vs Msg
deleteButton msg =
    el Icon
        [ padding 10
        , class "fa fa-trash"
        , onClick msg
        ]
        empty


nameEdit : { r | name : String } -> ({ r | name : String } -> Msg) -> Element Styles vs Msg
nameEdit r msg =
    Input.text
        None
        [ maxWidth <| px 300, center ]
        { onChange = \str -> msg { r | name = str }
        , value = r.name
        , label = Input.labelAbove <| el Title [] <| text "NAME"
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
    row ChooseBox
        [ spacing 20 ]
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
            [ spacing 10 ]
            [ el BigIcon [ class "fa fa-cogs", center ] empty
            , steps
            , buttons
            ]


notesEditor : { r | notes : Array String } -> ({ r | notes : Array String } -> Msg) -> Element Styles vs Msg
notesEditor form msg =
    let
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
            [ spacing 10 ]
            [ el BigIcon [ class "fa fa-sticky-note-o", center ] empty
            , notes
            , buttons
            ]


oopsView : List (Element Styles vs Msg)
oopsView =
    [ text "oops!" ]


viewSteps : Array String -> Element Styles vs Msg
viewSteps steps =
    when (not (Array.isEmpty steps)) <|
        (steps
            |> Array.toList
            |> List.indexedMap
                (\i step ->
                    paragraph None
                        []
                        [ el Dot [] <| text <| (toString (i + 1) ++ ".")
                        , text <| " " ++ step
                        ]
                )
            |> column None [ maxWidth <| px 700 ]
        )


viewNotes : Array String -> Element Styles vs msg
viewNotes =
    Array.toList
        >> List.map
            (\x ->
                if Regex.contains matchLink x then
                    paragraph None
                        [ spacing 5 ]
                        [ el Dot [] <| text "• "
                        , newTab x <|
                            row None
                                [ spacing 5 ]
                                [ el MattIcon
                                    [ class "fa fa-globe"
                                    ]
                                    empty
                                , text <| domain x
                                ]
                        ]
                else
                    paragraph None [] [ el Dot [] <| text "• ", text x ]
            )
        >> column None [ center, maxWidth <| px 500 ]


viewTechList : String -> List { r | name : String, id : Id } -> Element Styles vs Msg
viewTechList x xs =
    if List.isEmpty xs then
        el None [] <| text "None!"
    else
        xs
            |> List.map
                (\t ->
                    case t.id of
                        Id id ->
                            row None
                                []
                                [ el Dot [] <| text "• "
                                , link ("/#/" ++ x ++ "/" ++ id) <|
                                    el Link [] <|
                                        text t.name
                                ]
                )
            |> column None []


domain : String -> String
domain s =
    Regex.find (Regex.AtMost 10) matchDomain s
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
        |> Maybe.withDefault s
