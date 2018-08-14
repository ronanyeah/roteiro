module View exposing (..)

import Api.Scalar exposing (Id(..))
import Array exposing (Array)
import Color
import Element exposing (Attribute, Element, alignRight, behind, centerX, centerY, column, decorativeImage, el, fill, fillPortion, focused, height, htmlAttribute, inFront, layoutWith, maximum, mouseOver, newTabLink, noHover, none, padding, paragraph, px, row, scrollbarY, shrink, spaceEvenly, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (button)
import Html exposing (Html)
import Html.Attributes
import Keydown exposing (onEnter, onKeydown)
import List.Extra exposing (groupWhile)
import Regex
import RemoteData exposing (RemoteData(..))
import Style
import Types exposing (..)
import Utils exposing (icon, isJust, isPositionView, isSubmissionView, isTagView, isTopicView, isTransitionView, matchDomain, matchLink, noLabel, unwrap, when, whenJust)


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewApp appView ->
                    if model.device == Desktop then
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
                              <|
                                viewApp model appView
                            ]
                    else
                        viewApp model appView

                ViewLogin ->
                    let
                        inputWidth =
                            if model.device == Desktop then
                                px <| model.size.width // 3
                            else
                                fill

                        change =
                            model.form.errors
                                |> unwrap (always Nothing) (always Just)
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
                            , row
                                [ width shrink
                                , centerX
                                , spacing 10
                                , Font.color Style.e
                                ]
                                [ icon SignIn Style.mattIcon, text "Login" ]
                            , viewErrors model.form.errors
                            , Input.email
                                ([ centerX
                                 , width inputWidth
                                 ]
                                    ++ Style.field
                                )
                                { onChange = change UpdateEmail
                                , text = model.form.email
                                , label =
                                    Input.labelLeft [] <|
                                        icon Email Style.bigIcon
                                , placeholder = Just <| Input.placeholder [] <| el [ centerY ] <| text "email address"
                                }
                            , Input.currentPassword
                                ([ centerX
                                 , width inputWidth
                                 ]
                                    ++ Style.field
                                )
                                { onChange = change UpdatePassword
                                , text = model.form.password
                                , label =
                                    Input.labelLeft [] <|
                                        icon Lock Style.bigIcon
                                , placeholder = Just <| Input.placeholder [] <| el [ centerY ] <| text "password"
                                , show = False
                                }
                            , el [ centerX ]
                                (model.form.errors
                                    |> unwrap spinner
                                        (always
                                            (actionIcon Arrow (Just <| LoginSubmit))
                                        )
                                )
                            , button [ centerX, Font.underline ]
                                { onPress = Just <| NavigateTo SignUp
                                , label = text "Need to sign up?"
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
                            , row
                                [ width shrink
                                , centerX
                                , spacing 10
                                , Font.color Style.e
                                ]
                                [ icon NewUser Style.mattIcon, text "Sign Up" ]
                            , viewErrors model.form.errors
                            , Input.email
                                ([ centerX, width inputWidth ] ++ Style.field)
                                { onChange = Just UpdateEmail
                                , text = model.form.email
                                , label =
                                    Input.labelLeft [] <|
                                        icon Email Style.bigIcon
                                , placeholder = Just <| Input.placeholder [] <| el [ centerY ] <| text "email address"
                                }
                            , Input.currentPassword
                                ([ centerX, width inputWidth ] ++ Style.field)
                                { onChange = Just UpdatePassword
                                , text = model.form.password
                                , label =
                                    Input.labelLeft [] <|
                                        icon Lock Style.bigIcon
                                , placeholder = Just <| Input.placeholder [] <| el [ centerY ] <| text "password"
                                , show = False
                                }
                            , el [ centerX ] <| actionIcon Arrow (Just <| SignUpSubmit)
                            , button [ centerX, Font.underline ]
                                { onPress = Just <| NavigateTo Login
                                , label = text "Need to log in?"
                                }
                            ]

        confirm =
            model.confirm
                |> whenJust
                    (\msg ->
                        el
                            [ centerX
                            , centerY
                            , padding 10
                            , spacing 20
                            , Background.color Style.c
                            , Border.rounded 5
                            , Border.color Style.e
                            , Border.width 2
                            , Border.solid
                            ]
                        <|
                            column
                                []
                                [ icon Question (centerX :: Style.bigIcon)
                                , row
                                    [ spacing 40 ]
                                    [ actionIcon Tick (Just msg)
                                    , actionIcon Cross (Just <| Confirm Nothing)
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
    layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
                |> (if model.device == Mobile then
                        (::) noHover
                    else
                        identity
                   )
        }
        [ Background.color Style.c
        , Style.font
        , modal
        ]
        content


viewApp : Model -> AppView -> Element Msg
viewApp model appView =
    let
        col =
            column
                [ shrink |> maximum model.size.height |> height
                , scrollbarY
                , spacing 50
                , padding 20
                ]
    in
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
            col
                [ createHeader Flag
                , viewErrors model.form.errors
                , nameEdit model.form
                , notesEditor model.form
                , createButtons SaveCreatePosition
                ]

        ViewCreateSubmission ->
            col
                [ createHeader Bolt
                , viewErrors model.form.errors
                , nameEdit model.form
                , viewSubmissionPicker model.form
                , stepsEditor model.form
                , notesEditor model.form
                , createButtons SaveCreateSubmission
                ]

        ViewCreateTag ->
            col
                [ createHeader Tags
                , viewErrors model.form.errors
                , nameEdit model.form
                , createButtons SaveCreateTag
                ]

        ViewCreateTopic ->
            col
                [ createHeader Book
                , viewErrors model.form.errors
                , nameEdit model.form
                , notesEditor model.form
                , createButtons SaveCreateTopic
                ]

        ViewCreateTransition ->
            col
                [ createHeader Arrow
                , viewErrors model.form.errors
                , nameEdit model.form
                , viewTransitionPickers model.form
                , stepsEditor model.form
                , notesEditor model.form
                , createButtons SaveCreateTransition
                ]

        ViewEditPosition _ ->
            col
                [ editHeader Flag
                , viewErrors model.form.errors
                , nameEdit model.form
                , notesEditor model.form
                , editButtons SaveEditPosition <| DeletePosition model.form.id
                ]

        ViewEditSubmission _ ->
            col
                [ editHeader Bolt
                , viewErrors model.form.errors
                , nameEdit model.form
                , viewSubmissionPicker model.form
                , stepsEditor model.form
                , notesEditor model.form
                , editTags model.tags <| Array.toList model.form.tags
                , editButtons SaveEditSubmission <| DeleteSubmission model.form.id
                ]

        ViewEditTag _ ->
            col
                [ editHeader Tags
                , viewErrors model.form.errors
                , nameEdit model.form
                , editButtons SaveEditTag <| DeleteTag model.form.id
                ]

        ViewEditTopic _ ->
            col
                [ editHeader Book
                , viewErrors model.form.errors
                , nameEdit model.form
                , notesEditor model.form
                , editButtons SaveEditTopic <| DeleteTopic model.form.id
                ]

        ViewEditTransition _ ->
            col
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
                        col
                            [ editRow name Flag <| NavigateTo <| EditPositionRoute position.id
                            , viewNotes notes
                            , column
                                [ centerX
                                , Border.rounded 5
                                , Border.width 2
                                , Border.color Style.e
                                , Border.solid
                                , width shrink
                                , padding 30
                                , spacing 10
                                , height shrink
                                ]
                                [ addNewRow Bolt
                                    (SetRouteThenNavigate
                                        (PositionRoute id)
                                        CreateSubmissionRoute
                                    )
                                , viewTechList SubmissionRoute submissions
                                ]
                            , column
                                [ centerX
                                , Border.rounded 5
                                , Border.width 2
                                , Border.color Style.e
                                , Border.solid
                                , width shrink
                                , padding 30
                                , spacing 10
                                , height shrink
                                ]
                                [ addNewRow Arrow
                                    (SetRouteThenNavigate
                                        (PositionRoute id)
                                        CreateTransitionRoute
                                    )
                                , if
                                    List.isEmpty transitionsFrom
                                        && List.isEmpty transitionsTo
                                  then
                                    none
                                  else
                                    column [ spacing 10 ]
                                        [ column [ spacing 10 ]
                                            (transitionsFrom
                                                |> List.map
                                                    (viewTransitionPositions True False True)
                                            )
                                        , column [ spacing 10 ]
                                            (transitionsTo
                                                |> List.map
                                                    (viewTransitionPositions True True False)
                                            )
                                        ]
                                ]
                            ]
                    )

        ViewPositions ->
            model.positions
                |> viewRemote
                    (\positions ->
                        col
                            [ addNewRow Flag <| NavigateTo CreatePositionRoute
                            , blocks PositionRoute positions
                            ]
                    )

        ViewSettings ->
            let
                style =
                    onKeydown [ onEnter ChangePasswordSubmit ] :: Style.field
            in
            column [ padding 20 ]
                [ el [ centerX ] <| icon Cogs Style.mattIcon
                , el [] <| text "Change Password:"
                , viewErrors model.form.errors
                , Input.newPassword style
                    { onChange = Just UpdatePassword
                    , text = model.form.password
                    , label = Input.labelLeft [] none
                    , placeholder = Nothing
                    , show = False
                    }
                , Input.newPassword style
                    { onChange = Just UpdateConfirmPassword
                    , text = model.form.confirmPassword
                    , label = Input.labelLeft [] none
                    , placeholder = Nothing
                    , show = False
                    }
                , actionIcon SignIn (Just ChangePasswordSubmit)
                ]

        ViewSubmission data ->
            data
                |> viewRemote
                    (\sub ->
                        col
                            [ editRow sub.name Bolt <| NavigateTo <| EditSubmissionRoute sub.id
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
                        col
                            [ addNewRow Bolt <|
                                NavigateTo
                                    CreateSubmissionRoute
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
                        col
                            [ editRow t.name Tags <| NavigateTo <| EditTagRoute t.id
                            , column [ height shrink, width shrink, centerX, spacing 10 ]
                                [ el [ centerX ] <| icon Bolt Style.mattIcon
                                , viewTechList SubmissionRoute t.submissions
                                ]
                            , column [ height shrink, width shrink, centerX, spacing 10 ]
                                [ el [ centerX ] <| icon Arrow Style.mattIcon
                                , viewTechList TransitionRoute t.transitions
                                ]
                            ]
                    )

        ViewTags ->
            model.tags
                |> viewRemote
                    (\tags ->
                        col
                            [ addNewRow Tags <| NavigateTo CreateTagRoute
                            , blocks TagRoute tags
                            ]
                    )

        ViewTopic data ->
            data
                |> viewRemote
                    (\t ->
                        col
                            [ editRow t.name Book <| NavigateTo <| EditTopicRoute t.id
                            , viewNotes t.notes
                            ]
                    )

        ViewTopics data ->
            data
                |> viewRemote
                    (\topics ->
                        col
                            [ addNewRow Book <| NavigateTo CreateTopicRoute
                            , blocks TopicRoute topics
                            ]
                    )

        ViewTransition data ->
            data
                |> viewRemote
                    (\t ->
                        col
                            [ editRow t.name Arrow <| NavigateTo <| EditTransitionRoute t.id
                            , viewTransitionPositions False True True t
                            , viewSteps t.steps
                            , viewNotes t.notes
                            , viewTags t.tags
                            ]
                    )

        ViewTransitions data ->
            data
                |> viewRemote
                    (\transitions ->
                        col
                            [ addNewRow Arrow <|
                                NavigateTo
                                    CreateTransitionRoute
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


createHeader : FaIcon -> Element msg
createHeader fa =
    el [ centerX ] <|
        row [ spacing 20, padding 20 ]
            [ icon fa Style.mattIcon
            , icon Plus Style.mattIcon
            ]


editHeader : FaIcon -> Element msg
editHeader fa =
    el [ centerX ] <|
        row [ spacing 20, padding 20 ]
            [ icon fa Style.mattIcon
            , icon Write Style.mattIcon
            ]


ballIcon : List (Attribute msg)
ballIcon =
    [ Font.color Style.c
    , Font.size 35
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
            icons NavigateTo view


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
                (icons SidebarNavigate view
                    ++ [ Input.button (centerX :: Style.actionIcon)
                            { onPress =
                                Just <| ToggleSidebar
                            , label = icon Cross []
                            }
                       ]
                )
            ]
            |> inFront
    else
        button
            ([ alignRight
             , Element.alignBottom
             , Element.moveLeft 10
             , Element.moveUp 10
             ]
                ++ ballIcon
            )
            { onPress = Just ToggleSidebar
            , label = icon Bars []
            }
            |> inFront


icons : (Route -> Msg) -> AppView -> List (Element Msg)
icons nav view =
    let
        active isActive =
            if isActive then
                centerX :: ballIcon
            else
                centerX :: Style.actionIcon
    in
    [ button (active <| view == ViewStart)
        { onPress = Just <| nav Start
        , label = icon Home []
        }
    , button (active <| isPositionView view)
        { onPress = Just <| nav Positions
        , label = icon Flag []
        }
    , button (active <| isTransitionView view)
        { onPress = Just <| nav Transitions
        , label = icon Arrow []
        }
    , button (active <| isSubmissionView view)
        { onPress = Just <| nav Submissions
        , label = icon Bolt []
        }
    , button (active <| isTagView view)
        { onPress = Just <| nav TagsRoute
        , label = icon Tags []
        }
    , button (active <| isTopicView view)
        { onPress = Just <| nav Topics
        , label = icon Book []
        }
    , button (active <| view == ViewSettings)
        { onPress = Just <| nav SettingsRoute
        , label = icon Cogs []
        }
    , button (centerX :: Style.actionIcon)
        { onPress = Just <| Logout
        , label = icon SignOut []
        }
    ]


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
        >> column []


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
            el
                [ Font.color Style.e
                , Font.size 60
                , centerX
                , centerY
                ]
                spinner

        Failure err ->
            viewErrors (Just [ toString err ])

        Success a ->
            fn a


viewSubmissionPicker : Form -> Element Msg
viewSubmissionPicker form =
    column
        [ width shrink, centerX, spacing 20, height shrink ]
        [ el [ centerX ] <| icon Flag Style.mattIcon
        , pickPosition ToggleStartPosition form.startPosition
        ]


viewTransitionPickers : Form -> Element Msg
viewTransitionPickers form =
    column
        [ width shrink, centerX, spacing 20 ]
        [ el [ centerX ] <| pickPosition ToggleStartPosition form.startPosition
        , el [ centerX ] <| icon ArrowDown Style.mattIcon
        , el [ centerX ] <| pickPosition ToggleEndPosition form.endPosition
        ]


pickPosition : Msg -> Maybe Info -> Element Msg
pickPosition msg position =
    case position of
        Nothing ->
            actionIcon Question (Just msg)

        Just { name } ->
            Input.button []
                { onPress =
                    Just msg
                , label =
                    el Style.link <| text name
                }


editRow : String -> FaIcon -> Msg -> Element Msg
editRow name fa editMsg =
    row
        [ width shrink, height shrink, spacing 20, centerX ]
        [ el [ centerX ] <| icon fa Style.mattIcon
        , paragraph
            [ Font.size 35
            , Font.color Style.e
            , width fill
            ]
            [ text name ]
        , actionIcon Write (Just editMsg)
        ]


addNewRow : FaIcon -> Msg -> Element Msg
addNewRow fa msg =
    row [ spacing 20, width shrink, centerX ]
        [ icon fa Style.mattIcon
        , plus msg
        ]


nameEdit : Form -> Element Msg
nameEdit form =
    Input.text
        ([ centerX, fill |> maximum 500 |> width ] ++ Style.field)
        { onChange = Just <| \str -> UpdateForm { form | name = str }
        , text = form.name
        , label = noLabel
        , placeholder = Nothing
        }


plus : msg -> Element msg
plus msg =
    actionIcon Plus (Just msg)


minus : msg -> Element msg
minus msg =
    actionIcon Minus (Just msg)


editButtons : Msg -> Msg -> Element Msg
editButtons save delete =
    el [ centerX ] <|
        row
            [ spacing 20 ]
            [ actionIcon Tick (Just save)
            , actionIcon Cross (Just Cancel)
            , actionIcon Trash (Just <| Confirm <| Just delete)
            ]


createButtons : Msg -> Element Msg
createButtons save =
    el [ centerX ] <|
        row
            [ spacing 20 ]
            [ actionIcon Tick (Just save)
            , actionIcon Cross (Just Cancel)
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
                                       , htmlAttribute <| Html.Attributes.wrap "hard"
                                       , htmlAttribute <| Html.Attributes.style [ ( "white-space", "normal" ) ]
                                       , centerX
                                       , fill |> maximum 500 |> width
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
                    [ spacing 10 ]
                    [ plus (UpdateForm { form | steps = Array.push "" form.steps })
                    , when (not <| Array.isEmpty form.steps) <|
                        minus (UpdateForm { form | steps = Array.slice 0 -1 form.steps })
                    ]
    in
    column
        [ spacing 10
        , width fill
        , height shrink
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
                                       , htmlAttribute <| Html.Attributes.wrap "hard"
                                       , htmlAttribute <| Html.Attributes.style [ ( "white-space", "normal" ) ]
                                       , centerX
                                       , fill |> maximum 500 |> width
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
                    [ spacing 10 ]
                    [ plus (UpdateForm { form | notes = Array.push "" form.notes })
                    , when (not <| Array.isEmpty form.notes) <|
                        minus (UpdateForm { form | notes = Array.slice 0 -1 form.notes })
                    ]
    in
    column
        [ spacing 10
        , width fill
        , height shrink
        ]
        [ icon Notes (centerX :: Style.bigIcon)
        , notes
        , buttons
        ]


viewSteps : Array String -> Element Msg
viewSteps steps =
    column
        [ Font.size 25, width shrink, centerX ]
        (steps
            |> Array.toList
            |> List.indexedMap
                (\i step ->
                    row [ fill |> maximum 500 |> width ]
                        [ el [ Font.color Style.e, Element.alignTop ] <|
                            text <|
                                (toString (i + 1) ++ ".")
                        , paragraph
                            [ width fill ]
                            [ text step
                            ]
                        ]
                )
        )


viewNotes : Array String -> Element msg
viewNotes notes =
    column
        [ Font.size 25, width shrink, centerX ]
        (notes
            |> Array.toList
            |> List.map
                (\note ->
                    row [ fill |> maximum 500 |> width ]
                        [ el [ Font.color Style.e, Element.alignTop ] <| text "• "
                        , if Regex.contains matchLink note then
                            newTabLink [ Font.underline ]
                                { url = note
                                , label = text <| domain note
                                }
                          else
                            paragraph
                                [ width fill
                                ]
                                [ text note
                                ]
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
        none
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
                                    [ width fill
                                    ]
                                    [ el [ Font.color Style.e ] <| text "• "
                                    , el Style.link <| text t.name
                                    ]
                            }
                    )
            )


editTags : RemoteData.WebData (List Info) -> List Info -> Element Msg
editTags tags xs =
    column [ spacing 30, width shrink, centerX ]
        [ el [ centerX ] <| icon Tags Style.mattIcon
        , xs
            |> List.indexedMap
                (\i tag ->
                    block (tag.name ++ " -") <| RemoveTag i
                )
            |> paragraph [ width fill ]
        , tags
            |> viewRemote
                (List.filter
                    (flip List.member xs >> not)
                    >> List.map
                        (\tag ->
                            block (tag.name ++ " +") <| AddTag tag
                        )
                    >> paragraph [ width fill ]
                )
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
                                            [ width fill ]
                                            [ el [ Font.color Style.e, padding 5 ] <| text "• "
                                            , el Style.link <| text t.name
                                            ]
                                    }
                            )
                    )
            ]


viewErrors : Maybe (List String) -> Element Msg
viewErrors =
    whenJust
        (\errs ->
            column
                [ spacing 15
                , padding 10
                , height shrink
                , Border.rounded 5
                , Border.color Style.e
                , Border.width 2
                , Border.solid
                ]
                [ el [ centerX ] <| icon Warning Style.mattIcon
                , viewNotes <| Array.fromList errs
                ]
                |> el [ centerX ]
                |> when (errs |> List.isEmpty |> not)
        )


viewTransitionPositions : Bool -> Bool -> Bool -> Transition -> Element Msg
viewTransitionPositions showHeader linkFrom linkTo transition =
    column
        [ centerX
        , Border.rounded 5
        , Border.width 2
        , Border.color Style.e
        , Border.solid
        , width shrink
        , padding 30
        , spacing 20
        , height shrink
        ]
        [ when showHeader
            (column [ spacing 20 ]
                [ button [ centerX, width fill ]
                    { onPress = Just <| NavigateTo <| TransitionRoute transition.id
                    , label =
                        el (centerX :: Style.link) <|
                            text transition.name
                    }
                , el [ Background.color Style.e, centerX, width <| px 20, height <| px 2 ] none
                ]
            )
        , if linkFrom then
            button [ centerX ]
                { onPress = Just <| NavigateTo <| PositionRoute transition.startPosition.id
                , label =
                    el Style.link <|
                        text transition.startPosition.name
                }
          else
            el [ Font.color Style.e, centerX ] <| text transition.startPosition.name
        , el [ centerX ] <| icon ArrowDown Style.mattIcon
        , if linkTo then
            button [ centerX ]
                { onPress = Just <| NavigateTo <| PositionRoute transition.endPosition.id
                , label =
                    el Style.link <|
                        text transition.endPosition.name
                }
          else
            el [ Font.color Style.e, centerX ] <| text transition.endPosition.name
        ]


domain : String -> String
domain s =
    Regex.find (Regex.AtMost 10) matchDomain s
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
        |> Maybe.withDefault s


actionIcon : FaIcon -> Maybe msg -> Element msg
actionIcon fa msg =
    Input.button
        [ Font.color Style.e
        , Border.solid
        , Border.width 2
        , Border.color Style.e
        , padding 5
        , Border.rounded 5
        , mouseOver
            [ Background.color Style.e
            , Font.color Style.c
            ]
        ]
        { onPress = msg
        , label = icon fa [ centerX, centerY ]
        }


spinner : Element msg
spinner =
    icon Waiting
        ((Html.Attributes.style
            [ ( "animation"
              , "rotation 2s infinite linear"
              )
            ]
            |> Element.htmlAttribute
         )
            :: Style.mattIcon
        )