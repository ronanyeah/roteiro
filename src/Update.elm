module Update exposing (..)

import Array
import Data exposing (createPosition, createSubmission, createTag, createTopic, createTransition, fetchPosition, fetchPositions, fetchSubmission, fetchSubmissions, fetchTag, fetchTags, fetchTopic, fetchTopics, fetchTransition, fetchTransitions, mutation, query, updatePosition, updateSubmission, updateTag, updateTopic, updateTransition)
import Json.Encode as Encode
import Navigation
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Task
import Types exposing (..)
import Utils exposing (addErrors, arrayRemove, clearErrors, emptyForm, formatErrors, goTo, log, logError, removeNull, taskToGcData, unwrap)
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        doNothing =
            ( model, Cmd.none )

        protect =
            flip
                (unwrap
                    ( model
                    , Cmd.batch
                        [ goTo Login
                        , log <| "Message interrupted: " ++ toString msg
                        ]
                    )
                )
                model.auth
    in
    case msg of
        AddTag tag ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | tags = f.tags |> Array.push tag }
                           )
              }
            , Cmd.none
            )

        Cancel ->
            ( { model
                | view = model.previousView
                , confirm = Nothing
              }
            , Cmd.none
            )

        CbAuth res ->
            case res of
                Ok auth ->
                    ( { model | auth = Just auth }
                    , Cmd.batch
                        [ saveAuth auth
                        , goTo Start
                        ]
                    )

                Err err ->
                    ( { model
                        | form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbCreateOrUpdatePosition res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewPosition <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| PositionRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateSubmission res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewSubmission <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| SubmissionRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateTag res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewTag <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| TagRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateTopic res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewTopic <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| TopicRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateTransition res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewTransition <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| TransitionRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbDeletePosition res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                      -- Forces reload of previous page so deleted data won't be visible.
                    , Navigation.back 1
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteSubmission res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo Submissions
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteTag res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo TagsRoute
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteTopic res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo Topics
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteTransition res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo Transitions
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbPosition res ->
            ( { model
                | view = ViewApp <| ViewPosition res
              }
            , logError res
            )

        CbPositions res ->
            ( { model
                | positions = res
              }
            , logError res
            )

        CbSubmission res ->
            ( { model
                | view = ViewApp <| ViewSubmission res
              }
            , logError res
            )

        CbSubmissions res ->
            ( { model
                | view = ViewApp <| ViewSubmissions res
              }
            , logError res
            )

        CbTag res ->
            ( { model
                | view = ViewApp <| ViewTag res
              }
            , logError res
            )

        CbTags res ->
            ( { model
                | tags = res
              }
            , logError res
            )

        CbTopic res ->
            ( { model
                | view = ViewApp <| ViewTopic res
              }
            , logError res
            )

        CbTopics res ->
            ( { model
                | view = ViewApp <| ViewTopics res
              }
            , logError res
            )

        CbTransition res ->
            ( { model
                | view = ViewApp <| ViewTransition res
              }
            , logError res
            )

        CbTransitions res ->
            ( { model
                | view = ViewApp <| ViewTransitions res
              }
            , logError res
            )

        Confirm maybeM ->
            ( { model | confirm = maybeM }, Cmd.none )

        CreatePosition ->
            ( { model
                | view = ViewApp ViewCreatePosition
                , form = emptyForm
                , previousView = model.view
              }
            , Cmd.none
            )

        CreateSubmission p ->
            protect
                (\auth ->
                    let
                        form =
                            { emptyForm
                                | startPosition =
                                    p
                                        |> Maybe.map
                                            (\{ id, name } ->
                                                Info id name
                                            )
                            }
                    in
                    ( { model
                        | view = ViewApp ViewCreateSubmission
                        , previousView = model.view
                        , form = form
                      }
                    , Cmd.batch
                        [ maybeFetchPositions auth.token model.positions
                        , maybeFetchTags auth.token model.tags
                        ]
                    )
                )

        CreateTag ->
            ( { model
                | view = ViewApp ViewCreateTag
                , previousView = model.view
                , form = emptyForm
              }
            , Cmd.none
            )

        CreateTopic ->
            ( { model
                | view = ViewApp ViewCreateTopic
                , previousView = model.view
                , form = emptyForm
              }
            , Cmd.none
            )

        CreateTransition p ->
            protect
                (\auth ->
                    let
                        form =
                            { emptyForm
                                | startPosition =
                                    p
                                        |> Maybe.map
                                            (\{ id, name } ->
                                                Info id name
                                            )
                            }
                    in
                    ( { model
                        | view = ViewApp ViewCreateTransition
                        , previousView = model.view
                        , form = form
                      }
                    , Cmd.batch
                        [ maybeFetchPositions auth.token model.positions
                        , maybeFetchTags auth.token model.tags
                        ]
                    )
                )

        DeletePosition id ->
            protect
                (\auth ->
                    ( model
                    , Data.deletePosition id
                        |> mutation auth.token
                        |> Task.attempt CbDeletePosition
                    )
                )

        DeleteSubmission id ->
            protect
                (\auth ->
                    ( model
                    , Data.deleteSubmission id
                        |> mutation auth.token
                        |> Task.attempt CbDeleteSubmission
                    )
                )

        DeleteTag id ->
            protect
                (\auth ->
                    ( model
                    , Data.deleteTag id
                        |> mutation auth.token
                        |> Task.attempt CbDeleteTag
                    )
                )

        DeleteTopic id ->
            protect
                (\auth ->
                    ( model
                    , Data.deleteTopic id
                        |> mutation auth.token
                        |> Task.attempt CbDeleteTopic
                    )
                )

        DeleteTransition id ->
            protect
                (\auth ->
                    ( model
                    , Data.deleteTransition id
                        |> mutation auth.token
                        |> Task.attempt CbDeleteTransition
                    )
                )

        EditPosition p ->
            let
                form =
                    { emptyForm
                        | name = p.name
                        , notes = p.notes
                        , id = p.id
                    }
            in
            ( { model
                | view = ViewApp ViewEditPosition
                , previousView = model.view
                , form = form
              }
            , Cmd.none
            )

        EditSubmission s ->
            protect
                (\auth ->
                    let
                        form =
                            { emptyForm
                                | name = s.name
                                , steps = s.steps
                                , notes = s.notes
                                , startPosition = Just s.position
                                , id = s.id
                                , tags = s.tags |> Array.fromList
                            }
                    in
                    ( { model
                        | view = ViewApp ViewEditSubmission
                        , previousView = model.view
                        , form = form
                      }
                    , Cmd.batch
                        [ maybeFetchPositions auth.token model.positions
                        , maybeFetchTags auth.token model.tags
                        ]
                    )
                )

        EditTag t ->
            let
                form =
                    { emptyForm
                        | name = t.name
                        , id = t.id
                    }
            in
            ( { model
                | view = ViewApp ViewEditTag
                , previousView = model.view
                , form = form
              }
            , Cmd.none
            )

        EditTopic t ->
            let
                form =
                    { emptyForm
                        | name = t.name
                        , notes = t.notes
                        , id = t.id
                    }
            in
            ( { model
                | view = ViewApp ViewEditTopic
                , previousView = model.view
                , form = form
              }
            , Cmd.none
            )

        EditTransition t ->
            protect
                (\auth ->
                    let
                        form =
                            { emptyForm
                                | name = t.name
                                , id = t.id
                                , steps = t.steps
                                , notes = t.notes
                                , startPosition = Just t.startPosition
                                , endPosition = Just t.endPosition
                            }
                    in
                    ( { model
                        | view = ViewApp ViewEditTransition
                        , previousView = model.view
                        , form = form
                      }
                    , Cmd.batch
                        [ maybeFetchPositions auth.token model.positions
                        , maybeFetchTags auth.token model.tags
                        ]
                    )
                )

        LoginSubmit ->
            ( model
            , Data.login model.form.email model.form.password
                |> Task.attempt CbAuth
            )

        Logout ->
            ( { model | auth = Nothing }
            , Cmd.batch
                [ Ports.clearAuth ()
                , goTo Login
                ]
            )

        NavigateTo route ->
            ( model, goTo route )

        RemoveTag i ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | tags = arrayRemove i f.tags }
                           )
              }
            , Cmd.none
            )

        SaveCreatePosition ->
            protect
                (\auth ->
                    case Validate.position model.form of
                        Ok ( name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , createPosition auth.id name notes
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdatePosition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateSubmission ->
            protect
                (\auth ->
                    case Validate.submission model.form of
                        Ok ( name, startId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , createSubmission auth.id name startId steps notes
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateSubmission
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateTag ->
            protect
                (\auth ->
                    case Validate.tag model.form of
                        Ok name ->
                            ( { model | form = clearErrors model.form }
                            , createTag auth.id name
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateTag
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateTopic ->
            protect
                (\auth ->
                    case Validate.topic model.form of
                        Ok ( name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , createTopic auth.id name notes
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateTopic
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateTransition ->
            protect
                (\auth ->
                    case Validate.transition model.form of
                        Ok ( name, startId, endId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , createTransition
                                auth.id
                                name
                                startId
                                endId
                                steps
                                notes
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateTransition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditPosition ->
            protect
                (\auth ->
                    case Validate.position model.form of
                        Ok args ->
                            ( { model | form = clearErrors model.form }
                            , args
                                |> uncurry (updatePosition model.form.id)
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdatePosition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditSubmission ->
            protect
                (\auth ->
                    case Validate.submission model.form of
                        Ok ( name, position, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , updateSubmission model.form.id name position steps notes model.form.tags
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateSubmission
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditTag ->
            protect
                (\auth ->
                    case Validate.tag model.form of
                        Ok name ->
                            ( { model | form = clearErrors model.form }
                            , name
                                |> updateTag model.form.id
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateTag
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditTopic ->
            protect
                (\auth ->
                    case Validate.topic model.form of
                        Ok args ->
                            ( { model | form = clearErrors model.form }
                            , args
                                |> uncurry (updateTopic model.form.id)
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateTopic
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditTransition ->
            protect
                (\auth ->
                    case Validate.transition model.form of
                        Ok ( name, startId, endId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , updateTransition model.form.id name startId endId steps notes model.form.tags
                                |> mutation auth.token
                                |> Task.attempt CbCreateOrUpdateTransition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SidebarSignOut ->
            update Logout { model | sidebarOpen = False }

        SidebarNavigate route ->
            update (NavigateTo route) { model | sidebarOpen = False }

        SignUpSubmit ->
            ( model
            , Data.signUp model.form.email model.form.password
                |> Task.attempt CbAuth
            )

        ToggleEndPosition ->
            ( { model | selectingEndPosition = not model.selectingEndPosition }, Cmd.none )

        ToggleSidebar ->
            ( { model | sidebarOpen = not model.sidebarOpen }, Cmd.none )

        ToggleStartPosition ->
            ( { model | selectingStartPosition = not model.selectingStartPosition }, Cmd.none )

        UpdateForm f ->
            ( { model | form = f }, Cmd.none )

        UpdateEmail str ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | email = str }
                           )
              }
            , Cmd.none
            )

        UpdateEndPosition selection ->
            let
                form =
                    model.form |> (\f -> { f | endPosition = Just selection })
            in
            ( { model | form = form, selectingEndPosition = False }, Cmd.none )

        UpdatePassword str ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | password = str }
                           )
              }
            , Cmd.none
            )

        UpdateStartPosition selection ->
            let
                form =
                    model.form |> (\f -> { f | startPosition = Just selection })
            in
            ( { model | form = form, selectingStartPosition = False }, Cmd.none )

        UrlChange location ->
            case router location of
                Login ->
                    case model.auth of
                        Just _ ->
                            ( model, goTo Start )

                        Nothing ->
                            ( { model | view = ViewLogin, form = emptyForm }, Cmd.none )

                SignUp ->
                    case model.auth of
                        Just _ ->
                            ( model, goTo Start )

                        Nothing ->
                            ( { model | view = ViewSignUp, form = emptyForm }, Cmd.none )

                NotFound ->
                    ( model
                    , Cmd.batch
                        [ log "redirecting..."
                        , goTo
                            (model.auth |> unwrap Login (always Start))
                        ]
                    )

                PositionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewPosition Loading }
                                , fetchPosition id
                                    |> query auth.token
                                    |> taskToGcData (removeNull >> CbPosition)
                                )
                            )

                Positions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp ViewPositions, positions = Loading }
                            , fetchPositions
                                |> query auth.token
                                |> taskToGcData CbPositions
                            )
                        )

                SubmissionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewSubmission Loading }
                                , fetchSubmission id
                                    |> query auth.token
                                    |> taskToGcData (removeNull >> CbSubmission)
                                )
                            )

                Submissions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewSubmissions Loading }
                            , fetchSubmissions
                                |> query auth.token
                                |> taskToGcData CbSubmissions
                            )
                        )

                Start ->
                    ( { model | view = ViewApp ViewStart }, Cmd.none )

                TagRoute id ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTag Loading }
                            , fetchTag id
                                |> query auth.token
                                |> taskToGcData (removeNull >> CbTag)
                            )
                        )

                TagsRoute ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp ViewTags, tags = Loading }
                            , fetchTags
                                |> query auth.token
                                |> taskToGcData CbTags
                            )
                        )

                TopicRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewTopic Loading }
                                , fetchTopic id
                                    |> query auth.token
                                    |> taskToGcData (removeNull >> CbTopic)
                                )
                            )

                Topics ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTopics Loading }
                            , fetchTopics
                                |> query auth.token
                                |> taskToGcData CbTopics
                            )
                        )

                TransitionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewTransition Loading }
                                , fetchTransition id
                                    |> query auth.token
                                    |> taskToGcData (removeNull >> CbTransition)
                                )
                            )

                Transitions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTransitions Loading }
                            , fetchTransitions
                                |> query auth.token
                                |> taskToGcData CbTransitions
                            )
                        )

        WindowSize size ->
            ( { model
                | device = size |> Utils.classifyDevice
                , size = size
              }
            , Cmd.none
            )


saveAuth : Auth -> Cmd msg
saveAuth auth =
    [ ( "id", Encode.string (auth.id |> (\(Id id) -> id)) )
    , ( "token", Encode.string auth.token )
    , ( "email", Encode.string auth.email )
    ]
        |> Encode.object
        |> Ports.saveAuth


maybeFetchTags : String -> GcData a -> Cmd Msg
maybeFetchTags token data =
    if
        case data of
            RemoteData.NotAsked ->
                True

            RemoteData.Failure _ ->
                True

            RemoteData.Loading ->
                False

            RemoteData.Success _ ->
                False
    then
        fetchTags
            |> query token
            |> taskToGcData CbTags
    else
        Cmd.none


maybeFetchPositions : String -> GcData a -> Cmd Msg
maybeFetchPositions token data =
    if
        case data of
            RemoteData.NotAsked ->
                True

            RemoteData.Failure _ ->
                True

            RemoteData.Loading ->
                False

            RemoteData.Success _ ->
                False
    then
        fetchPositions
            |> query token
            |> taskToGcData CbPositions
    else
        Cmd.none


dataIsLoaded : View -> Id -> Bool
dataIsLoaded view id =
    case view of
        ViewApp (ViewPosition (Success d)) ->
            id == d.id

        ViewApp (ViewSubmission (Success d)) ->
            id == d.id

        ViewApp (ViewTopic (Success d)) ->
            id == d.id

        ViewApp (ViewTransition (Success d)) ->
            id == d.id

        _ ->
            False
