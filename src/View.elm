module View exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Element exposing (Element, circle, column, decorativeImage, el, empty, layout, link, modal, newTab, paragraph, row, screen, text, when, whenJust)
import Element.Attributes exposing (alignBottom, attribute, center, class, fill, height, maxWidth, moveDown, padding, px, spacing, spread, vary, verticalCenter, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import Html exposing (Html)
import Regex exposing (Regex)
import Styling exposing (styling)
import Types exposing (Device(..), Form, Id(..), Model, Msg(..), Picker(..), Position, Styles(..), Variations(..), View(..))
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
view ({ form } as model) =
    let
        content =
            case model.view of
                ViewAll ->
                    case model.device of
                        Mobile ->
                            column None
                                [ center, spacing 20, moveDown 200 ]
                                [ decorativeImage None
                                    [ onClick <| TokenEdit <| Just ""
                                    , height <| px 100
                                    , width <| px 100
                                    ]
                                    { src = "/map.svg" }
                                , el Home [] <| text "Roteiro"
                                ]

                        Desktop ->
                            column None
                                [ center ]
                                [ link "/#/ps" <|
                                    el Topics
                                        [ padding 10
                                        , class "fa fa-flag-checkered"
                                        ]
                                        empty
                                , link "/#/trs" <|
                                    el Topics
                                        [ padding 10
                                        , class "fa fa-long-arrow-right"
                                        ]
                                        empty
                                , link "/#/ss" <|
                                    el Topics
                                        [ padding 10
                                        , class "fa fa-bolt"
                                        ]
                                        empty
                                , link "/#/ts" <|
                                    el Topics
                                        [ padding 10
                                        , class "fa fa-book"
                                        ]
                                        empty
                                ]

                ViewCreateTopic ->
                    column None
                        [ center, spacing 20 ]
                        [ nameEdit form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewCreateTransition ->
                    column None
                        [ center, spacing 20 ]
                        [ nameEdit form
                        , row None
                            [ verticalCenter, spacing 10 ]
                            [ pickStartPosition model.positions form
                            , el MattIcon
                                [ class "fa fa-long-arrow-right"
                                ]
                                empty
                            , pickEndPosition model.positions form
                            ]
                        , stepsEditor form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewCreateSubmission ->
                    column None
                        [ center, spacing 20 ]
                        [ nameEdit form
                        , row None
                            [ spacing 10 ]
                            [ el MattIcon
                                [ class "fa fa-flag-checkered"
                                ]
                                empty
                            , pickStartPosition model.positions form
                            ]
                        , stepsEditor form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewCreatePosition ->
                    column None
                        [ center, spacing 20 ]
                        [ nameEdit form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewPosition editing position ->
                    column None [ center, spacing 20 ] <|
                        if editing then
                            [ nameEdit form
                            , notesEditor form
                            , buttons <| Just <| DeletePosition position.id
                            ]
                        else
                            let
                                ({ id, notes } as p) =
                                    position

                                transitions =
                                    model.transitions
                                        |> Dict.values
                                        |> List.filter (.startPosition >> (==) id)

                                submissions =
                                    model.submissions
                                        |> Dict.values
                                        |> List.filter (.position >> (==) id)
                            in
                                [ editRow p.name
                                , viewNotes notes
                                , el Line [ width <| px 100, height <| px 2 ] empty
                                , el MattIcon
                                    [ class "fa fa-long-arrow-right"
                                    ]
                                    empty
                                , viewTechList "t" transitions
                                , plus <| CreateTransition <| Just p
                                , el Line [ width <| px 100, height <| px 2 ] empty
                                , el MattIcon
                                    [ class "fa fa-bolt"
                                    ]
                                    empty
                                , viewTechList "s" submissions
                                , plus <| CreateSubmission <| Just p
                                ]

                ViewPositions ->
                    column None [ center, spacing 20 ] <|
                        (model.positions
                            |> Dict.values
                            |> List.map
                                (\p ->
                                    case p.id of
                                        Id id ->
                                            link ("/#/p/" ++ id) <|
                                                paragraph Choice
                                                    []
                                                    [ text p.name
                                                    ]
                                )
                            |> flip (++)
                                [ plus CreatePosition
                                ]
                        )

                ViewSubmission editing ({ notes, steps, position } as s) ->
                    column None [ center, spacing 20 ] <|
                        if editing then
                            [ nameEdit model.form
                            , whenEdit model.form
                            , row None
                                [ spacing 10 ]
                                [ el MattIcon
                                    [ class "fa fa-flag-checkered"
                                    ]
                                    empty
                                , pickStartPosition model.positions form
                                ]
                            , stepsEditor form
                            , notesEditor form
                            , buttons <| Just <| DeleteSubmission s.id
                            ]
                        else
                            get position model.positions
                                |> unwrap oopsView
                                    (\p ->
                                        [ editRow s.name
                                        , whenJust s.when text
                                        , row None
                                            [ spacing 10 ]
                                            [ el MattIcon
                                                [ class "fa fa-flag-checkered"
                                                ]
                                                empty
                                            , link (p.id |> (\(Id id) -> "/#/p/" ++ id)) <|
                                                el Link [] <|
                                                    text p.name
                                            ]
                                        , viewSteps steps
                                        , viewNotes notes
                                        ]
                                    )

                ViewSubmissions ->
                    column None [ center, spacing 20 ] <|
                        (model.submissions
                            |> Dict.values
                            |> List.map
                                (\s ->
                                    case s.id of
                                        Id id ->
                                            link ("/#/s/" ++ id) <|
                                                paragraph Choice
                                                    []
                                                    [ text s.name
                                                    ]
                                )
                            |> flip (++) [ plus <| CreateSubmission Nothing ]
                        )

                ViewTransition editing ({ steps, startPosition, endPosition, notes } as t) ->
                    column None [ center, spacing 20 ] <|
                        if editing then
                            [ nameEdit form
                            , paragraph None
                                [ verticalCenter, spacing 10 ]
                                [ pickStartPosition model.positions form
                                , el MattIcon
                                    [ class "fa fa-long-arrow-right"
                                    ]
                                    empty
                                , pickEndPosition model.positions form
                                ]
                            , stepsEditor form
                            , notesEditor form
                            , buttons <| Just <| DeleteTransition t.id
                            ]
                        else
                            unwrap2 oopsView
                                (get startPosition model.positions)
                                (get endPosition model.positions)
                                (\start end ->
                                    [ editRow t.name
                                    , paragraph None
                                        [ verticalCenter, spacing 10 ]
                                        [ link (start.id |> (\(Id id) -> "/#/p/" ++ id)) <|
                                            el Link [] <|
                                                text start.name
                                        , el MattIcon
                                            [ class "fa fa-long-arrow-right"
                                            ]
                                            empty
                                        , link (end.id |> (\(Id id) -> "/#/p/" ++ id)) <|
                                            el Link [] <|
                                                text end.name
                                        ]
                                    , viewSteps steps
                                    , viewNotes notes
                                    ]
                                )

                ViewTopics ->
                    column None [ center, spacing 20 ] <|
                        (model.topics
                            |> Dict.values
                            |> List.map
                                (\t ->
                                    case t.id of
                                        Id id ->
                                            link ("/#/to/" ++ id) <|
                                                el Choice [] <|
                                                    text t.name
                                )
                            |> flip (++) [ plus CreateTopic ]
                        )

                ViewTopic editing t ->
                    column None [ center, spacing 20 ] <|
                        if editing then
                            [ nameEdit form
                            , notesEditor form
                            , buttons <| Just <| DeleteTopic t.id
                            ]
                        else
                            [ editRow t.name
                            , viewNotes t.notes
                            , link "/#/ts" <|
                                el Topics
                                    [ padding 10
                                    , class "fa fa-book"
                                    ]
                                    empty
                            ]

                ViewTransitions ->
                    column None [ center, spacing 20 ] <|
                        (model.transitions
                            |> Dict.values
                            |> List.map
                                (\t ->
                                    case t.id of
                                        Id id ->
                                            link ("/#/t/" ++ id) <|
                                                el Choice [] <|
                                                    text t.name
                                )
                            |> flip (++) [ plus <| CreateTransition Nothing ]
                        )

        roteiro =
            when (not (model.view == ViewAll && model.device == Mobile)) <|
                row None
                    [ center, spacing 10, verticalCenter ]
                    [ link "/#/" <| el Header [ vary Small <| model.view /= ViewAll ] <| text "ROTEIRO"
                    , when (model.view == ViewAll) <|
                        el Icon
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
                                Field
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

        confirm =
            whenJust model.confirm
                (\msg ->
                    modal ChooseBox [ center, verticalCenter, padding 10, spacing 20 ] <|
                        column None
                            [ center ]
                            [ el BigIcon
                                [ center
                                , class "fa fa-question"
                                ]
                                empty
                            , row None
                                [ spacing 40 ]
                                [ el PickerCancel
                                    [ onClick msg
                                    , class "fa fa-check"
                                    ]
                                    empty
                                , el PickerCancel
                                    [ onClick <| Confirm Nothing
                                    , class "fa fa-times"
                                    ]
                                    empty
                                ]
                            ]
                )

        ball lnk clss =
            link lnk <|
                circle 40 Ball [] <|
                    el BallIcon
                        [ class <| "fa " ++ clss
                        , center
                        , verticalCenter
                        ]
                        empty

        balls =
            when (model.device == Mobile && Utils.notEditing model.view) <|
                screen <|
                    el None [ alignBottom, width fill ] <|
                        row None
                            [ spread, width fill, padding 10 ]
                            [ ball "/#/ps" "fa-flag-checkered"
                            , ball "/#/trs" "fa-long-arrow-right"
                            , ball "/#/ss" "fa-bolt"
                            , ball "/#/ts" "fa-book"
                            ]

        ws =
            case model.device of
                Desktop ->
                    30

                Mobile ->
                    10
    in
        layout styling <|
            column Body
                [ height fill
                , center
                , width fill
                , spacing 20
                , padding ws
                ]
                [ enterToken
                , balls
                , confirm
                , roteiro
                , content
                , el None
                    [ height <|
                        px <|
                            if model.device == Mobile then
                                100
                            else
                                0
                    ]
                    empty
                ]


pickStartPosition : Dict String Position -> Form -> Element Styles vs Msg
pickStartPosition positions form =
    case form.startPosition of
        Pending ->
            el Icon
                [ center
                , class "fa fa-question"
                , onClick <|
                    Update
                        { form
                            | startPosition =
                                Picking <|
                                    Input.autocomplete Nothing UpdateStartPosition
                        }
                ]
                empty

        Picking state ->
            Input.select None
                []
                { label = Input.hiddenLabel "sub"
                , with = state
                , max = 5
                , options = []
                , menu =
                    Input.menu None
                        []
                        (positions
                            |> Dict.values
                            |> List.map
                                (\p ->
                                    Input.choice p <| text p.name
                                )
                        )
                }

        Picked position ->
            positions
                |> Dict.get (position |> .id |> (\(Id id) -> id))
                |> flip whenJust
                    (\p ->
                        paragraph Link
                            [ onClick <|
                                Update
                                    { form
                                        | startPosition =
                                            Picking <|
                                                Input.autocomplete Nothing UpdateStartPosition
                                    }
                            ]
                            [ text p.name
                            ]
                    )


pickEndPosition : Dict String Position -> Form -> Element Styles vs Msg
pickEndPosition positions form =
    case form.endPosition of
        Pending ->
            el Icon
                [ center
                , class "fa fa-question"
                , onClick <|
                    Update
                        { form
                            | endPosition =
                                Picking <|
                                    Input.autocomplete Nothing UpdateEndPosition
                        }
                ]
                empty

        Picking state ->
            Input.select None
                []
                { label = Input.hiddenLabel "sub"
                , with = state
                , max = 5
                , options = []
                , menu =
                    Input.menu None
                        []
                        (positions
                            |> Dict.values
                            |> List.map
                                (\p ->
                                    Input.choice p <| text p.name
                                )
                        )
                }

        Picked position ->
            positions
                |> Dict.get (position |> .id |> (\(Id id) -> id))
                |> flip whenJust
                    (\p ->
                        paragraph Link
                            [ onClick <|
                                Update
                                    { form
                                        | endPosition =
                                            Picking <|
                                                Input.autocomplete Nothing UpdateEndPosition
                                    }
                            ]
                            [ text p.name
                            ]
                    )


editRow : String -> Element Styles vs Msg
editRow name =
    paragraph None
        [ spacing 5, verticalCenter ]
        [ el Subtitle [] <| text name
        , el Icon
            [ padding 10
            , class "fa fa-edit"
            , onClick Edit
            ]
            empty
        ]


nameEdit : Form -> Element Styles vs Msg
nameEdit form =
    Input.text
        Field
        [ maxWidth <| px 300, center ]
        { onChange = \str -> Update { form | name = str }
        , value = form.name
        , label = Input.hiddenLabel "name"
        , options = []
        }


whenEdit : Form -> Element Styles vs Msg
whenEdit r =
    Input.text
        Field
        [ maxWidth <| px 300, center ]
        { onChange =
            \str ->
                Update { r | when = str }
        , value = r.when
        , label = Input.hiddenLabel "when"
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


buttons : Maybe Msg -> Element Styles vs Msg
buttons maybeDelete =
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
        , whenJust maybeDelete
            (\msg ->
                el Icon
                    [ padding 10
                    , onClick <| Confirm <| Just msg
                    , class "fa fa-trash"
                    ]
                    empty
            )
        ]


stepsEditor : Form -> Element Styles vs Msg
stepsEditor form =
    let
        steps =
            column None
                [ spacing 10 ]
                (form.steps
                    |> Array.indexedMap
                        (\i v ->
                            Input.multiline
                                Field
                                []
                                { onChange = \str -> Update { form | steps = Array.set i str form.steps }
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
                [ plus (Update { form | steps = Array.push "" form.steps })
                , when (not <| Array.isEmpty form.steps) <|
                    minus (Update { form | steps = Array.slice 0 -1 form.steps })
                ]
    in
        column None
            [ spacing 10 ]
            [ el BigIcon [ class "fa fa-cogs", center ] empty
            , steps
            , buttons
            ]


notesEditor : Form -> Element Styles vs Msg
notesEditor form =
    let
        notes =
            column None
                [ spacing 10 ]
                (form.notes
                    |> Array.indexedMap
                        (\i v ->
                            Input.multiline
                                Field
                                [ width <| px 300, attribute "rows" "3" ]
                                { onChange = \str -> Update { form | notes = Array.set i str form.notes }
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
                [ plus (Update { form | notes = Array.push "" form.notes })
                , when (not <| Array.isEmpty form.notes) <|
                    minus (Update { form | notes = Array.slice 0 -1 form.notes })
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
                    row None
                        [ spacing 10 ]
                        [ el Dot [] <| text <| (toString (i + 1) ++ ".")
                        , paragraph None
                            []
                            [ text step
                            ]
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
                    row None
                        [ spacing 10 ]
                        [ el Dot [] <| text "• "
                        , paragraph None
                            []
                            [ text x
                            ]
                        ]
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
                            paragraph None
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
