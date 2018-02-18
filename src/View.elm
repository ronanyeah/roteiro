module View exposing (..)

import Array exposing (Array)
import Element exposing (Element, alignRight, attribute, center, centerY, column, decorativeImage, el, empty, fill, height, inFront, layout, layoutWith, link, newTabLink, noHover, padding, paragraph, pointer, px, row, scrollbars, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import List.Extra exposing (groupWhile)
import Paths
import Regex
import RemoteData exposing (RemoteData(..))
import Style
import Types exposing (..)
import Utils exposing (formatErrors, icon, isJust, matchDomain, matchLink, noLabel, unwrap, when, whenJust)


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewStart ->
                    column [ spacing 20 ]
                        [ Input.button []
                            { onPress =
                                Just <| TokenEdit <| Just ""
                            , label =
                                decorativeImage
                                    [ height <| px 100
                                    , width <| px 100
                                    ]
                                    { src = "/map.svg" }
                            }
                        , el
                            [ Font.size 45, Font.color Style.e ]
                          <|
                            text "ROTEIRO"
                        ]

                ViewCreatePosition ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , notesEditor model.form
                        , createButtons SaveCreatePosition
                        ]

                ViewCreateSubmission ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , viewSubmissionPicker model.form
                        , stepsEditor model.form
                        , notesEditor model.form
                        , createButtons SaveCreateSubmission
                        ]

                ViewCreateTopic ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , notesEditor model.form
                        , createButtons SaveCreateTopic
                        ]

                ViewCreateTransition ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , viewTransitionPickers model.form
                        , stepsEditor model.form
                        , notesEditor model.form
                        , createButtons SaveCreateTransition
                        ]

                ViewEditPosition ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , notesEditor model.form
                        , editButtons SaveEditPosition <| DeletePosition model.form.id
                        ]

                ViewEditSubmission ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , viewSubmissionPicker model.form
                        , stepsEditor model.form
                        , notesEditor model.form
                        , editButtons SaveEditSubmission <| DeleteSubmission model.form.id
                        ]

                ViewEditTopic ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , notesEditor model.form
                        , editButtons SaveEditTopic <| DeleteTopic model.form.id
                        ]

                ViewEditTransition ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , viewTransitionPickers model.form
                        , stepsEditor model.form
                        , notesEditor model.form
                        , editButtons SaveEditTransition <| DeleteTransition model.form.id
                        ]

                ViewPosition data ->
                    data
                        |> viewRemote
                            (\({ name, notes, submissions, transitionsFrom, transitionsTo } as position) ->
                                column [ height <| px model.size.height, scrollbars ]
                                    [ editRow name Flag <| EditPosition position
                                    , viewNotes notes
                                    , column []
                                        [ row [ spacing 20, padding 30 ]
                                            [ icon Bolt Style.mattIcon
                                            , plus <| CreateSubmission <| Just position
                                            ]
                                        , viewTechList Paths.submission submissions
                                        ]
                                    , column []
                                        [ row [ spacing 20, padding 30 ]
                                            [ icon Arrow Style.mattIcon
                                            , plus <| CreateTransition <| Just position
                                            ]
                                        , column []
                                            (transitionsFrom
                                                |> List.map
                                                    (transitionPositions { id = position.id, name = name })
                                            )
                                        , column []
                                            (transitionsTo
                                                |> List.map
                                                    (flip transitionPositions { id = position.id, name = name })
                                            )
                                        ]
                                    ]
                            )

                ViewPositions ->
                    model.positions
                        |> viewRemote
                            (\positions ->
                                column
                                    [ height <| px model.size.height, scrollbars ]
                                    [ row [ spacing 20, padding 30 ]
                                        [ icon Flag Style.mattIcon
                                        , plus CreatePosition
                                        ]
                                    , blocks Paths.position positions
                                    ]
                            )

                ViewSubmission data ->
                    data
                        |> viewRemote
                            (\sub ->
                                column [ height <| px model.size.height, scrollbars ]
                                    [ editRow sub.name Bolt <| EditSubmission sub
                                    , row
                                        [ spacing 10 ]
                                        [ icon Flag Style.mattIcon
                                        , link []
                                            { url = Paths.position sub.position.id
                                            , label =
                                                el Style.link <|
                                                    text sub.position.name
                                            }
                                        ]
                                    , viewSteps sub.steps
                                    , viewNotes sub.notes
                                    ]
                            )

                ViewSubmissions data ->
                    data
                        |> viewRemote
                            (\submissions ->
                                column
                                    [ height <| px model.size.height, scrollbars ]
                                    [ row [ spacing 20, padding 30 ]
                                        [ icon Bolt Style.mattIcon
                                        , plus <| CreateSubmission Nothing
                                        ]
                                    , column [ spacing 20 ] <|
                                        (submissions
                                            |> List.sortBy (.position >> .id >> (\(Id id) -> id))
                                            |> groupWhile (\a b -> a.position.id == b.position.id)
                                            |> List.map
                                                (\g ->
                                                    el [] <|
                                                        column
                                                            []
                                                            [ g
                                                                |> List.head
                                                                |> Maybe.map .position
                                                                |> whenJust
                                                                    (\{ id, name } ->
                                                                        link []
                                                                            { url = Paths.position id
                                                                            , label =
                                                                                paragraph Style.choice
                                                                                    [ text name ]
                                                                            }
                                                                    )
                                                            , blocks Paths.submission g
                                                            ]
                                                )
                                        )
                                    ]
                            )

                ViewTopic data ->
                    data
                        |> viewRemote
                            (\t ->
                                column []
                                    [ editRow t.name Book <| EditTopic t
                                    , viewNotes t.notes
                                    ]
                            )

                ViewTopics data ->
                    data
                        |> viewRemote
                            (\topics ->
                                column
                                    [ height <| px model.size.height, scrollbars ]
                                    [ row [ spacing 20, padding 30 ]
                                        [ icon Book Style.mattIcon
                                        , plus CreateTopic
                                        ]
                                    , blocks Paths.topic topics
                                    ]
                            )

                ViewTransition data ->
                    data
                        |> viewRemote
                            (\({ steps, startPosition, endPosition, notes } as t) ->
                                column
                                    [ height <| px model.size.height, scrollbars ]
                                    [ editRow t.name Arrow <| EditTransition t
                                    , transitionPositions startPosition endPosition
                                    , viewSteps steps
                                    , viewNotes notes
                                    ]
                            )

                ViewTransitions data ->
                    data
                        |> viewRemote
                            (\transitions ->
                                column
                                    [ height <| px model.size.height, scrollbars ]
                                    [ row [ spacing 20, padding 30 ]
                                        [ icon Arrow Style.mattIcon
                                        , plus <| CreateTransition Nothing
                                        ]
                                    , column [ spacing 20 ] <|
                                        (transitions
                                            |> List.sortBy
                                                (.startPosition >> .id >> (\(Id id) -> id))
                                            |> groupWhile
                                                (\a b ->
                                                    a.startPosition.id == b.startPosition.id
                                                )
                                            |> List.map
                                                (\g ->
                                                    el [] <|
                                                        column
                                                            [ center ]
                                                            [ g
                                                                |> List.head
                                                                |> Maybe.map .startPosition
                                                                |> whenJust
                                                                    (\{ id, name } ->
                                                                        link []
                                                                            { url = Paths.position id
                                                                            , label =
                                                                                paragraph Style.choice
                                                                                    [ text name ]
                                                                            }
                                                                    )
                                                            , blocks Paths.transition g
                                                            ]
                                                )
                                        )
                                    ]
                            )

        scale =
            if model.device == Mobile then
                2
            else
                3

        ballIcon =
            [ Font.color Style.c
            , Font.size <| 10 * scale
            , pointer
            , Background.color Style.e
            , Border.rounded <| 10 * scale
            , width <| px <| 20 * scale
            , height <| px <| 20 * scale
            , Font.mouseOverColor Style.a
            ]

        enterToken =
            model.tokenForm
                |> whenJust
                    (\str ->
                        column
                            [ center
                            , spacing 20
                            , Background.color Style.c
                            , width fill
                            , height fill
                            ]
                            [ Input.text
                                ([ centerY, width <| px <| model.size.width // 3 ] ++ Style.field)
                                { onChange = Just (Just >> TokenEdit)
                                , text = str
                                , label =
                                    Input.labelAbove [] <|
                                        icon Lock (center :: Style.bigIcon)
                                , placeholder = Nothing
                                , notice = Nothing
                                }
                            , Input.button []
                                { onPress =
                                    Just <| TokenEdit Nothing
                                , label =
                                    icon Cross
                                        Style.actionIcon
                                }
                            ]
                    )

        confirm =
            model.confirm
                |> whenJust
                    (\msg ->
                        el [ center, centerY, padding 10, spacing 20 ] <|
                            column
                                [ center ]
                                [ icon Question (center :: Style.bigIcon)
                                , row
                                    [ spacing 40 ]
                                    [ Input.button []
                                        { onPress =
                                            Just msg
                                        , label =
                                            icon Tick
                                                Style.actionIcon
                                        }
                                    , Input.button []
                                        { onPress =
                                            Just <| Confirm Nothing
                                        , label =
                                            icon Cross
                                                Style.actionIcon
                                        }
                                    ]
                                ]
                    )

        links =
            column
                [ spacing 40
                , height <| px model.size.height
                ]
                [ link []
                    { url = Paths.start
                    , label =
                        icon Home
                            (if model.view == ViewStart then
                                ballIcon
                             else
                                Style.actionIcon
                            )
                    }
                , link []
                    { url = Paths.positions
                    , label =
                        icon Flag
                            (case model.view of
                                ViewPositions ->
                                    ballIcon

                                ViewPosition _ ->
                                    ballIcon

                                ViewCreatePosition ->
                                    ballIcon

                                ViewEditPosition ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , link []
                    { url = Paths.transitions
                    , label =
                        icon Arrow
                            (case model.view of
                                ViewTransitions _ ->
                                    ballIcon

                                ViewTransition _ ->
                                    ballIcon

                                ViewCreateTransition ->
                                    ballIcon

                                ViewEditTransition ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , link []
                    { url = Paths.submissions
                    , label =
                        icon Bolt
                            (case model.view of
                                ViewSubmissions _ ->
                                    ballIcon

                                ViewSubmission _ ->
                                    ballIcon

                                ViewCreateSubmission ->
                                    ballIcon

                                ViewEditSubmission ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , link []
                    { url = Paths.topics
                    , label =
                        icon Book
                            (case model.view of
                                ViewTopics _ ->
                                    ballIcon

                                ViewTopic _ ->
                                    ballIcon

                                ViewCreateTopic ->
                                    ballIcon

                                ViewEditTopic ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                ]

        sidebar =
            column
                [ spacing 40
                , height <| px model.size.height
                , alignRight
                , width <| px <| model.size.width // 2
                , Background.color Style.c
                , Border.solid
                , Border.widthEach { bottom = 0, left = 5, right = 0, top = 0 }
                , Border.color Style.e
                ]
                [ Input.button
                    []
                    { onPress =
                        Just <| SidebarNavigate Paths.start
                    , label =
                        icon Home
                            (if model.view == ViewStart then
                                ballIcon
                             else
                                Style.actionIcon
                            )
                    }
                , Input.button
                    []
                    { onPress =
                        Just <| SidebarNavigate Paths.positions
                    , label =
                        icon Flag
                            (case model.view of
                                ViewPositions ->
                                    ballIcon

                                ViewPosition _ ->
                                    ballIcon

                                ViewCreatePosition ->
                                    ballIcon

                                ViewEditPosition ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , Input.button
                    []
                    { onPress =
                        Just <| SidebarNavigate Paths.transitions
                    , label =
                        icon Arrow
                            (case model.view of
                                ViewTransitions _ ->
                                    ballIcon

                                ViewTransition _ ->
                                    ballIcon

                                ViewCreateTransition ->
                                    ballIcon

                                ViewEditTransition ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , Input.button
                    []
                    { onPress =
                        Just <| SidebarNavigate Paths.submissions
                    , label =
                        icon Bolt
                            (case model.view of
                                ViewSubmissions _ ->
                                    ballIcon

                                ViewSubmission _ ->
                                    ballIcon

                                ViewCreateSubmission ->
                                    ballIcon

                                ViewEditSubmission ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , Input.button
                    []
                    { onPress =
                        Just <| SidebarNavigate Paths.topics
                    , label =
                        icon Book
                            (case model.view of
                                ViewTopics _ ->
                                    ballIcon

                                ViewTopic _ ->
                                    ballIcon

                                ViewCreateTopic ->
                                    ballIcon

                                ViewEditTopic ->
                                    ballIcon

                                _ ->
                                    Style.actionIcon
                            )
                    }
                , Input.button
                    []
                    { onPress =
                        Just <| ToggleSidebar
                    , label =
                        icon Cross Style.actionIcon
                    }
                ]

        modal =
            if isJust model.confirm then
                confirm
                    |> inFront True
            else if isJust model.tokenForm then
                enterToken
                    |> inFront True
            else if model.selectingEndPosition then
                viewPickPosition UpdateEndPosition model.positions
                    |> inFront True
            else if model.selectingStartPosition then
                viewPickPosition UpdateStartPosition model.positions
                    |> inFront True
            else
                empty
                    |> inFront False
    in
    case model.device of
        Desktop ->
            row
                [ width fill
                , height fill

                --, viewPickPosition UpdateEndPosition model.positions
                --|> inFront model.selectingEndPosition
                --, viewPickPosition UpdateStartPosition model.positions
                --|> inFront model.selectingStartPosition
                ]
                [ links
                , el [ width <| px <| round <| toFloat model.size.width * 0.8 ]
                    content
                ]
                |> layout
                    [ Background.color Style.c
                    , Style.font
                    , modal
                    ]

        Mobile ->
            content
                |> layoutWith { options = [ noHover ] }
                    [ Background.color Style.c
                    , Style.font
                    , modal

                    --, viewPickPosition UpdateStartPosition model.positions
                    --|> inFront model.selectingStartPosition
                    --, viewPickPosition UpdateEndPosition model.positions
                    --|> inFront model.selectingEndPosition
                    ]


transitionPositions : Info -> Info -> Element msg
transitionPositions startPosition endPosition =
    paragraph
        [ centerY, center ]
        [ link []
            { url = Paths.position startPosition.id
            , label =
                el Style.link <|
                    text startPosition.name
            }
        , el [ padding 20 ] <| icon Arrow Style.mattIcon
        , link []
            { url = Paths.position endPosition.id
            , label =
                el Style.link <|
                    text endPosition.name
            }
        ]


blocks : (Id -> String) -> List { r | id : Id, name : String } -> Element msg
blocks url =
    List.map
        (\{ id, name } ->
            link [ padding 10 ]
                { url = url id
                , label =
                    paragraph Style.block
                        [ text name
                        ]
                }
        )
        >> paragraph [ padding 20 ]


viewPickPosition : (Info -> Msg) -> GcData (List Info) -> Element Msg
viewPickPosition msg ps =
    el [ width fill, height fill, Background.color Style.c ] <|
        paragraph [ padding 20 ]
            (ps
                |> RemoteData.withDefault []
                |> List.map
                    (\p ->
                        Input.button
                            []
                            { onPress =
                                Just <| msg p
                            , label =
                                el [ padding 10 ] <| el Style.block <| text p.name
                            }
                    )
            )


viewRemote : (a -> Element Msg) -> GcData a -> Element Msg
viewRemote fn data =
    case data of
        NotAsked ->
            el [ center ] <| text "not asked"

        Loading ->
            icon Waiting
                [ Font.color Style.e
                , Font.size 60
                ]

        Failure err ->
            err
                |> formatErrors
                |> viewErrors

        Success a ->
            fn a


viewSubmissionPicker : Form -> Element Msg
viewSubmissionPicker form =
    paragraph
        [ spacing 10, center ]
        [ icon Flag Style.mattIcon
        , pickPosition ToggleStartPosition form.startPosition
        ]


viewTransitionPickers : Form -> Element Msg
viewTransitionPickers form =
    el [ center ] <|
        paragraph
            [ centerY ]
            [ pickPosition ToggleStartPosition form.startPosition
            , el [ padding 20 ] <| icon Arrow Style.mattIcon
            , pickPosition ToggleEndPosition form.endPosition
            ]


pickPosition : Msg -> Maybe Info -> Element Msg
pickPosition msg position =
    case position of
        Nothing ->
            Input.button [ center ]
                { onPress =
                    Just msg
                , label =
                    icon Question
                        Style.actionIcon
                }

        Just { name } ->
            Input.button [ center ]
                { onPress =
                    Just msg
                , label =
                    el Style.link <| text name
                }


editRow : String -> FaIcon -> Msg -> Element Msg
editRow name faIcon editMsg =
    el [] <|
        row
            [ spacing 20, centerY ]
            [ icon faIcon Style.mattIcon
            , paragraph
                [ Font.size 35
                , Font.color Style.e
                , width fill
                ]
                [ text name ]
            , Input.button []
                { onPress = Just editMsg
                , label = icon Write Style.actionIcon
                }
            ]


nameEdit : Form -> Element Msg
nameEdit form =
    Input.text
        (center :: Style.field)
        { onChange = Just <| \str -> UpdateForm { form | name = str }
        , text = form.name
        , label = noLabel
        , placeholder = Nothing
        , notice = Nothing
        }


plus : msg -> Element msg
plus msg =
    Input.button [ padding 10 ]
        { onPress = Just msg
        , label =
            icon Plus
                Style.actionIcon
        }


minus : msg -> Element msg
minus msg =
    Input.button [ padding 10 ]
        { onPress = Just msg
        , label =
            icon Minus
                Style.actionIcon
        }


editButtons : Msg -> Msg -> Element Msg
editButtons save delete =
    row
        [ spacing 20 ]
        [ Input.button [ padding 10 ]
            { onPress = Just save
            , label =
                icon Tick
                    Style.actionIcon
            }
        , Input.button [ padding 10 ]
            { onPress = Just Cancel
            , label =
                icon Cross
                    Style.actionIcon
            }
        , Input.button [ padding 10 ]
            { onPress = Just <| Confirm <| Just delete
            , label =
                icon Trash
                    Style.actionIcon
            }
        ]


createButtons : Msg -> Element Msg
createButtons save =
    row
        [ spacing 20 ]
        [ Input.button [ padding 10 ]
            { onPress = Just save
            , label =
                icon Tick
                    Style.actionIcon
            }
        , Input.button [ padding 10 ]
            { onPress = Just Cancel
            , label =
                icon Cross
                    Style.actionIcon
            }
        ]


stepsEditor : Form -> Element Msg
stepsEditor form =
    let
        steps =
            column
                [ spacing 10 ]
                (form.steps
                    |> Array.indexedMap
                        (\i v ->
                            Input.multiline
                                (Style.field
                                    ++ [ width fill, attribute <| Html.Attributes.rows 4 ]
                                )
                                { onChange =
                                    Just <|
                                        \str ->
                                            UpdateForm
                                                { form | steps = Array.set i str form.steps }
                                , text = v
                                , label = noLabel
                                , notice = Nothing
                                , placeholder = Nothing
                                }
                        )
                    |> Array.toList
                )

        buttons =
            row
                [ center ]
                [ plus (UpdateForm { form | steps = Array.push "" form.steps })
                , when (not <| Array.isEmpty form.steps) <|
                    minus (UpdateForm { form | steps = Array.slice 0 -1 form.steps })
                ]
    in
    column
        [ spacing 10
        , width fill
        ]
        [ icon Cogs (center :: Style.bigIcon)
        , steps
        , buttons
        ]


notesEditor : Form -> Element Msg
notesEditor form =
    let
        notes =
            column
                [ spacing 10 ]
                (form.notes
                    |> Array.indexedMap
                        (\i v ->
                            Input.multiline
                                (Style.field
                                    ++ [ width fill, attribute <| Html.Attributes.rows 4 ]
                                )
                                { onChange =
                                    Just <|
                                        \str ->
                                            UpdateForm
                                                { form | notes = Array.set i str form.notes }
                                , text = v
                                , label = noLabel
                                , notice = Nothing
                                , placeholder = Nothing
                                }
                        )
                    |> Array.toList
                )

        buttons =
            row
                [ center ]
                [ plus (UpdateForm { form | notes = Array.push "" form.notes })
                , when (not <| Array.isEmpty form.notes) <|
                    minus (UpdateForm { form | notes = Array.slice 0 -1 form.notes })
                ]
    in
    column
        [ spacing 10
        , width fill
        ]
        [ icon Notes (center :: Style.bigIcon)
        , notes
        , buttons
        ]


viewSteps : Array String -> Element Msg
viewSteps steps =
    el [] <|
        column
            []
            (steps
                |> Array.toList
                |> List.indexedMap
                    (\i step ->
                        row
                            [ spacing 10 ]
                            [ el Style.dot <| text <| (toString (i + 1) ++ ".")
                            , paragraph
                                [ width fill ]
                                [ text step
                                ]
                            ]
                    )
            )


viewNotes : Array String -> Element msg
viewNotes notes =
    el [] <|
        column
            []
            (notes
                |> Array.toList
                |> List.map
                    (\note ->
                        let
                            content =
                                if Regex.contains matchLink note then
                                    newTabLink [ spacing 5 ]
                                        { url = note
                                        , label =
                                            paragraph []
                                                [ icon Globe Style.mattIcon
                                                , text <| domain note
                                                ]
                                        }
                                else
                                    text note
                        in
                        paragraph
                            [ spacing 5 ]
                            [ el Style.dot <| text "• "
                            , content
                            ]
                    )
            )


viewTransitions : List Transition -> Element Msg
viewTransitions ts =
    column
        []
        (ts
            |> List.map
                (\{ id, endPosition, name } ->
                    paragraph
                        []
                        [ el Style.dot <| text "• "
                        , link Style.link
                            { url = Paths.transition id
                            , label = text name
                            }
                        , text " "
                        , paragraph
                            []
                            [ text "("
                            , link Style.link
                                { url =
                                    Paths.position endPosition.id
                                , label =
                                    text endPosition.name
                                }
                            , text ")"
                            ]
                        ]
                )
        )


viewTechList : (Id -> String) -> List { r | name : String, id : Id } -> Element Msg
viewTechList fn xs =
    if List.isEmpty xs then
        el [] <| text "None!"
    else
        column
            []
            (xs
                |> List.map
                    (\t ->
                        link []
                            { url = fn t.id
                            , label =
                                paragraph
                                    []
                                    [ el Style.dot <| text "• "
                                    , el Style.link <| text t.name
                                    ]
                            }
                    )
            )


viewErrors : List String -> Element Msg
viewErrors errs =
    when (errs |> List.isEmpty |> not) <|
        column
            [ center, spacing 15 ]
            [ icon Warning Style.mattIcon
            , viewNotes <| Array.fromList errs
            ]


domain : String -> String
domain s =
    Regex.find (Regex.AtMost 10) matchDomain s
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
        |> Maybe.withDefault s
