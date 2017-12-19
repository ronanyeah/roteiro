module View exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Element exposing (Element, circle, column, decorativeImage, el, empty, layout, link, modal, newTab, paragraph, row, screen, text, when, whenJust)
import Element.Attributes exposing (alignBottom, alignLeft, attribute, center, fill, height, maxWidth, moveDown, padding, px, spacing, spread, vary, verticalCenter, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import Html exposing (Html)
import List.Extra exposing (groupWhile)
import Regex exposing (Regex)
import Router
import Styling exposing (styling)
import Types exposing (Device(..), FaIcon(..), Form, Id(..), Model, Msg(..), Picker(..), Position, Styles(..), Variations(..), View(..))
import Utils exposing (get, icon, sort)


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
                                , el Home [] <| text "ROTEIRO"
                                ]

                        Desktop ->
                            column None
                                [ center, spacing 40 ]
                                [ link "/#/ps" <|
                                    icon Flag ActionIcon []
                                , link "/#/trs" <|
                                    icon Arrow ActionIcon []
                                , link "/#/ss" <|
                                    icon Bolt ActionIcon []
                                , link "/#/ts" <|
                                    icon Book ActionIcon []
                                ]

                ViewCreatePosition ->
                    column None
                        [ center, spacing 20, width fill ]
                        [ nameEdit form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewCreateSubmission ->
                    column None
                        [ center, spacing 20, width fill ]
                        [ nameEdit form
                        , row None
                            [ spacing 10 ]
                            [ icon Flag MattIcon []
                            , pickStartPosition model.positions form
                            ]
                        , stepsEditor form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewCreateTopic ->
                    column None
                        [ center, spacing 20, width fill ]
                        [ nameEdit form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewCreateTransition ->
                    column None
                        [ center, spacing 20, width fill ]
                        [ nameEdit form
                        , row None
                            [ verticalCenter, spacing 10 ]
                            [ pickStartPosition model.positions form
                            , icon Arrow MattIcon []
                            , pickEndPosition model.positions form
                            ]
                        , stepsEditor form
                        , notesEditor form
                        , buttons Nothing
                        ]

                ViewPosition editing ({ id, name, notes } as position) ->
                    column None [ center, spacing 20, width fill ] <|
                        if editing then
                            [ nameEdit form
                            , notesEditor form
                            , buttons <| Just <| DeletePosition id
                            ]
                        else
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
                                [ editRow name
                                , viewNotes notes
                                , el Line [ width <| px 100, height <| px 2 ] empty
                                , icon Arrow MattIcon []
                                , viewTechList Router.transition transitions
                                , plus <| CreateTransition <| Just position
                                , el Line [ width <| px 100, height <| px 2 ] empty
                                , icon Bolt MattIcon []
                                , viewTechList Router.submission submissions
                                , plus <| CreateSubmission <| Just position
                                ]

                ViewPositions ->
                    column None
                        [ alignLeft, center, spacing 20 ]
                        [ icon Flag MattIcon []
                        , column None [] <|
                            (model.positions
                                |> Dict.values
                                |> sort
                                |> List.map
                                    (\p ->
                                        link (Router.position p.id) <|
                                            paragraph Choice
                                                []
                                                [ text p.name
                                                ]
                                    )
                            )
                        , plus CreatePosition
                        ]

                ViewSubmission editing sub ->
                    column None [ center, spacing 20, width fill ] <|
                        if editing then
                            [ nameEdit form
                            , row None
                                [ spacing 10 ]
                                [ icon Flag MattIcon []
                                , pickStartPosition model.positions form
                                ]
                            , stepsEditor form
                            , notesEditor form
                            , buttons <| Just <| DeleteSubmission sub.id
                            ]
                        else
                            [ editRow sub.name
                            , row None
                                [ spacing 10 ]
                                [ icon Flag MattIcon []
                                , get sub.position model.positions
                                    |> flip whenJust
                                        (\pos ->
                                            link (Router.position pos.id) <|
                                                el Link [] <|
                                                    text pos.name
                                        )
                                ]
                            , viewSteps sub.steps
                            , viewNotes sub.notes
                            ]

                ViewSubmissions ->
                    column None
                        [ alignLeft, center, spacing 20 ]
                        [ icon Bolt MattIcon []
                        , column None [ spacing 20 ] <|
                            (model.submissions
                                |> Dict.values
                                |> List.sortBy (.position >> (\(Id id) -> id))
                                |> groupWhile (\a b -> a.position == b.position)
                                |> List.map
                                    (\g ->
                                        column None
                                            []
                                            [ g
                                                |> List.head
                                                |> Maybe.andThen
                                                    (\{ position } ->
                                                        get position model.positions
                                                    )
                                                |> flip whenJust
                                                    (\{ id, name } ->
                                                        link (Router.position id) <|
                                                            el Link [ center ] <|
                                                                text name
                                                    )
                                            , viewTechList Router.submission g
                                            ]
                                    )
                            )
                        , plus <| CreateSubmission Nothing
                        ]

                ViewTopic editing t ->
                    column None [ center, spacing 20, width fill ] <|
                        if editing then
                            [ nameEdit form
                            , notesEditor form
                            , buttons <| Just <| DeleteTopic t.id
                            ]
                        else
                            [ editRow t.name
                            , viewNotes t.notes
                            , link "/#/ts" <|
                                icon Book ActionIcon []
                            ]

                ViewTopics ->
                    column None
                        [ alignLeft, center, spacing 20 ]
                        [ icon Book MattIcon []
                        , column None [] <|
                            (model.topics
                                |> Dict.values
                                |> List.map
                                    (\t ->
                                        link (Router.topic t.id) <|
                                            el Choice [] <|
                                                text t.name
                                    )
                            )
                        , plus CreateTopic
                        ]

                ViewTransition editing ({ steps, startPosition, endPosition, notes } as t) ->
                    column None [ center, spacing 20, width fill ] <|
                        if editing then
                            [ nameEdit form
                            , paragraph None
                                [ verticalCenter, spacing 10 ]
                                [ pickStartPosition model.positions form
                                , icon Arrow MattIcon []
                                , pickEndPosition model.positions form
                                ]
                            , stepsEditor form
                            , notesEditor form
                            , buttons <| Just <| DeleteTransition t.id
                            ]
                        else
                            [ editRow t.name
                            , Maybe.map2
                                (\start end ->
                                    paragraph None
                                        [ verticalCenter, spacing 10 ]
                                        [ link (Router.position start.id) <|
                                            el Link [] <|
                                                text start.name
                                        , icon Arrow MattIcon []
                                        , link (Router.position end.id) <|
                                            el Link [] <|
                                                text end.name
                                        ]
                                )
                                (get startPosition model.positions)
                                (get endPosition model.positions)
                                |> Maybe.withDefault empty
                            , viewSteps steps
                            , viewNotes notes
                            ]

                ViewTransitions ->
                    column None
                        [ alignLeft, center, spacing 20 ]
                        [ icon Arrow MattIcon []
                        , column None [ spacing 20 ] <|
                            (model.transitions
                                |> Dict.values
                                |> List.sortBy (.startPosition >> (\(Id id) -> id))
                                |> groupWhile (\a b -> a.startPosition == b.startPosition)
                                |> List.map
                                    (\g ->
                                        column None
                                            []
                                            [ g
                                                |> List.head
                                                |> Maybe.andThen
                                                    (\{ startPosition } ->
                                                        get startPosition model.positions
                                                    )
                                                |> flip whenJust
                                                    (\{ id, name } ->
                                                        link (Router.position id) <|
                                                            el Link [ center ] <|
                                                                text name
                                                    )
                                            , viewTechList Router.transition g
                                            ]
                                    )
                            )
                        , plus <| CreateTransition Nothing
                        ]

        roteiro =
            when (not (model.view == ViewAll && model.device == Mobile)) <|
                row None
                    [ center, spacing 10, verticalCenter ]
                    [ link "/#/" <|
                        el Header [ vary Small <| model.view /= ViewAll ] <|
                            text "ROTEIRO"
                    , when (model.view == ViewAll) <|
                        icon Lock
                            ActionIcon
                            [ padding 10
                            , onClick <| TokenEdit <| Just ""
                            ]
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
                                        icon Lock BigIcon [ center ]
                                , options = []
                                }
                            , icon Cross ActionIcon [ onClick <| TokenEdit Nothing ]
                            ]
                )

        confirm =
            whenJust model.confirm
                (\msg ->
                    modal ChooseBox [ center, verticalCenter, padding 10, spacing 20 ] <|
                        column None
                            [ center ]
                            [ icon Question BigIcon [ center ]
                            , row None
                                [ spacing 40 ]
                                [ icon Tick ActionIcon [ onClick msg ]
                                , icon Cross ActionIcon [ onClick <| Confirm Nothing ]
                                ]
                            ]
                )

        ball lnk fa =
            link lnk <|
                circle 40 Ball [] <|
                    icon fa
                        BallIcon
                        [ center
                        , verticalCenter
                        ]

        balls =
            when (model.device == Mobile && Utils.notEditing model.view) <|
                screen <|
                    el None [ alignBottom, width fill ] <|
                        row None
                            [ spread, width fill, padding 10 ]
                            [ ball "/#/ps" Flag
                            , ball "/#/trs" Arrow
                            , ball "/#/ss" Bolt
                            , ball "/#/ts" Book
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
            icon Question
                ActionIcon
                [ center
                , onClick <|
                    Update
                        { form
                            | startPosition =
                                Picking <|
                                    Input.autocomplete Nothing UpdateStartPosition
                        }
                ]

        Picking state ->
            Input.select None
                []
                { label = Input.hiddenLabel ""
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

        Picked { name } ->
            paragraph Link
                [ onClick <|
                    Update
                        { form
                            | startPosition =
                                Picking <|
                                    Input.autocomplete Nothing UpdateStartPosition
                        }
                ]
                [ text name
                ]


pickEndPosition : Dict String Position -> Form -> Element Styles vs Msg
pickEndPosition positions form =
    case form.endPosition of
        Pending ->
            icon Question
                ActionIcon
                [ center
                , onClick <|
                    Update
                        { form
                            | endPosition =
                                Picking <|
                                    Input.autocomplete Nothing UpdateEndPosition
                        }
                ]

        Picking state ->
            Input.select None
                []
                { label = Input.hiddenLabel ""
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

        Picked { name } ->
            paragraph Link
                [ onClick <|
                    Update
                        { form
                            | endPosition =
                                Picking <|
                                    Input.autocomplete Nothing UpdateEndPosition
                        }
                ]
                [ text name
                ]


editRow : String -> Element Styles vs Msg
editRow name =
    paragraph None
        [ spacing 5, verticalCenter ]
        [ el Subtitle [] <| text name
        , icon Write
            ActionIcon
            [ padding 10
            , onClick Edit
            ]
        ]


nameEdit : Form -> Element Styles vs Msg
nameEdit form =
    Input.text
        Field
        [ maxWidth <| px 300, center ]
        { onChange = \str -> Update { form | name = str }
        , value = form.name
        , label = Input.hiddenLabel ""
        , options = []
        }


plus : msg -> Element Styles vs msg
plus msg =
    icon Plus
        ActionIcon
        [ padding 10
        , onClick msg
        ]


minus : msg -> Element Styles vs msg
minus msg =
    icon Minus
        ActionIcon
        [ padding 10
        , onClick msg
        ]


buttons : Maybe Msg -> Element Styles vs Msg
buttons maybeDelete =
    row ChooseBox
        [ spacing 20 ]
        [ icon Tick
            ActionIcon
            [ padding 10
            , onClick Save
            ]
        , icon Cross
            ActionIcon
            [ padding 10
            , onClick Cancel
            ]
        , whenJust maybeDelete
            (\msg ->
                icon Trash
                    ActionIcon
                    [ padding 10
                    , onClick <| Confirm <| Just msg
                    ]
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
                                [ width fill, attribute "rows" "4" ]
                                { onChange =
                                    \str ->
                                        Update
                                            { form | steps = Array.set i str form.steps }
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
            [ spacing 10, width fill, maxWidth <| px 500 ]
            [ icon Cogs BigIcon [ center ]
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
                                [ width fill, attribute "rows" "4" ]
                                { onChange =
                                    \str ->
                                        Update
                                            { form | notes = Array.set i str form.notes }
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
            [ spacing 10, width fill, maxWidth <| px 500 ]
            [ icon Notes BigIcon [ center ]
            , notes
            , buttons
            ]


viewSteps : Array String -> Element Styles vs Msg
viewSteps steps =
    column None
        [ maxWidth <| px 700 ]
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
        )


viewNotes : Array String -> Element Styles vs msg
viewNotes notes =
    column None
        [ center, maxWidth <| px 500 ]
        (notes
            |> Array.toList
            |> List.map
                (\x ->
                    let
                        content =
                            if Regex.contains matchLink x then
                                newTab x <|
                                    paragraph None
                                        [ spacing 5 ]
                                        [ icon Globe MattIcon []
                                        , text <| domain x
                                        ]
                            else
                                text x
                    in
                        paragraph None
                            [ spacing 5 ]
                            [ el Dot [] <| text "• "
                            , content
                            ]
                )
        )


viewTechList : (Id -> String) -> List { r | name : String, id : Id } -> Element Styles vs Msg
viewTechList fn xs =
    if List.isEmpty xs then
        el None [] <| text "None!"
    else
        column None
            []
            (xs
                |> List.map
                    (\t ->
                        link (fn t.id) <|
                            paragraph None
                                []
                                [ el Dot [] <| text "• "
                                , el Link [] <|
                                    text t.name
                                ]
                    )
            )


domain : String -> String
domain s =
    Regex.find (Regex.AtMost 10) matchDomain s
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
        |> Maybe.withDefault s
