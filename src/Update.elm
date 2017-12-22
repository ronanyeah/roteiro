module Update exposing (..)

import Data exposing (createPosition, createSubmission, createTopic, createTransition, mutation, mutationTask, updatePosition, updateSubmission, updateTopic, updateTransition)
import Element
import Element.Input as Input
import Navigation
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Task
import Types exposing (..)
import Utils exposing (del, emptyForm, get, listToDict, log, set, unwrap)
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ form } as model) =
    case msg of
        Cancel ->
            case model.view of
                ViewCreatePosition ->
                    ( model, Navigation.newUrl "/#/ps" )

                ViewCreateSubmission ->
                    ( model, Navigation.newUrl "/#/ss" )

                ViewCreateTransition ->
                    ( model, Navigation.newUrl "/#/trs" )

                ViewCreateTopic ->
                    ( { model | view = ViewTopics }, Cmd.none )

                ViewPosition _ p ->
                    ( { model | view = ViewPosition False p, confirm = Nothing }, Cmd.none )

                ViewSubmission _ s ->
                    ( { model | view = ViewSubmission False s, confirm = Nothing }, Cmd.none )

                ViewTopic _ t ->
                    ( { model | view = ViewTopic False t, confirm = Nothing }, Cmd.none )

                ViewTransition _ t ->
                    ( { model | view = ViewTransition False t, confirm = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CbData res ->
            case res of
                Success { transitions, positions, submissions, topics } ->
                    ( { model
                        | transitions = listToDict transitions
                        , positions = listToDict positions
                        , submissions = listToDict submissions
                        , topics = listToDict topics
                      }
                    , Cmd.none
                    )

                Failure err ->
                    ( model, log err )

                _ ->
                    ( model, Cmd.none )

        CbPosition res ->
            ( { model
                | view = ViewPosition False res
              }
            , Cmd.none
            )

        CbPositions res ->
            ( { model
                | view = ViewPositions res
              }
            , Cmd.none
            )

        CbPositionDelete res ->
            case res of
                Ok id ->
                    ( { model
                        | view = ViewStart
                        , positions = del id model.positions
                        , confirm = Nothing
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbSubmission res ->
            case res of
                Success data ->
                    ( { model
                        | view = ViewSubmission False data
                        , submissions = set data model.submissions
                      }
                    , Navigation.modifyUrl <| Router.submission data.id
                    )

                Failure err ->
                    ( model, log err )

                _ ->
                    ( model, Cmd.none )

        CbSubmissions res ->
            ( { model
                | view = ViewSubmissions res
              }
            , Cmd.none
            )

        CbSubmissionDelete res ->
            case res of
                Ok id ->
                    ( { model
                        | submissions = del id model.submissions
                        , confirm = Nothing
                      }
                    , Navigation.back 1
                    )

                Err err ->
                    ( model, log err )

        CbTopic res ->
            case res of
                Success data ->
                    ( { model
                        | view = ViewTopic False data
                        , topics = set data model.topics
                      }
                    , Navigation.modifyUrl <| Router.topic data.id
                    )

                Failure err ->
                    ( model, log err )

                _ ->
                    ( model, Cmd.none )

        CbTopicDelete res ->
            case res of
                Ok id ->
                    ( { model
                        | view = ViewTopics
                        , topics = del id model.topics
                        , confirm = Nothing
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTransition res ->
            case res of
                Success data ->
                    ( { model
                        | view = ViewTransition False data
                        , transitions = set data model.transitions
                      }
                    , Navigation.modifyUrl <| Router.transition data.id
                    )

                Failure err ->
                    ( model, log err )

                _ ->
                    ( model, Cmd.none )

        CbTransitionDelete res ->
            case res of
                Ok id ->
                    ( { model
                        | transitions = del id model.transitions
                        , confirm = Nothing
                      }
                    , Navigation.back 1
                    )

                Err err ->
                    ( model, log err )

        Confirm maybeM ->
            ( { model | confirm = maybeM }, Cmd.none )

        CreatePosition ->
            ( { model
                | view =
                    ViewCreatePosition
                , form = emptyForm
              }
            , Cmd.none
            )

        CreateSubmission p ->
            ( { model
                | view =
                    ViewCreateSubmission
                , form = { emptyForm | startPosition = unwrap Pending Picked p }
              }
            , Cmd.none
            )

        CreateTopic ->
            ( { model
                | view =
                    ViewCreateTopic
                , form = emptyForm
              }
            , Cmd.none
            )

        CreateTransition p ->
            ( { model
                | view =
                    ViewCreateTransition
                , form = { emptyForm | startPosition = unwrap Pending Picked p }
              }
            , Cmd.none
            )

        DeletePosition id ->
            let
                request =
                    Data.deletePosition id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbPositionDelete request )

        DeleteSubmission id ->
            let
                request =
                    Data.deleteSubmission id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbSubmissionDelete request )

        DeleteTopic id ->
            let
                request =
                    Data.deleteTopic id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbTopicDelete request )

        DeleteTransition id ->
            let
                request =
                    Data.deleteTransition id
                        |> mutationTask model.url model.token
            in
            ( model, Task.attempt CbTransitionDelete request )

        Edit ->
            case model.view of
                ViewPosition _ (Success p) ->
                    let
                        form_ =
                            { emptyForm
                                | name = p.name
                                , notes = p.notes
                            }
                    in
                    ( { model | view = ViewPosition True (Success p), form = form_ }, Cmd.none )

                ViewSubmission _ s ->
                    let
                        form_ =
                            { emptyForm
                                | name = s.name
                                , steps = s.steps
                                , notes = s.notes
                                , startPosition =
                                    get s.position model.positions
                                        |> unwrap Pending Picked
                            }
                    in
                    ( { model | view = ViewSubmission True s, form = form_ }, Cmd.none )

                ViewTopic _ t ->
                    let
                        form_ =
                            { emptyForm
                                | name = t.name
                                , notes = t.notes
                            }
                    in
                    ( { model | view = ViewTopic True t, form = form_ }, Cmd.none )

                ViewTransition _ t ->
                    let
                        form_ =
                            { emptyForm
                                | name = t.name
                                , steps = t.steps
                                , notes = t.notes
                                , startPosition =
                                    get t.startPosition model.positions
                                        |> unwrap Pending Picked
                                , endPosition =
                                    get t.endPosition model.positions
                                        |> unwrap Pending Picked
                            }
                    in
                    ( { model | view = ViewTransition True t, form = form_ }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Save ->
            case model.view of
                ViewCreatePosition ->
                    ( model
                    , createPosition form.name form.notes
                        |> mutation model.url model.token CbPosition
                    )

                ViewCreateSubmission ->
                    case form.startPosition of
                        Picked { id } ->
                            ( model
                            , createSubmission form.name form.steps form.notes id
                                |> mutation model.url model.token CbSubmission
                            )

                        _ ->
                            ( model, log "missing position" )

                ViewCreateTopic ->
                    ( model
                    , createTopic form.name form.notes
                        |> mutation model.url model.token CbTopic
                    )

                ViewCreateTransition ->
                    case ( form.startPosition, form.endPosition ) of
                        ( Picked start, Picked end ) ->
                            ( model
                            , createTransition form.name
                                form.steps
                                form.notes
                                start.id
                                end.id
                                |> mutation model.url model.token CbTransition
                            )

                        _ ->
                            ( model, log "missing position" )

                ViewPosition _ (Success p) ->
                    case Validate.position p.id form of
                        Ok value ->
                            ( model
                            , updatePosition value
                                |> mutation model.url model.token CbPosition
                            )

                        Err _ ->
                            ( { model | view = ViewPosition True (Success p) }, Cmd.none )

                ViewSubmission _ s ->
                    case Validate.submission s.id form of
                        Ok value ->
                            ( model
                            , updateSubmission value
                                |> mutation model.url model.token CbSubmission
                            )

                        Err _ ->
                            ( { model | view = ViewSubmission True s }, Cmd.none )

                ViewTopic _ t ->
                    case Validate.topic t.id form of
                        Ok value ->
                            ( model
                            , updateTopic value
                                |> mutation model.url model.token CbTopic
                            )

                        Err _ ->
                            ( { model | view = ViewTopic True t }, Cmd.none )

                ViewTransition _ t ->
                    case Validate.transition t.id form of
                        Ok value ->
                            ( model
                            , updateTransition value
                                |> mutation model.url model.token CbTransition
                            )

                        Err _ ->
                            ( { model | view = ViewTransition True t }, Cmd.none )

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

        Update f ->
            ( { model | form = f }, Cmd.none )

        UpdateEndPosition selectMsg ->
            case form.endPosition of
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
                            model.form |> (\f -> { f | endPosition = picker })
                    in
                    ( { model | form = form_ }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdateStartPosition selectMsg ->
            case form.startPosition of
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
