module View exposing (..)

import Array exposing (Array)
import Color
import Element exposing (Attribute, Element, alignRight, centerX, centerY, column, decorativeImage, el, empty, fill, focused, height, htmlAttribute, inFront, layoutWith, mouseOver, newTabLink, noHover, padding, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (button)
import Html exposing (Html)
import Html.Attributes
import List.Extra exposing (groupWhile)
import Paths
import Regex
import RemoteData exposing (RemoteData(..))
import Style
import Types exposing (..)
import Utils exposing (formatErrors, icon, isJust, isPositionView, isSubmissionView, isTagView, isTopicView, isTransitionView, matchDomain, matchLink, noLabel, remoteUnwrap, when, whenJust)
import Window exposing (Size)


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewStart ->
                    el [ centerY ] <|
                        column [ spacing 20 ]
                            [ decorativeImage
                                [ height <| px 100
                                , width <| px 100
                                , centerX
                                ]
                                { src = "/map.svg" }
                            , el
                                [ Font.size 45, Font.color Style.e, centerX ]
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

                ViewCreateTag ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , createButtons SaveCreateTag
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
                        , editTags model.tags <| Array.toList model.form.tags
                        , editButtons SaveEditSubmission <| DeleteSubmission model.form.id
                        ]

                ViewEditTag ->
                    column []
                        [ viewErrors model.form.errors
                        , nameEdit model.form
                        , editButtons SaveEditTag <| DeleteTag model.form.id
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
                        , editTags model.tags <| Array.toList model.form.tags
                        , editButtons SaveEditTransition <| DeleteTransition model.form.id
                        ]

                ViewLogin ->
                    el [ centerY ] <|
                        column
                            [ centerX
                            , spacing 20
                            , Background.color Style.c
                            , width fill
                            , height fill
                            ]
                            [ decorativeImage
                                [ height <| px 100
                                , width <| px 100
                                , centerX
                                ]
                                { src = "/map.svg" }
                            , el
                                [ Font.size 45, Font.color Style.e, centerX ]
                              <|
                                text "ROTEIRO"
                            , Input.button [ centerX ]
                                { onPress =
                                    Just <| NavigateTo Paths.signUp
                                , label =
                                    icon NewUser
                                        Style.actionIcon
                                }
                            , Input.email
                                ([ centerX, width <| px <| model.size.width // 3 ] ++ Style.field)
                                { onChange = Just UpdateEmail
                                , text = model.form.email
                                , label =
                                    Input.labelLeft [] <|
                                        icon Email Style.bigIcon
                                , placeholder = Nothing
                                }
                            , Input.currentPassword
                                ([ centerX, width <| px <| model.size.width // 3 ] ++ Style.field)
                                { onChange = Just UpdatePassword
                                , text = model.form.password
                                , label =
                                    Input.labelLeft [] <|
                                        icon Lock Style.bigIcon
                                , placeholder = Nothing
                                , show = False
                                }
                            , Input.button [ centerX ]
                                { onPress =
                                    Just <| LoginSubmit
                                , label =
                                    icon SignIn
                                        Style.actionIcon
                                }
                            ]

                ViewSignUp ->
                    el [ centerY ] <|
                        column
                            [ centerX
                            , spacing 20
                            , Background.color Style.c
                            , width fill
                            , height fill
                            ]
                            [ decorativeImage
                                [ height <| px 100
                                , width <| px 100
                                , centerX
                                ]
                                { src = "/map.svg" }
                            , el
                                [ Font.size 45, Font.color Style.e, centerX ]
                              <|
                                text "ROTEIRO"
                            , Input.button [ centerX ]
                                { onPress =
                                    Just <| NavigateTo Paths.login
                                , label =
                                    icon SignIn
                                        Style.actionIcon
                                }
                            , Input.email
                                ([ centerX, width <| px <| model.size.width // 3 ] ++ Style.field)
                                { onChange = Just UpdateEmail
                                , text = model.form.email
                                , label =
                                    Input.labelLeft [] <|
                                        icon Email Style.bigIcon
                                , placeholder = Nothing
                                }
                            , Input.currentPassword
                                ([ centerX, width <| px <| model.size.width // 3 ] ++ Style.field)
                                { onChange = Just UpdatePassword
                                , text = model.form.password
                                , label =
                                    Input.labelLeft [] <|
                                        icon Lock Style.bigIcon
                                , placeholder = Nothing
                                , show = False
                                }
                            , Input.button [ centerX ]
                                { onPress =
                                    Just <| SignUpSubmit
                                , label =
                                    icon NewUser
                                        Style.actionIcon
                                }
                            ]

                ViewPosition data ->
                    data
                        |> viewRemote
                            (\({ name, notes, submissions, transitionsFrom, transitionsTo } as position) ->
                                column [ height <| px model.size.height, scrollbarY ]
                                    [ editRow name Flag <| EditPosition position
                                    , viewNotes notes
                                    , column []
                                        [ addNewRow Bolt <| CreateSubmission <| Just position
                                        , viewTechList Paths.submission submissions
                                        ]
                                    , column []
                                        [ addNewRow Arrow <| CreateTransition <| Just position
                                        , column []
                                            (transitionsFrom
                                                |> List.map
                                                    (\transition ->
                                                        paragraph
                                                            [ centerY, centerX ]
                                                            [ button []
                                                                { onPress = Just <| NavigateTo <| Paths.transition transition.id
                                                                , label =
                                                                    el Style.link <|
                                                                        text transition.name
                                                                }
                                                            , text " ("
                                                            , el [] <| text name
                                                            , el [ padding 20 ] <| icon Arrow Style.mattIcon
                                                            , button []
                                                                { onPress = Just <| NavigateTo <| Paths.position transition.endPosition.id
                                                                , label =
                                                                    el Style.link <|
                                                                        text transition.endPosition.name
                                                                }
                                                            , text ")"
                                                            ]
                                                    )
                                            )
                                        , column []
                                            (transitionsTo
                                                |> List.map
                                                    (\transition ->
                                                        paragraph
                                                            [ centerY, centerX ]
                                                            [ button []
                                                                { onPress = Just <| NavigateTo <| Paths.transition transition.id
                                                                , label =
                                                                    el Style.link <|
                                                                        text transition.name
                                                                }
                                                            , text " ("
                                                            , button []
                                                                { onPress = Just <| NavigateTo <| Paths.position transition.startPosition.id
                                                                , label =
                                                                    el Style.link <|
                                                                        text transition.startPosition.name
                                                                }
                                                            , el [ padding 20 ] <| icon Arrow Style.mattIcon
                                                            , el [] <| text name
                                                            , text ")"
                                                            ]
                                                    )
                                            )
                                        ]
                                    ]
                            )

                ViewPositions ->
                    model.positions
                        |> viewRemote
                            (\positions ->
                                column
                                    []
                                    [ addNewRow Flag CreatePosition
                                    , blocks Paths.position positions
                                    ]
                            )

                ViewSubmission data ->
                    data
                        |> viewRemote
                            (\sub ->
                                column []
                                    [ editRow sub.name Bolt <| EditSubmission sub
                                    , row
                                        [ spacing 10 ]
                                        [ icon Flag Style.mattIcon
                                        , button []
                                            { onPress = Just <| NavigateTo <| Paths.position sub.position.id
                                            , label =
                                                el Style.link <|
                                                    text sub.position.name
                                            }
                                        ]
                                    , viewSteps sub.steps
                                    , viewNotes sub.notes
                                    , viewTags sub.tags
                                    ]
                            )

                ViewSubmissions data ->
                    data
                        |> viewRemote
                            (\submissions ->
                                column
                                    []
                                    [ addNewRow Bolt <| CreateSubmission Nothing
                                    , column [ spacing 20 ] <|
                                        (submissions
                                            |> List.sortBy (.position >> .id >> (\(Id id) -> id))
                                            |> groupWhile (\a b -> a.position.id == b.position.id)
                                            |> List.map
                                                (\g ->
                                                    el [ centerX ] <|
                                                        column
                                                            []
                                                            [ g
                                                                |> List.head
                                                                |> Maybe.map .position
                                                                |> whenJust
                                                                    (\{ id, name } ->
                                                                        button [ centerX ]
                                                                            { onPress = Just <| NavigateTo <| Paths.position id
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

                ViewTag data ->
                    data
                        |> viewRemote
                            (\t ->
                                column []
                                    [ editRow t.name Tags <| EditTag t
                                    , column []
                                        [ icon Bolt Style.mattIcon
                                        , viewTechList Paths.submission t.submissions
                                        ]
                                    , column []
                                        [ icon Arrow Style.mattIcon
                                        , viewTechList Paths.transition t.transitions
                                        ]
                                    ]
                            )

                ViewTags ->
                    model.tags
                        |> viewRemote
                            (\tags ->
                                column
                                    []
                                    [ addNewRow Tags CreateTag
                                    , blocks Paths.tag tags
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
                                    []
                                    [ addNewRow Book CreateTopic
                                    , blocks Paths.topic topics
                                    ]
                            )

                ViewTransition data ->
                    data
                        |> viewRemote
                            (\({ steps, startPosition, endPosition, notes, tags } as t) ->
                                column
                                    []
                                    [ editRow t.name Arrow <| EditTransition t
                                    , paragraph
                                        [ centerY, centerX ]
                                        [ button []
                                            { onPress = Just <| NavigateTo <| Paths.position startPosition.id
                                            , label =
                                                el Style.link <|
                                                    text startPosition.name
                                            }
                                        , el [ padding 20 ] <| icon Arrow Style.mattIcon
                                        , button []
                                            { onPress = Just <| NavigateTo <| Paths.position endPosition.id
                                            , label =
                                                el Style.link <|
                                                    text endPosition.name
                                            }
                                        ]
                                    , viewSteps steps
                                    , viewNotes notes
                                    , viewTags tags
                                    ]
                            )

                ViewTransitions data ->
                    data
                        |> viewRemote
                            (\transitions ->
                                column
                                    []
                                    [ addNewRow Arrow <| CreateTransition Nothing
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
                                                    el [ centerX ] <|
                                                        column
                                                            []
                                                            [ g
                                                                |> List.head
                                                                |> Maybe.map .startPosition
                                                                |> whenJust
                                                                    (\{ id, name } ->
                                                                        button [ centerX ]
                                                                            { onPress = Just <| NavigateTo <| Paths.position id
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

                ViewWaiting ->
                    el [ centerX, centerY ] <| icon Waiting Style.bigIcon

        confirm =
            model.confirm
                |> whenJust
                    (\msg ->
                        el [ centerX, centerY, padding 10, spacing 20 ] <|
                            column
                                [ centerX ]
                                [ icon Question (centerX :: Style.bigIcon)
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

        modal =
            if isJust model.confirm then
                confirm
                    |> inFront
            else if model.selectingEndPosition then
                viewPickPosition UpdateEndPosition model.positions
                    |> inFront
            else if model.selectingStartPosition then
                viewPickPosition UpdateStartPosition model.positions
                    |> inFront
            else
                empty
                    |> inFront
    in
    case model.device of
        Desktop ->
            layoutWith
                { options =
                    [ Element.focusStyle
                        { borderColor = Nothing
                        , backgroundColor = Nothing
                        , shadow = Nothing
                        }
                    ]
                }
                [ Background.color Style.c
                , Style.font
                , modal
                ]
            <|
                case model.view of
                    ViewLogin ->
                        content

                    ViewSignUp ->
                        content

                    ViewWaiting ->
                        content

                    _ ->
                        row
                            [ width fill
                            , height fill
                            ]
                            [ links model.view
                            , el
                                [ width <| px <| round <| toFloat model.size.width * 0.8
                                , height <| px model.size.height
                                , scrollbarY
                                ]
                                content
                            ]

        Mobile ->
            layoutWith { options = [ noHover ] }
                [ Background.color Style.c
                , Style.font
                , modal
                ]
                content


ballIcon : List (Attribute msg)
ballIcon =
    [ Font.color Style.c
    , Font.size 35
    , pointer
    , Background.color Style.e
    , Border.rounded 30
    , width <| px 60
    , height <| px 60
    , mouseOver
        [ Font.color Style.a
        ]
    , focused
        [ Border.glow Color.white 0
        ]
    ]


links : View -> Element Msg
links view =
    el [ centerX, centerY ] <|
        column
            [ padding 20
            , spacing 20
            ]
            [ button []
                { onPress = Just <| NavigateTo <| Paths.start
                , label =
                    icon Home
                        (if view == ViewStart then
                            ballIcon
                         else
                            Style.actionIcon
                        )
                }
            , button []
                { onPress = Just <| NavigateTo <| Paths.positions
                , label =
                    icon Flag
                        (if isPositionView view then
                            ballIcon
                         else
                            Style.actionIcon
                        )
                }
            , button []
                { onPress = Just <| NavigateTo <| Paths.transitions
                , label =
                    icon Arrow
                        (if isTransitionView view then
                            ballIcon
                         else
                            Style.actionIcon
                        )
                }
            , button []
                { onPress = Just <| NavigateTo <| Paths.submissions
                , label =
                    icon Bolt
                        (if isSubmissionView view then
                            ballIcon
                         else
                            Style.actionIcon
                        )
                }
            , button []
                { onPress =
                    Just <| NavigateTo Paths.tags
                , label =
                    icon Tags
                        (if isTagView view then
                            ballIcon
                         else
                            Style.actionIcon
                        )
                }
            , button []
                { onPress = Just <| NavigateTo <| Paths.topics
                , label =
                    icon Book
                        (if isTopicView view then
                            ballIcon
                         else
                            Style.actionIcon
                        )
                }
            , button []
                { onPress = Just <| Logout
                , label =
                    icon SignOut Style.actionIcon
                }
            ]


sidebar : Size -> View -> Element Msg
sidebar size view =
    column
        [ spacing 40
        , height <| px size.height
        , alignRight
        , width <| px <| size.width // 2
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
                    (if view == ViewStart then
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
                    (if isPositionView view then
                        ballIcon
                     else
                        Style.actionIcon
                    )
            }
        , Input.button
            []
            { onPress =
                Just <| SidebarNavigate Paths.transitions
            , label =
                icon Arrow
                    (if isTransitionView view then
                        ballIcon
                     else
                        Style.actionIcon
                    )
            }
        , Input.button
            []
            { onPress =
                Just <| SidebarNavigate Paths.submissions
            , label =
                icon Bolt
                    (if isSubmissionView view then
                        ballIcon
                     else
                        Style.actionIcon
                    )
            }
        , Input.button
            []
            { onPress =
                Just <| SidebarNavigate Paths.topics
            , label =
                icon Book
                    (if isTopicView view then
                        ballIcon
                     else
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


transitionPositions : Info -> Info -> Element Msg
transitionPositions startPosition endPosition =
    paragraph
        [ centerY, centerX ]
        [ button []
            { onPress = Just <| NavigateTo <| Paths.position startPosition.id
            , label =
                el Style.link <|
                    text startPosition.name
            }
        , el [ padding 20 ] <| icon Arrow Style.mattIcon
        , button []
            { onPress = Just <| NavigateTo <| Paths.position endPosition.id
            , label =
                el Style.link <|
                    text endPosition.name
            }
        ]


blocks : (Id -> String) -> List { r | id : Id, name : String } -> Element Msg
blocks url =
    List.map
        (\{ id, name } ->
            block name <| NavigateTo <| url id
        )
        >> paragraph []


block : String -> msg -> Element msg
block txt msg =
    button [ padding 10 ]
        { onPress = Just <| msg
        , label =
            paragraph Style.block
                [ text txt
                ]
        }


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
            el [ centerX ] <| text "not asked"

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
        [ spacing 10, centerX ]
        [ icon Flag Style.mattIcon
        , pickPosition ToggleStartPosition form.startPosition
        ]


viewTransitionPickers : Form -> Element Msg
viewTransitionPickers form =
    el [ centerX ] <|
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
            Input.button [ centerX ]
                { onPress =
                    Just msg
                , label =
                    icon Question
                        Style.actionIcon
                }

        Just { name } ->
            Input.button [ centerX ]
                { onPress =
                    Just msg
                , label =
                    el Style.link <| text name
                }


editRow : String -> FaIcon -> Msg -> Element Msg
editRow name faIcon editMsg =
    el [ centerX ] <|
        row
            [ spacing 20, centerY ]
            [ icon faIcon Style.mattIcon
            , paragraph
                [ Font.size 35
                , Font.color Style.e
                , width shrink
                ]
                [ text name ]
            , Input.button []
                { onPress = Just editMsg
                , label = icon Write Style.actionIcon
                }
            ]


addNewRow : FaIcon -> Msg -> Element Msg
addNewRow fa msg =
    el [ centerX ] <|
        row [ spacing 20, padding 30 ]
            [ icon fa Style.mattIcon
            , plus msg
            ]


nameEdit : Form -> Element Msg
nameEdit form =
    Input.text
        (centerX :: Style.field)
        { onChange = Just <| \str -> UpdateForm { form | name = str }
        , text = form.name
        , label = noLabel
        , placeholder = Nothing
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
                                    ++ [ width Element.shrink
                                       , htmlAttribute <| Html.Attributes.rows 4
                                       , htmlAttribute <| Html.Attributes.cols 40
                                       , htmlAttribute <| Html.Attributes.wrap "hard"
                                       , htmlAttribute <| Html.Attributes.style [ ( "white-space", "normal" ) ]
                                       , centerX
                                       ]
                                )
                                { onChange =
                                    Just <|
                                        \str ->
                                            UpdateForm
                                                { form | steps = Array.set i str form.steps }
                                , text = v
                                , label = noLabel
                                , placeholder = Nothing
                                , spellcheck = True
                                }
                        )
                    |> Array.toList
                )

        buttons =
            row
                [ centerX ]
                [ plus (UpdateForm { form | steps = Array.push "" form.steps })
                , when (not <| Array.isEmpty form.steps) <|
                    minus (UpdateForm { form | steps = Array.slice 0 -1 form.steps })
                ]
    in
    column
        [ spacing 10
        , width fill
        ]
        [ icon Cogs (centerX :: Style.bigIcon)
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
                                    ++ [ width Element.shrink
                                       , htmlAttribute <| Html.Attributes.rows 4
                                       , htmlAttribute <| Html.Attributes.cols 40
                                       , htmlAttribute <| Html.Attributes.wrap "hard"
                                       , htmlAttribute <| Html.Attributes.style [ ( "white-space", "normal" ) ]
                                       , centerX
                                       ]
                                )
                                { onChange =
                                    Just <|
                                        \str ->
                                            UpdateForm
                                                { form | notes = Array.set i str form.notes }
                                , text = v
                                , label = noLabel
                                , placeholder = Nothing
                                , spellcheck = True
                                }
                        )
                    |> Array.toList
                )

        buttons =
            row
                [ centerX ]
                [ plus (UpdateForm { form | notes = Array.push "" form.notes })
                , when (not <| Array.isEmpty form.notes) <|
                    minus (UpdateForm { form | notes = Array.slice 0 -1 form.notes })
                ]
    in
    column
        [ spacing 10
        , width fill
        ]
        [ icon Notes (centerX :: Style.bigIcon)
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
                            [ el [ Font.color Style.e ] <| text <| (toString (i + 1) ++ ".")
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
                            [ el [ Font.color Style.e ] <| text "• "
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
                        [ el [ Font.color Style.e ] <| text "• "
                        , button Style.link
                            { onPress = Just <| NavigateTo <| Paths.transition id
                            , label = text name
                            }
                        , text " "
                        , paragraph
                            []
                            [ text "("
                            , button Style.link
                                { onPress =
                                    Just <| NavigateTo <| Paths.position endPosition.id
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
                        button []
                            { onPress = Just <| NavigateTo <| fn t.id
                            , label =
                                paragraph
                                    []
                                    [ el [ Font.color Style.e ] <| text "• "
                                    , el Style.link <| text t.name
                                    ]
                            }
                    )
            )


editTags : GcData (List Info) -> List Info -> Element Msg
editTags tags xs =
    el [ centerX ] <|
        column [ spacing 20 ]
            [ icon Tags Style.mattIcon
            , tags
                |> remoteUnwrap (icon Waiting Style.mattIcon)
                    (List.filter
                        (flip List.member xs >> not)
                        >> List.map
                            (\tag ->
                                block (tag.name ++ " +") <| AddTag tag
                            )
                        >> paragraph [ padding 20 ]
                    )
            , xs
                |> List.indexedMap
                    (\i tag ->
                        block (tag.name ++ " -") <| RemoveTag i
                    )
                |> paragraph [ padding 20 ]
            ]


viewTags : List Info -> Element Msg
viewTags tags =
    el [ centerX ] <|
        column [ spacing 20 ]
            [ icon Tags Style.mattIcon
            , if List.isEmpty tags then
                el [] <| text "None!"
              else
                column
                    []
                    (tags
                        |> List.map
                            (\t ->
                                button []
                                    { onPress = Just <| NavigateTo <| Paths.tag t.id
                                    , label =
                                        paragraph
                                            []
                                            [ el [ Font.color Style.e, padding 5 ] <| text "• "
                                            , el Style.link <| text t.name
                                            ]
                                    }
                            )
                    )
            ]


viewErrors : List String -> Element Msg
viewErrors errs =
    when (errs |> List.isEmpty |> not) <|
        column
            [ centerX, spacing 15 ]
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
