module View exposing (..)

import Api.Scalar exposing (Id(..))
import Array exposing (Array)
import Color
import Element exposing (Attribute, Element, alignRight, behind, centerX, centerY, column, decorativeImage, el, fill, fillPortion, focused, height, htmlAttribute, inFront, layoutWith, mouseOver, newTabLink, noHover, none, padding, paragraph, pointer, px, row, scrollbarY, spaceEvenly, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (button)
import Html exposing (Html)
import Html.Attributes
import List.Extra exposing (groupWhile)
import Regex
import RemoteData exposing (RemoteData(..))
import Style
import Types exposing (..)
import Utils exposing (icon, isJust, isPositionView, isSubmissionView, isTagView, isTopicView, isTransitionView, matchDomain, matchLink, noLabel, remoteUnwrap, when, whenJust)


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewApp appView ->
                    case appView of
                        ViewStart ->
                            el [ centerY, centerX ] <|
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
                                [ createHeader Flag
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , notesEditor model.form
                                , createButtons SaveCreatePosition
                                ]

                        ViewCreateSubmission ->
                            column []
                                [ createHeader Bolt
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , viewSubmissionPicker model.form
                                , stepsEditor model.form
                                , notesEditor model.form
                                , createButtons SaveCreateSubmission
                                ]

                        ViewCreateTag ->
                            column []
                                [ createHeader Tags
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , createButtons SaveCreateTag
                                ]

                        ViewCreateTopic ->
                            column []
                                [ createHeader Book
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , notesEditor model.form
                                , createButtons SaveCreateTopic
                                ]

                        ViewCreateTransition ->
                            column []
                                [ createHeader Arrow
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , viewTransitionPickers model.form
                                , stepsEditor model.form
                                , notesEditor model.form
                                , createButtons SaveCreateTransition
                                ]

                        ViewEditPosition _ ->
                            column [ height <| px model.size.height, scrollbarY ]
                                [ editHeader Flag
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , notesEditor model.form
                                , editButtons SaveEditPosition <| DeletePosition model.form.id
                                ]

                        ViewEditSubmission ->
                            column [ height <| px model.size.height, scrollbarY ]
                                [ editHeader Bolt
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , viewSubmissionPicker model.form
                                , stepsEditor model.form
                                , notesEditor model.form
                                , editTags model.tags <| Array.toList model.form.tags
                                , editButtons SaveEditSubmission <| DeleteSubmission model.form.id
                                ]

                        ViewEditTag ->
                            column [ height <| px model.size.height, scrollbarY ]
                                [ editHeader Tags
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , editButtons SaveEditTag <| DeleteTag model.form.id
                                ]

                        ViewEditTopic ->
                            column [ height <| px model.size.height, scrollbarY ]
                                [ editHeader Book
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , notesEditor model.form
                                , editButtons SaveEditTopic <| DeleteTopic model.form.id
                                ]

                        ViewEditTransition ->
                            column [ height <| px model.size.height, scrollbarY ]
                                [ editHeader Arrow
                                , viewErrors model.form.errors
                                , nameEdit model.form
                                , viewTransitionPickers model.form
                                , stepsEditor model.form
                                , notesEditor model.form
                                , editTags model.tags <| Array.toList model.form.tags
                                , editButtons SaveEditTransition <| DeleteTransition model.form.id
                                ]

                        ViewPosition data ->
                            data
                                |> viewRemote
                                    (\({ name, notes, submissions, transitionsFrom, transitionsTo, id } as position) ->
                                        let
                                            (Id idStr) =
                                                id
                                        in
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ editRow name Flag <| EditPosition position
                                            , viewNotes notes
                                            , column []
                                                [ addNewRow Bolt
                                                    (SetRouteThenNavigate
                                                        (PositionRoute id)
                                                        (CreateSubmissionRoute <| Just idStr)
                                                    )
                                                , viewTechList SubmissionRoute submissions
                                                ]
                                            , column []
                                                [ addNewRow Arrow
                                                    (SetRouteThenNavigate
                                                        (PositionRoute id)
                                                        (CreateTransitionRoute
                                                            (Just idStr)
                                                            Nothing
                                                        )
                                                    )
                                                , column []
                                                    (transitionsFrom
                                                        |> List.map
                                                            (\transition ->
                                                                paragraph
                                                                    [ centerY, centerX ]
                                                                    [ button []
                                                                        { onPress = Just <| NavigateTo <| TransitionRoute transition.id
                                                                        , label =
                                                                            el Style.link <|
                                                                                text transition.name
                                                                        }
                                                                    , text " ("
                                                                    , el [] <| text name
                                                                    , el [ padding 20 ] <| icon Arrow Style.mattIcon
                                                                    , button []
                                                                        { onPress = Just <| NavigateTo <| PositionRoute transition.endPosition.id
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
                                                                        { onPress = Just <| NavigateTo <| TransitionRoute transition.id
                                                                        , label =
                                                                            el Style.link <|
                                                                                text transition.name
                                                                        }
                                                                    , text " ("
                                                                    , button []
                                                                        { onPress = Just <| NavigateTo <| PositionRoute transition.startPosition.id
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
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ addNewRow Flag <| NavigateTo CreatePositionRoute
                                            , blocks PositionRoute positions
                                            ]
                                    )

                        ViewSubmission data ->
                            data
                                |> viewRemote
                                    (\sub ->
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ editRow sub.name Bolt <| EditSubmission sub
                                            , row
                                                [ spacing 10 ]
                                                [ icon Flag Style.mattIcon
                                                , button []
                                                    { onPress = Just <| NavigateTo <| PositionRoute sub.position.id
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
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ addNewRow Bolt <|
                                                NavigateTo
                                                    (CreateSubmissionRoute Nothing)
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
                                                                                    { onPress = Just <| NavigateTo <| PositionRoute id
                                                                                    , label =
                                                                                        paragraph Style.choice
                                                                                            [ text name ]
                                                                                    }
                                                                            )
                                                                    , blocks SubmissionRoute g
                                                                    ]
                                                        )
                                                )
                                            ]
                                    )

                        ViewTag data ->
                            data
                                |> viewRemote
                                    (\t ->
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ editRow t.name Tags <| EditTag t
                                            , column []
                                                [ icon Bolt Style.mattIcon
                                                , viewTechList SubmissionRoute t.submissions
                                                ]
                                            , column []
                                                [ icon Arrow Style.mattIcon
                                                , viewTechList TransitionRoute t.transitions
                                                ]
                                            ]
                                    )

                        ViewTags ->
                            model.tags
                                |> viewRemote
                                    (\tags ->
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ addNewRow Tags <| NavigateTo CreateTagRoute
                                            , blocks TagRoute tags
                                            ]
                                    )

                        ViewTopic data ->
                            data
                                |> viewRemote
                                    (\t ->
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ editRow t.name Book <| EditTopic t
                                            , viewNotes t.notes
                                            ]
                                    )

                        ViewTopics data ->
                            data
                                |> viewRemote
                                    (\topics ->
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ addNewRow Book <| NavigateTo CreateTopicRoute
                                            , blocks TopicRoute topics
                                            ]
                                    )

                        ViewTransition data ->
                            data
                                |> viewRemote
                                    (\({ steps, startPosition, endPosition, notes, tags } as t) ->
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ editRow t.name Arrow <| EditTransition t
                                            , paragraph
                                                [ centerY, centerX ]
                                                [ button []
                                                    { onPress = Just <| NavigateTo <| PositionRoute startPosition.id
                                                    , label =
                                                        el Style.link <|
                                                            text startPosition.name
                                                    }
                                                , el [ padding 20 ] <| icon Arrow Style.mattIcon
                                                , button []
                                                    { onPress = Just <| NavigateTo <| PositionRoute endPosition.id
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
                                        column [ height <| px model.size.height, scrollbarY ]
                                            [ addNewRow Arrow <|
                                                NavigateTo
                                                    (CreateTransitionRoute Nothing Nothing)
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
                                                                                    { onPress = Just <| NavigateTo <| PositionRoute id
                                                                                    , label =
                                                                                        paragraph Style.choice
                                                                                            [ text name ]
                                                                                    }
                                                                            )
                                                                    , blocks TransitionRoute g
                                                                    ]
                                                        )
                                                )
                                            ]
                                    )

                ViewLogin ->
                    let
                        inputWidth =
                            if model.device == Desktop then
                                px <| model.size.width // 3
                            else
                                fill
                    in
                    el [ centerY, width fill, padding 20 ] <|
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
                                    Just <| NavigateTo SignUp
                                , label =
                                    icon NewUser
                                        Style.actionIcon
                                }
                            , viewErrors model.form.errors
                            , Input.email
                                ([ centerX
                                 , width inputWidth
                                 ]
                                    ++ Style.field
                                )
                                { onChange = Just UpdateEmail
                                , text = model.form.email
                                , label =
                                    Input.labelLeft [] <|
                                        icon Email Style.bigIcon
                                , placeholder = Nothing
                                }
                            , Input.currentPassword
                                ([ centerX
                                 , width inputWidth
                                 ]
                                    ++ Style.field
                                )
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
                    let
                        inputWidth =
                            if model.device == Desktop then
                                px <| model.size.width // 3
                            else
                                fill
                    in
                    el [ centerY, width fill, padding 20 ] <|
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
                                    Just <| NavigateTo Login
                                , label =
                                    icon SignIn
                                        Style.actionIcon
                                }
                            , viewErrors model.form.errors
                            , Input.email
                                ([ centerX, width inputWidth ] ++ Style.field)
                                { onChange = Just UpdateEmail
                                , text = model.form.email
                                , label =
                                    Input.labelLeft [] <|
                                        icon Email Style.bigIcon
                                , placeholder = Nothing
                                }
                            , Input.currentPassword
                                ([ centerX, width inputWidth ] ++ Style.field)
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
            else if model.device == Mobile then
                case model.view of
                    ViewApp appView ->
                        sidebar model.sidebarOpen appView

                    _ ->
                        behind none
            else
                behind none
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

                    ViewApp appView ->
                        row
                            [ width fill
                            , height fill
                            ]
                            [ links appView
                            , el
                                [ width <| px <| round <| toFloat model.size.width * 0.8
                                , height <| px model.size.height
                                , scrollbarY
                                ]
                                content
                            ]

        Mobile ->
            layoutWith
                { options =
                    [ noHover
                    , Element.focusStyle
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
                content


createHeader : FaIcon -> Element msg
createHeader faIcon =
    el [ centerX ] <|
        row [ spacing 20, padding 20 ]
            [ icon faIcon Style.mattIcon
            , icon Plus Style.mattIcon
            ]


editHeader : FaIcon -> Element msg
editHeader faIcon =
    el [ centerX ] <|
        row [ spacing 20, padding 20 ]
            [ icon faIcon Style.mattIcon
            , icon Write Style.mattIcon
            ]


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


links : AppView -> Element Msg
links view =
    el [ centerX, centerY ] <|
        column
            [ padding 20
            , spacing 20
            ]
        <|
            icons False view


sidebar : Bool -> AppView -> Attribute Msg
sidebar isOpen view =
    if isOpen then
        row [ height fill ]
            [ button [ width <| fillPortion 1, height fill ]
                { onPress = Just ToggleSidebar
                , label = none
                }
            , column
                [ height fill
                , alignRight
                , width <| fillPortion 1
                , Background.color Style.c
                , Border.solid
                , Border.widthEach { bottom = 0, left = 5, right = 0, top = 0 }
                , Border.color Style.e
                , spaceEvenly
                ]
              <|
                icons True view
            ]
            |> inFront
    else
        button [ alignRight ]
            { onPress = Just ToggleSidebar
            , label =
                icon Bars
                    [ height <| px 50
                    , width <| px 50
                    , Font.color Style.e
                    , Font.size 30
                    ]
            }
            |> inFront


icons : Bool -> AppView -> List (Element Msg)
icons isSidebar view =
    let
        nav =
            if isSidebar then
                SidebarNavigate
            else
                NavigateTo
    in
    [ button [ centerX ]
        { onPress = Just <| nav Start
        , label =
            icon Home
                (if view == ViewStart then
                    ballIcon
                 else
                    Style.actionIcon
                )
        }
    , button [ centerX ]
        { onPress = Just <| nav Positions
        , label =
            icon Flag
                (if isPositionView view then
                    ballIcon
                 else
                    Style.actionIcon
                )
        }
    , button [ centerX ]
        { onPress = Just <| nav Transitions
        , label =
            icon Arrow
                (if isTransitionView view then
                    ballIcon
                 else
                    Style.actionIcon
                )
        }
    , button [ centerX ]
        { onPress = Just <| nav Submissions
        , label =
            icon Bolt
                (if isSubmissionView view then
                    ballIcon
                 else
                    Style.actionIcon
                )
        }
    , button [ centerX ]
        { onPress =
            Just <| nav TagsRoute
        , label =
            icon Tags
                (if isTagView view then
                    ballIcon
                 else
                    Style.actionIcon
                )
        }
    , button [ centerX ]
        { onPress = Just <| nav Topics
        , label =
            icon Book
                (if isTopicView view then
                    ballIcon
                 else
                    Style.actionIcon
                )
        }
    , button [ centerX ]
        { onPress = Just <| Logout
        , label =
            icon SignOut Style.actionIcon
        }
    ]
        ++ (if isSidebar then
                [ Input.button
                    [ centerX ]
                    { onPress =
                        Just <| ToggleSidebar
                    , label =
                        icon Cross Style.actionIcon
                    }
                ]
            else
                []
           )


transitionPositions : Info -> Info -> Element Msg
transitionPositions startPosition endPosition =
    paragraph
        [ centerY, centerX ]
        [ button []
            { onPress = Just <| NavigateTo <| PositionRoute startPosition.id
            , label =
                el Style.link <|
                    text startPosition.name
            }
        , el [ padding 20 ] <| icon Arrow Style.mattIcon
        , button []
            { onPress = Just <| NavigateTo <| PositionRoute endPosition.id
            , label =
                el Style.link <|
                    text endPosition.name
            }
        ]


blocks : (Id -> Route) -> List { r | id : Id, name : String } -> Element Msg
blocks route =
    List.map
        (\{ id, name } ->
            block name <| NavigateTo <| route id
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


viewPickPosition : (Info -> Msg) -> RemoteData.WebData (List Info) -> Element Msg
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


viewRemote : (a -> Element Msg) -> RemoteData.WebData a -> Element Msg
viewRemote fn data =
    case data of
        NotAsked ->
            el [ centerX ] <| text "not asked"

        Loading ->
            icon Waiting
                [ Font.color Style.e
                , Font.size 60
                , centerX
                , centerY
                ]

        Failure err ->
            viewErrors [ toString err ]

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
    row
        [ spacing 20 ]
        [ icon faIcon Style.mattIcon
        , paragraph
            [ Font.size 35
            , Font.color Style.e
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
    el [ centerX ] <|
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
    el [ centerX ] <|
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
                                    ++ [ htmlAttribute <| Html.Attributes.rows 4
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
            el [ centerX ] <|
                row
                    []
                    [ plus (UpdateForm { form | steps = Array.push "" form.steps })
                    , when (not <| Array.isEmpty form.steps) <|
                        minus (UpdateForm { form | steps = Array.slice 0 -1 form.steps })
                    ]
    in
    column
        [ spacing 10
        , width fill
        , height Element.shrink
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
                                    ++ [ htmlAttribute <| Html.Attributes.rows 4
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
            el [ centerX ] <|
                row
                    []
                    [ plus (UpdateForm { form | notes = Array.push "" form.notes })
                    , when (not <| Array.isEmpty form.notes) <|
                        minus (UpdateForm { form | notes = Array.slice 0 -1 form.notes })
                    ]
    in
    column
        [ spacing 10
        , width fill
        , height Element.shrink
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
                            { onPress = Just <| NavigateTo <| TransitionRoute id
                            , label = text name
                            }
                        , text " "
                        , paragraph
                            []
                            [ text "("
                            , button Style.link
                                { onPress =
                                    Just <| NavigateTo <| PositionRoute endPosition.id
                                , label =
                                    text endPosition.name
                                }
                            , text ")"
                            ]
                        ]
                )
        )


viewTechList : (Id -> Route) -> List { r | name : String, id : Id } -> Element Msg
viewTechList route xs =
    if List.isEmpty xs then
        el [] <| text "None!"
    else
        column
            []
            (xs
                |> List.map
                    (\t ->
                        button []
                            { onPress = Just <| NavigateTo <| route t.id
                            , label =
                                paragraph
                                    []
                                    [ el [ Font.color Style.e ] <| text "• "
                                    , el Style.link <| text t.name
                                    ]
                            }
                    )
            )


editTags : RemoteData.WebData (List Info) -> List Info -> Element Msg
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
                                    { onPress = Just <| NavigateTo <| TagRoute t.id
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
            [ spacing 15 ]
            [ el [ centerX ] <| icon Warning Style.mattIcon
            , viewNotes <| Array.fromList errs
            ]


domain : String -> String
domain s =
    Regex.find (Regex.AtMost 10) matchDomain s
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
        |> Maybe.withDefault s
