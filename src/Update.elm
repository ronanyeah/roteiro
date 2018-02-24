module Update exposing (..)

import Array
import Data exposing (createPosition, createSubmission, createTag, createTopic, createTransition, fetchPosition, fetchPositions, fetchSubmission, fetchSubmissions, fetchTag, fetchTags, fetchTopic, fetchTopics, fetchTransition, fetchTransitions, mutation, query, updatePosition, updateSubmission, updateTag, updateTopic, updateTransition)
import Navigation
import Paths
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Task
import Types exposing (..)
import Utils exposing (addErrors, arrayRemove, clearErrors, emptyForm, formatErrors, goTo, log, logError, removeNull, taskToGcData)
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
            ( { model | view = model.previousView, confirm = Nothing }, Cmd.none )

        CbCreateOrUpdatePosition res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewPosition <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| Paths.position a.id
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
                        | view = ViewSubmission <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| Paths.submission a.id
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
                        | view = ViewTag <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| Paths.tag a.id
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
                        | view = ViewTopic <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| Paths.topic a.id
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
                        | view = ViewTransition <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| Paths.transition a.id
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
                    , goTo <| Paths.submissions
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
                    , goTo <| Paths.tags
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
                    , goTo <| Paths.topics
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
                    , goTo <| Paths.transitions
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
                | view = ViewPosition res
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
                | view = ViewSubmission res
              }
            , logError res
            )

        CbSubmissions res ->
            ( { model
                | view = ViewSubmissions res
              }
            , logError res
            )

        CbTag res ->
            ( { model
                | view = ViewTag res
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
                | view = ViewTopic res
              }
            , logError res
            )

        CbTopics res ->
            ( { model
                | view = ViewTopics res
              }
            , logError res
            )

        CbTransition res ->
            ( { model
                | view = ViewTransition res
              }
            , logError res
            )

        CbTransitions res ->
            ( { model
                | view = ViewTransitions res
              }
            , logError res
            )

        Confirm maybeM ->
            ( { model | confirm = maybeM }, Cmd.none )

        CreatePosition ->
            ( { model
                | view = ViewCreatePosition
                , form = emptyForm
                , previousView = model.view
              }
            , Cmd.none
            )

        CreateSubmission p ->
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
                | view = ViewCreateSubmission
                , previousView = model.view
                , form = form
              }
            , Cmd.batch
                [ maybeFetchPositions model.token model.positions
                , maybeFetchTags model.token model.tags
                ]
            )

        CreateTag ->
            ( { model
                | view = ViewCreateTag
                , previousView = model.view
                , form = emptyForm
              }
            , Cmd.none
            )

        CreateTopic ->
            ( { model
                | view = ViewCreateTopic
                , previousView = model.view
                , form = emptyForm
              }
            , Cmd.none
            )

        CreateTransition p ->
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
                | view = ViewCreateTransition
                , previousView = model.view
                , form = form
              }
            , Cmd.batch
                [ maybeFetchPositions model.token model.positions
                , maybeFetchTags model.token model.tags
                ]
            )

        DeletePosition id ->
            ( model
            , Data.deletePosition id
                |> mutation model.token
                |> Task.attempt CbDeletePosition
            )

        DeleteSubmission id ->
            ( model
            , Data.deleteSubmission id
                |> mutation model.token
                |> Task.attempt CbDeleteSubmission
            )

        DeleteTag id ->
            ( model
            , Data.deleteTag id
                |> mutation model.token
                |> Task.attempt CbDeleteTag
            )

        DeleteTopic id ->
            ( model
            , Data.deleteTopic id
                |> mutation model.token
                |> Task.attempt CbDeleteTopic
            )

        DeleteTransition id ->
            ( model
            , Data.deleteTransition id
                |> mutation model.token
                |> Task.attempt CbDeleteTransition
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
                | view = ViewEditPosition
                , previousView = model.view
                , form = form
              }
            , Cmd.none
            )

        EditSubmission s ->
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
                | view = ViewEditSubmission
                , previousView = model.view
                , form = form
              }
            , Cmd.batch
                [ maybeFetchPositions model.token model.positions
                , maybeFetchTags model.token model.tags
                ]
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
                | view = ViewEditTag
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
                | view = ViewEditTopic
                , previousView = model.view
                , form = form
              }
            , Cmd.none
            )

        EditTransition t ->
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
                | view = ViewEditTransition
                , previousView = model.view
                , form = form
              }
            , Cmd.batch
                [ maybeFetchPositions model.token model.positions
                , maybeFetchTags model.token model.tags
                ]
            )

        NavigateTo path ->
            ( model, goTo path )

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
            case Validate.position model.form of
                Ok args ->
                    ( { model | form = clearErrors model.form }
                    , args
                        |> uncurry createPosition
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdatePosition
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveCreateSubmission ->
            case Validate.submission model.form of
                Ok ( name, startId, steps, notes ) ->
                    ( { model | form = clearErrors model.form }
                    , createSubmission name startId steps notes
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateSubmission
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveCreateTag ->
            case Validate.tag model.form of
                Ok name ->
                    ( { model | form = clearErrors model.form }
                    , name
                        |> createTag
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateTag
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveCreateTopic ->
            case Validate.topic model.form of
                Ok args ->
                    ( { model | form = clearErrors model.form }
                    , args
                        |> uncurry createTopic
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateTopic
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveCreateTransition ->
            case Validate.transition model.form of
                Ok ( name, startId, endId, steps, notes ) ->
                    ( { model | form = clearErrors model.form }
                    , createTransition
                        name
                        startId
                        endId
                        steps
                        notes
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateTransition
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveEditPosition ->
            case Validate.position model.form of
                Ok args ->
                    ( { model | form = clearErrors model.form }
                    , args
                        |> uncurry (updatePosition model.form.id)
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdatePosition
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveEditSubmission ->
            case Validate.submission model.form of
                Ok ( name, position, steps, notes ) ->
                    ( { model | form = clearErrors model.form }
                    , updateSubmission model.form.id name position steps notes (model.form.tags |> Array.toList)
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateSubmission
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveEditTag ->
            case Validate.tag model.form of
                Ok name ->
                    ( { model | form = clearErrors model.form }
                    , name
                        |> updateTag model.form.id
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateTag
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveEditTopic ->
            case Validate.topic model.form of
                Ok args ->
                    ( { model | form = clearErrors model.form }
                    , args
                        |> uncurry (updateTopic model.form.id)
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateTopic
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SaveEditTransition ->
            case Validate.transition model.form of
                Ok ( name, startId, endId, steps, notes ) ->
                    ( { model | form = clearErrors model.form }
                    , updateTransition model.form.id name startId endId steps notes
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateTransition
                    )

                Err errs ->
                    ( { model | form = addErrors errs model.form }
                    , Cmd.none
                    )

        SidebarNavigate url ->
            ( { model | sidebarOpen = False }, goTo url )

        ToggleEndPosition ->
            ( { model | selectingEndPosition = not model.selectingEndPosition }, Cmd.none )

        ToggleSidebar ->
            ( { model | sidebarOpen = not model.sidebarOpen }, Cmd.none )

        ToggleStartPosition ->
            ( { model | selectingStartPosition = not model.selectingStartPosition }, Cmd.none )

        TokenEdit maybeStr ->
            case maybeStr of
                Nothing ->
                    ( { model | tokenForm = Nothing }, Cmd.none )

                Just "" ->
                    ( { model | tokenForm = Just "" }, Cmd.none )

                Just token ->
                    ( { model | tokenForm = Nothing, token = token }
                    , Ports.saveToken token
                    )

        UpdateForm f ->
            ( { model | form = f }, Cmd.none )

        UpdateEndPosition selection ->
            let
                form =
                    model.form |> (\f -> { f | endPosition = Just selection })
            in
            ( { model | form = form, selectingEndPosition = False }, Cmd.none )

        UpdateStartPosition selection ->
            let
                form =
                    model.form |> (\f -> { f | startPosition = Just selection })
            in
            ( { model | form = form, selectingStartPosition = False }, Cmd.none )

        UrlChange location ->
            let
                doNothing =
                    ( model, Cmd.none )
            in
            case router location of
                NotFound ->
                    ( model, Cmd.batch [ log "redirecting...", goTo Paths.start ] )

                PositionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        ( { model | view = ViewPosition Loading }
                        , fetchPosition id
                            |> query model.token
                            |> taskToGcData (removeNull >> CbPosition)
                        )

                Positions ->
                    ( { model | view = ViewPositions, positions = Loading }
                    , fetchPositions
                        |> query model.token
                        |> taskToGcData CbPositions
                    )

                SubmissionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        ( { model | view = ViewSubmission Loading }
                        , fetchSubmission id
                            |> query model.token
                            |> taskToGcData (removeNull >> CbSubmission)
                        )

                Submissions ->
                    ( { model | view = ViewSubmissions Loading }
                    , fetchSubmissions
                        |> query model.token
                        |> taskToGcData CbSubmissions
                    )

                Start ->
                    ( { model | view = ViewStart }, Cmd.none )

                TagRoute id ->
                    ( { model | view = ViewTag Loading }
                    , fetchTag id
                        |> query model.token
                        |> taskToGcData (removeNull >> CbTag)
                    )

                TagsRoute ->
                    ( { model | view = ViewTags, tags = Loading }
                    , fetchTags
                        |> query model.token
                        |> taskToGcData CbTags
                    )

                TopicRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        ( { model | view = ViewTopic Loading }
                        , fetchTopic id
                            |> query model.token
                            |> taskToGcData (removeNull >> CbTopic)
                        )

                Topics ->
                    ( { model | view = ViewTopics Loading }
                    , fetchTopics
                        |> query model.token
                        |> taskToGcData CbTopics
                    )

                TransitionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        ( { model | view = ViewTransition Loading }
                        , fetchTransition id
                            |> query model.token
                            |> taskToGcData (removeNull >> CbTransition)
                        )

                Transitions ->
                    ( { model | view = ViewTransitions Loading }
                    , fetchTransitions
                        |> query model.token
                        |> taskToGcData CbTransitions
                    )

        WindowSize size ->
            ( { model
                | device = size |> Utils.classifyDevice
                , size = size
              }
            , Cmd.none
            )


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
        ViewPosition (Success d) ->
            id == d.id

        ViewSubmission (Success d) ->
            id == d.id

        ViewTopic (Success d) ->
            id == d.id

        ViewTransition (Success d) ->
            id == d.id

        _ ->
            False
