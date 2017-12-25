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
import Utils exposing (emptyForm, listToDict, log, unwrap)
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
                    , Navigation.back 1
                    )

                Err err ->
                    ( { model | view = ViewStart }, log err )

        CbPosition res ->
            ( { model
                | view = ViewPosition res
              }
            , Cmd.none
            )

        CbPositions res ->
            ( { model
                | positions = RemoteData.map listToDict res
              }
            , Cmd.none
            )

        CbSubmission res ->
            ( { model
                | view = ViewSubmission res
              }
            , Cmd.none
            )

        CbSubmissions res ->
            ( { model
                | view = ViewSubmissions res
              }
            , Cmd.none
            )

        CbTopic res ->
            ( { model
                | view = ViewTopic res
              }
            , Cmd.none
            )

        CbTopics res ->
            ( { model
                | view = ViewTopics res
              }
            , Cmd.none
            )

        CbTransition res ->
            ( { model
                | view = ViewTransition res
              }
            , Cmd.none
            )

        CbTransitions res ->
            ( { model
                | view = ViewTransitions res
              }
            , Cmd.none
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
            , Cmd.none
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

        Edit ->
            case model.view of
                ViewPosition (Success p) ->
                    let
                        form_ =
                            { emptyForm
                                | name = p.name
                                , notes = p.notes
                            }
                    in
                    ( { model | view = ViewEditPosition p, form = form_ }
                    , Cmd.none
                    )

                ViewSubmission (Success s) ->
                    let
                        form =
                            { emptyForm
                                | name = s.name
                                , steps = s.steps
                                , notes = s.notes
                                , startPosition = Picked s.position
                            }
                    in
                    ( { model | view = ViewEditSubmission s, form = form }
                    , fetchPositions |> query model.url model.token CbPositions
                    )

                ViewTopic (Success t) ->
                    let
                        form =
                            { emptyForm
                                | name = t.name
                                , notes = t.notes
                            }
                    in
                    ( { model | view = ViewEditTopic t, form = form }, Cmd.none )

                ViewTransition (Success t) ->
                    let
                        form =
                            { emptyForm
                                | name = t.name
                                , steps = t.steps
                                , notes = t.notes
                                , startPosition = Picked t.startPosition
                                , endPosition = Picked t.endPosition
                            }
                    in
                    ( { model | view = ViewEditTransition t, form = form }
                    , fetchPositions |> query model.url model.token CbPositions
                    )

                _ ->
                    ( model, Cmd.none )

        Save ->
            case model.view of
                ViewCreatePosition ->
                    ( model
                    , createPosition model.form.name model.form.notes
                        |> mutation model.url model.token CbPosition
                    )

                ViewCreateSubmission ->
                    case model.form.startPosition of
                        Picked { id } ->
                            ( model
                            , createSubmission model.form.name model.form.steps model.form.notes id
                                |> mutation model.url model.token CbSubmission
                            )

                        _ ->
                            ( model, log "missing position" )

                ViewCreateTopic ->
                    ( model
                    , createTopic model.form.name model.form.notes
                        |> mutation model.url model.token CbTopic
                    )

                ViewCreateTransition ->
                    case ( model.form.startPosition, model.form.endPosition ) of
                        ( Picked start, Picked end ) ->
                            ( model
                            , createTransition
                                model.form.name
                                model.form.steps
                                model.form.notes
                                start.id
                                end.id
                                |> mutation model.url model.token CbTransition
                            )

                        _ ->
                            ( model, log "missing position" )

                ViewEditPosition { id } ->
                    case Validate.position id model.form of
                        Ok value ->
                            ( model
                            , updatePosition value
                                |> mutation model.url model.token CbPosition
                            )

                        Err _ ->
                            ( model, Cmd.none )

                ViewEditSubmission { id } ->
                    case Validate.submission id model.form of
                        Ok value ->
                            ( model
                            , updateSubmission value
                                |> mutation model.url model.token CbSubmission
                            )

                        Err _ ->
                            ( model, Cmd.none )

                ViewEditTopic { id } ->
                    case Validate.topic id model.form of
                        Ok value ->
                            ( model
                            , updateTopic value
                                |> mutation model.url model.token CbTopic
                            )

                        Err _ ->
                            ( model, Cmd.none )

                ViewEditTransition { id } ->
                    case Validate.transition id model.form of
                        Ok value ->
                            ( model
                            , updateTransition value
                                |> mutation model.url model.token CbTransition
                            )

                        Err _ ->
                            ( model, Cmd.none )

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

                        form_ =
                            model.form |> (\f -> { f | startPosition = picker })
                    in
                    ( { model | form = form_ }, Cmd.none )

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
            ( { model | device = device }, Cmd.none )
