module Update exposing (..)

import Data exposing (createPosition, createSubmission, createTopic, createTransition, fetchPositions, mutation, mutationTask, query, updatePosition, updateSubmission, updateTopic, updateTransition)
import Element
import Element.Input as Input
import Navigation
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Task
import Types exposing (..)
import Utils exposing (addErrors, clearErrors, emptyForm, log, logError, unwrap)
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Cancel ->
            ( { model | view = model.previousView, confirm = Nothing }, Cmd.none )

        CbDelete res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                      -- Forces reload of previous page so deleted data won't be visible.
                    , Navigation.back 1
                    )

                Err err ->
                    ( { model | confirm = Nothing }, log err )

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
                            unwrap Pending
                                (\{ id, name } ->
                                    Picked <| Info id name
                                )
                                p
                    }
            in
            ( { model
                | view = ViewCreateSubmission
                , previousView = model.view
                , form = form
              }
            , fetchPositions |> query model.url model.token CbPositions
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
                            unwrap Pending
                                (\{ id, name } ->
                                    Picked <| Info id name
                                )
                                p
                    }
            in
            ( { model
                | view = ViewCreateTransition
                , previousView = model.view
                , form = form
              }
            , fetchPositions |> query model.url model.token CbPositions
            )

        DeletePosition id ->
            let
                request =
                    Data.deletePosition id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbDelete request )

        DeleteSubmission id ->
            let
                request =
                    Data.deleteSubmission id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbDelete request )

        DeleteTopic id ->
            let
                request =
                    Data.deleteTopic id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbDelete request )

        DeleteTransition id ->
            let
                request =
                    Data.deleteTransition id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbDelete request )

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
                        , startPosition = Picked s.position
                        , id = s.id
                    }
            in
            ( { model
                | view = ViewEditSubmission
                , previousView = model.view
                , form = form
              }
            , fetchPositions |> query model.url model.token CbPositions
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
                        , startPosition = Picked t.startPosition
                        , endPosition = Picked t.endPosition
                    }
            in
            ( { model
                | view = ViewEditTransition
                , previousView = model.view
                , form = form
              }
            , fetchPositions |> query model.url model.token CbPositions
            )

        Save ->
            case model.view of
                ViewCreatePosition ->
                    case Validate.createPosition model.form of
                        Ok args ->
                            ( { model | form = clearErrors model.form }
                            , uncurry createPosition args
                                |> mutation model.url model.token CbPosition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewCreateSubmission ->
                    case Validate.createSubmission model.form of
                        Ok ( name, startId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , createSubmission name startId steps notes
                                |> mutation model.url model.token CbSubmission
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewCreateTopic ->
                    case Validate.createTopic model.form of
                        Ok args ->
                            ( { model | form = clearErrors model.form }
                            , uncurry createTopic args
                                |> mutation model.url model.token CbTopic
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewCreateTransition ->
                    case Validate.createTransition model.form of
                        Ok ( name, startId, endId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , createTransition
                                name
                                startId
                                endId
                                steps
                                notes
                                |> mutation model.url model.token CbTransition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewEditPosition ->
                    case Validate.updatePosition model.form of
                        Ok ( id, name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , updatePosition id name notes
                                |> mutation model.url model.token CbPosition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewEditSubmission ->
                    case Validate.updateSubmission model.form of
                        Ok ( id, name, position, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , updateSubmission id name position steps notes
                                |> mutation model.url model.token CbSubmission
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewEditTopic ->
                    case Validate.updateTopic model.form of
                        Ok ( id, name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , updateTopic id name notes
                                |> mutation model.url model.token CbTopic
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                ViewEditTransition ->
                    case Validate.updateTransition model.form of
                        Ok ( id, name, startId, endId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , updateTransition id name startId endId steps notes
                                |> mutation model.url model.token CbTransition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )

                _ ->
                    ( model, Cmd.none )

        SetRoute route ->
            router model route

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

        UpdateEndPosition selectMsg ->
            case model.form.endPosition of
                Picking state ->
                    let
                        newState =
                            Input.updateSelection selectMsg state

                        picker =
                            case Input.selected newState of
                                Just pos ->
                                    Picked pos

                                Nothing ->
                                    Picking newState

                        form =
                            model.form |> (\f -> { f | endPosition = picker })
                    in
                    ( { model | form = form }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdateStartPosition selectMsg ->
            case model.form.startPosition of
                Picking state ->
                    let
                        newState =
                            Input.updateSelection selectMsg state

                        picker =
                            case Input.selected newState of
                                Just pos ->
                                    Picked pos

                                Nothing ->
                                    Picking newState

                        form =
                            model.form |> (\f -> { f | startPosition = picker })
                    in
                    ( { model | form = form }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        WindowSize size ->
            let
                device =
                    if size |> Element.classifyDevice |> .phone then
                        Mobile
                    else
                        Desktop
            in
            ( { model | device = device, size = size }, Cmd.none )
