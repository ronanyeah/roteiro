module View exposing (..)

import Array exposing (Array)
import Element exposing (Element, alignLeft, alignRight, attribute, center, centerY, column, decorativeImage, el, empty, fill, height, inFront, layoutWith, link, newTabLink, noHover, padding, paddingXY, paragraph, px, row, scrollbars, spacing, text, width)
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
import Styling
import Swiper
import Types exposing (..)
import Utils exposing (formatErrors, icon, matchDomain, matchLink, noLabel, sort, when, whenJust)


view : Model -> Html Msg
view ({ form } as model) =
    let
        wrapper =
            column
                [ scrollbars
                , height <| px model.size.height
                , spacing 40
                ]

        content =
            case model.view of
                ViewStart ->
                    wrapper
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
                        , el Styling.home <| text "ROTEIRO"
                        ]

                ViewCreatePosition ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , notesEditor form
                        , createButtons SaveCreatePosition
                        ]

                ViewCreateSubmission ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , viewSubmissionPicker form
                        , stepsEditor form
                        , notesEditor form
                        , createButtons SaveCreateSubmission
                        ]

                ViewCreateTopic ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , notesEditor form
                        , createButtons SaveCreateTopic
                        ]

                ViewCreateTransition ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , viewTransitionPickers form
                        , stepsEditor form
                        , notesEditor form
                        , createButtons SaveCreateTransition
                        ]

                ViewEditPosition ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , notesEditor form
                        , editButtons SaveEditPosition <| DeletePosition form.id
                        ]

                ViewEditSubmission ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , viewSubmissionPicker form
                        , stepsEditor form
                        , notesEditor form
                        , editButtons SaveEditSubmission <| DeleteSubmission form.id
                        ]

                ViewEditTopic ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , notesEditor form
                        , editButtons SaveEditTopic <| DeleteTopic form.id
                        ]

                ViewEditTransition ->
                    wrapper
                        [ viewErrors form.errors
                        , nameEdit form
                        , viewTransitionPickers form
                        , stepsEditor form
                        , notesEditor form
                        , editButtons SaveEditTransition <| DeleteTransition form.id
                        ]

                ViewPosition data ->
                    data
                        |> viewRemote
                            (\({ name, notes, submissions, transitionsFrom, transitionsTo } as position) ->
                                wrapper
                                    [ editRow name <| EditPosition position
                                    , viewNotes <| Array.toList notes
                                    , el (Styling.line ++ [ width <| px 100, height <| px 2 ]) empty
                                    , viewTechList Paths.transition transitionsFrom
                                    , icon Arrow Styling.mattIcon
                                    , viewTechList Paths.transition transitionsTo
                                    , plus <| CreateTransition <| Just position
                                    , el (Styling.line ++ [ width <| px 100, height <| px 2 ]) empty
                                    , icon Bolt Styling.mattIcon
                                    , viewTechList Paths.submission submissions
                                    , plus <| CreateSubmission <| Just position
                                    ]
                            )

                ViewPositions ->
                    model.positions
                        |> viewRemote
                            (\positions ->
                                column
                                    []
                                    [ row [ spacing 20, padding 30 ]
                                        [ icon Flag Styling.mattIcon
                                        , plus CreatePosition
                                        ]
                                    , column [ paddingXY 40 0 ] <|
                                        (positions
                                            |> sort
                                            |> List.map
                                                (\{ id, name } ->
                                                    link [ alignLeft ]
                                                        { url = Paths.position id
                                                        , label =
                                                            paragraph Styling.choice
                                                                [ text name
                                                                ]
                                                        }
                                                )
                                        )
                                    ]
                            )

                ViewSubmission data ->
                    data
                        |> viewRemote
                            (\sub ->
                                wrapper
                                    [ editRow sub.name <| EditSubmission sub
                                    , row
                                        [ spacing 10 ]
                                        [ icon Flag Styling.mattIcon
                                        , link []
                                            { url = Paths.position sub.position.id
                                            , label =
                                                el Styling.link <|
                                                    text sub.position.name
                                            }
                                        ]
                                    , viewSteps sub.steps
                                    , viewNotes <| Array.toList sub.notes
                                    ]
                            )

                ViewSubmissions data ->
                    data
                        |> viewRemote
                            (\submissions ->
                                wrapper
                                    [ icon Bolt Styling.mattIcon
                                    , column [ spacing 20 ] <|
                                        (submissions
                                            |> List.sortBy (.position >> .id >> (\(Id id) -> id))
                                            |> groupWhile (\a b -> a.position.id == b.position.id)
                                            |> List.map
                                                (\g ->
                                                    column
                                                        [ center ]
                                                        [ g
                                                            |> List.head
                                                            |> Maybe.map .position
                                                            |> whenJust
                                                                (\{ id, name } ->
                                                                    link []
                                                                        { url = Paths.position id
                                                                        , label =
                                                                            paragraph Styling.choice
                                                                                [ text name ]
                                                                        }
                                                                )
                                                        , viewTechList Paths.submission g
                                                        ]
                                                )
                                        )
                                    , plus <| CreateSubmission Nothing
                                    ]
                            )

                ViewTopic data ->
                    data
                        |> viewRemote
                            (\t ->
                                wrapper
                                    [ editRow t.name <| EditTopic t
                                    , viewNotes <| Array.toList t.notes
                                    ]
                            )

                ViewTopics data ->
                    data
                        |> viewRemote
                            (\topics ->
                                wrapper
                                    [ icon Book Styling.mattIcon
                                    , column [] <|
                                        (topics
                                            |> List.map
                                                (\t ->
                                                    link []
                                                        { url = Paths.topic t.id
                                                        , label =
                                                            el Styling.choice <|
                                                                text t.name
                                                        }
                                                )
                                        )
                                    , plus CreateTopic
                                    ]
                            )

                ViewTransition data ->
                    data
                        |> viewRemote
                            (\({ steps, startPosition, endPosition, notes } as t) ->
                                wrapper
                                    [ editRow t.name <| EditTransition t
                                    , el [ center ] <|
                                        paragraph
                                            [ centerY, center ]
                                            [ link []
                                                { url = Paths.position startPosition.id
                                                , label =
                                                    el Styling.link <|
                                                        text startPosition.name
                                                }
                                            , el [ padding 20 ] <| icon Arrow Styling.mattIcon
                                            , link []
                                                { url = Paths.position endPosition.id
                                                , label =
                                                    el Styling.link <|
                                                        text endPosition.name
                                                }
                                            ]
                                    , viewSteps steps
                                    , viewNotes <| Array.toList notes
                                    ]
                            )

                ViewTransitions data ->
                    data
                        |> viewRemote
                            (\transitions ->
                                wrapper
                                    [ icon Arrow Styling.mattIcon
                                    , column [ spacing 20 ] <|
                                        (transitions
                                            |> List.sortBy (.startPosition >> .id >> (\(Id id) -> id))
                                            |> groupWhile (\a b -> a.startPosition.id == b.startPosition.id)
                                            |> List.map
                                                (\g ->
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
                                                                            paragraph Styling.choice
                                                                                [ text name ]
                                                                        }
                                                                )
                                                        , viewTransitions g
                                                        ]
                                                )
                                        )
                                    , plus <| CreateTransition Nothing
                                    ]
                            )

        enterToken =
            model.tokenForm
                |> whenJust
                    (\str ->
                        el
                            [ center
                            , centerY
                            , Background.color Styling.c
                            , width fill
                            , height fill
                            ]
                        <|
                            column
                                [ center, spacing 20 ]
                                [ Input.text
                                    ([ centerY, width <| px <| model.size.width // 3 ] ++ Styling.field)
                                    { onChange = Just (Just >> TokenEdit)
                                    , text = str
                                    , label =
                                        Input.labelAbove [] <|
                                            icon Lock (center :: Styling.bigIcon)
                                    , placeholder = Nothing
                                    , notice = Nothing
                                    }
                                , Input.button []
                                    { onPress =
                                        Just <| TokenEdit Nothing
                                    , label =
                                        icon Cross
                                            Styling.actionIcon
                                    }
                                ]
                    )
                |> inFront True

        confirm =
            model.confirm
                |> whenJust
                    (\msg ->
                        el [ center, centerY, padding 10, spacing 20 ] <|
                            column
                                [ center ]
                                [ icon Question (center :: Styling.bigIcon)
                                , row
                                    [ spacing 40 ]
                                    [ Input.button []
                                        { onPress =
                                            Just msg
                                        , label =
                                            icon Tick
                                                Styling.actionIcon
                                        }
                                    , Input.button []
                                        { onPress =
                                            Just <| Confirm Nothing
                                        , label =
                                            icon Cross
                                                Styling.actionIcon
                                        }
                                    ]
                                ]
                    )
                |> inFront True

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
                                Styling.ballIcon
                             else
                                Styling.actionIcon
                            )
                    }
                , link []
                    { url = Paths.positions
                    , label =
                        icon Flag
                            (case model.view of
                                ViewPositions ->
                                    Styling.ballIcon

                                ViewPosition _ ->
                                    Styling.ballIcon

                                ViewCreatePosition ->
                                    Styling.ballIcon

                                ViewEditPosition ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
                            )
                    }
                , link []
                    { url = Paths.transitions
                    , label =
                        icon Arrow
                            (case model.view of
                                ViewTransitions _ ->
                                    Styling.ballIcon

                                ViewTransition _ ->
                                    Styling.ballIcon

                                ViewCreateTransition ->
                                    Styling.ballIcon

                                ViewEditTransition ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
                            )
                    }
                , link []
                    { url = Paths.submissions
                    , label =
                        icon Bolt
                            (case model.view of
                                ViewSubmissions _ ->
                                    Styling.ballIcon

                                ViewSubmission _ ->
                                    Styling.ballIcon

                                ViewCreateSubmission ->
                                    Styling.ballIcon

                                ViewEditSubmission ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
                            )
                    }
                , link []
                    { url = Paths.topics
                    , label =
                        icon Book
                            (case model.view of
                                ViewTopics _ ->
                                    Styling.ballIcon

                                ViewTopic _ ->
                                    Styling.ballIcon

                                ViewCreateTopic ->
                                    Styling.ballIcon

                                ViewEditTopic ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
                            )
                    }
                ]

        sidebar =
            column
                [ spacing 40
                , height <| px model.size.height
                , alignRight
                , width <| px <| model.size.width // 2
                , Background.color Styling.c
                , Border.solid
                , Border.widthEach { bottom = 0, left = 5, right = 0, top = 0 }
                , Border.color Styling.e
                ]
                [ Input.button
                    []
                    { onPress =
                        Just <| SidebarNavigate Paths.start
                    , label =
                        icon Home
                            (if model.view == ViewStart then
                                Styling.ballIcon
                             else
                                Styling.actionIcon
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
                                    Styling.ballIcon

                                ViewPosition _ ->
                                    Styling.ballIcon

                                ViewCreatePosition ->
                                    Styling.ballIcon

                                ViewEditPosition ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
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
                                    Styling.ballIcon

                                ViewTransition _ ->
                                    Styling.ballIcon

                                ViewCreateTransition ->
                                    Styling.ballIcon

                                ViewEditTransition ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
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
                                    Styling.ballIcon

                                ViewSubmission _ ->
                                    Styling.ballIcon

                                ViewCreateSubmission ->
                                    Styling.ballIcon

                                ViewEditSubmission ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
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
                                    Styling.ballIcon

                                ViewTopic _ ->
                                    Styling.ballIcon

                                ViewCreateTopic ->
                                    Styling.ballIcon

                                ViewEditTopic ->
                                    Styling.ballIcon

                                _ ->
                                    Styling.actionIcon
                            )
                    }
                , Input.button
                    []
                    { onPress =
                        Just <| ToggleSidebar
                    , label =
                        icon Cross Styling.actionIcon
                    }
                ]
    in
    case model.device of
        Desktop ->
            row
                [ width fill
                , height fill
                , enterToken
                , confirm
                , viewPickPosition UpdateStartPosition model.positions
                    |> inFront model.selectingStartPosition
                , viewPickPosition UpdateEndPosition model.positions
                    |> inFront model.selectingEndPosition
                ]
                [ links
                , el [ width <| px <| round <| toFloat model.size.width * 0.8 ]
                    content
                ]
                |> layoutWith { options = [] }
                    [ Background.color Styling.c
                    , Styling.font
                    ]

        Mobile ->
            content
                |> layoutWith { options = [ noHover ] }
                    ([ Background.color Styling.c
                     , Styling.font
                     , enterToken
                     , confirm
                     , inFront model.sidebarOpen sidebar
                     , viewPickPosition UpdateStartPosition model.positions
                        |> inFront model.selectingStartPosition
                     , viewPickPosition UpdateEndPosition model.positions
                        |> inFront model.selectingEndPosition
                     ]
                        ++ (Swiper.onSwipeEvents Swiped |> List.map attribute)
                    )


viewPickPosition : (Info -> Msg) -> GcData (List Info) -> Element Msg
viewPickPosition msg ps =
    el [ width fill, height fill, Background.color Styling.c ] <|
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
                                el [ padding 10 ] <| el Styling.block <| text p.name
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
                [ Font.color Styling.e
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
        [ icon Flag Styling.mattIcon
        , pickPosition ToggleStartPosition form.startPosition
        ]


viewTransitionPickers : Form -> Element Msg
viewTransitionPickers form =
    el [ center ] <|
        paragraph
            [ centerY ]
            [ pickPosition ToggleStartPosition form.startPosition
            , el [ padding 20 ] <| icon Arrow Styling.mattIcon
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
                        Styling.actionIcon
                }

        Just { name } ->
            Input.button [ center ]
                { onPress =
                    Just msg
                , label =
                    el Styling.link <| text name
                }


editRow : String -> Msg -> Element Msg
editRow name editMsg =
    el [] <|
        row
            [ spacing 20, centerY ]
            [ paragraph Styling.subtitle [ text name ]
            , Input.button []
                { onPress = Just editMsg
                , label = icon Write Styling.actionIcon
                }
            ]


nameEdit : Form -> Element Msg
nameEdit form =
    Input.text
        (center :: Styling.field)
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
                Styling.actionIcon
        }


minus : msg -> Element msg
minus msg =
    Input.button [ padding 10 ]
        { onPress = Just msg
        , label =
            icon Minus
                Styling.actionIcon
        }


editButtons : Msg -> Msg -> Element Msg
editButtons save delete =
    row
        [ spacing 20 ]
        [ Input.button [ padding 10 ]
            { onPress = Just save
            , label =
                icon Tick
                    Styling.actionIcon
            }
        , Input.button [ padding 10 ]
            { onPress = Just Cancel
            , label =
                icon Cross
                    Styling.actionIcon
            }
        , Input.button [ padding 10 ]
            { onPress = Just <| Confirm <| Just delete
            , label =
                icon Trash
                    Styling.actionIcon
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
                    Styling.actionIcon
            }
        , Input.button [ padding 10 ]
            { onPress = Just Cancel
            , label =
                icon Cross
                    Styling.actionIcon
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
                                (Styling.field
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
        [ icon Cogs (center :: Styling.bigIcon)
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
                                (Styling.field
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
        [ icon Notes (center :: Styling.bigIcon)
        , notes
        , buttons
        ]


viewSteps : Array String -> Element Msg
viewSteps steps =
    column
        []
        (steps
            |> Array.toList
            |> List.indexedMap
                (\i step ->
                    row
                        [ spacing 10 ]
                        [ el Styling.dot <| text <| (toString (i + 1) ++ ".")
                        , paragraph
                            []
                            [ text step
                            ]
                        ]
                )
        )


viewNotes : List String -> Element msg
viewNotes notes =
    column
        [ center
        , alignLeft
        ]
        (notes
            |> List.map
                (\x ->
                    let
                        content =
                            if Regex.contains matchLink x then
                                newTabLink [ spacing 5 ]
                                    { url = x
                                    , label =
                                        paragraph []
                                            [ icon Globe Styling.mattIcon
                                            , text <| domain x
                                            ]
                                    }
                            else
                                text x
                    in
                    paragraph
                        [ spacing 5 ]
                        [ el Styling.dot <| text "• "
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
                        [ el Styling.dot <| text "• "
                        , link Styling.link
                            { url = Paths.transition id
                            , label = text name
                            }
                        , text " "
                        , paragraph
                            []
                            [ text "("
                            , link Styling.link
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
                                    [ el Styling.dot <| text "• "
                                    , el Styling.link <| text t.name
                                    ]
                            }
                    )
            )


viewErrors : List String -> Element Msg
viewErrors errs =
    when (errs |> List.isEmpty |> not) <|
        column
            [ center, spacing 15 ]
            [ icon Warning Styling.mattIcon
            , viewNotes errs
            ]


domain : String -> String
domain s =
    Regex.find (Regex.AtMost 10) matchDomain s
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
        |> Maybe.withDefault s
