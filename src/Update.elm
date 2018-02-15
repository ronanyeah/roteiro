module Update exposing (..)

import Data exposing (createPosition, createSubmission, createTopic, createTransition, fetchPositions, mutation, query, updatePosition, updateSubmission, updateTopic, updateTransition)
import Navigation
import Paths
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Task
import Types exposing (..)
import Utils exposing (addErrors, clearErrors, emptyForm, formatErrors, log, logError, taskToGcData)
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Cancel ->
            ( { model | view = model.previousView, confirm = Nothing }, Cmd.none )

        CbCreateOrUpdatePosition res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewPosition <| Success a
                        , confirm = Nothing
                      }
                    , Navigation.newUrl <| Paths.position a.id
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
                    , Navigation.newUrl <| Paths.submission a.id
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
                    , Navigation.newUrl <| Paths.topic a.id
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
                    , Navigation.newUrl <| Paths.transition a.id
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
                    , Navigation.newUrl <| Paths.submissions
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
                    , Navigation.newUrl <| Paths.topics
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
                    , Navigation.newUrl <| Paths.transitions
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
            , fetchPositions
                |> query model.token
                |> taskToGcData CbPositions
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
            , fetchPositions
                |> query model.token
                |> taskToGcData CbPositions
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
                    }
            in
            ( { model
                | view = ViewEditSubmission
                , previousView = model.view
                , form = form
              }
            , fetchPositions
                |> query model.token
                |> taskToGcData CbPositions
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
            , fetchPositions
                |> query model.token
                |> taskToGcData CbPositions
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
                    , updateSubmission model.form.id name position steps notes
                        |> mutation model.token
                        |> Task.attempt CbCreateOrUpdateSubmission
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

        ToggleEndPosition ->
            ( { model | selectingEndPosition = not model.selectingEndPosition }, Cmd.none )

        ToggleStartPosition ->
            ( { model | selectingStartPosition = not model.selectingStartPosition }, Cmd.none )

        SidebarNavigate url ->
            ( { model | sidebarOpen = False }, Navigation.newUrl url )

        ToggleSidebar ->
            ( { model | sidebarOpen = not model.sidebarOpen }, Cmd.none )

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
            router model location

        WindowSize size ->
            ( { model
                | device = size |> Utils.classifyDevice
                , size = size
              }
            , Cmd.none
            )
