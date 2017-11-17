module Update exposing (..)

import Array
import Editable
import Data exposing (createTopic, createPosition, createSubmission, createTransition, mutate, updatePosition, updateTopic, updateTransition)
import Element
import Ports
import Router exposing (router)
import Task
import Types exposing (..)
import Utils exposing (del, emptyForm, get, listToDict, log, set, unwrap)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Cancel ->
            case model.view of
                ViewAll ->
                    ( model, Cmd.none )

                ViewPosition p ->
                    ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewCreatePosition _ ->
                    ( { model | view = ViewAll }, Cmd.none )

                ViewCreateTransition { startPosition } ->
                    case startPosition of
                        Just p ->
                            ( { model | view = ViewPosition <| Editable.ReadOnly p }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                ViewCreateSubmission { startPosition } ->
                    case startPosition of
                        Just p ->
                            ( { model | view = ViewPosition <| Editable.ReadOnly p }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                ViewCreateTopic _ ->
                    ( { model | view = ViewTopics Nothing }, Cmd.none )

                ViewSubmission s ->
                    ( { model | view = ViewSubmission <| Editable.cancel s }, Cmd.none )

                ViewTopics _ ->
                    ( { model | view = ViewTopics Nothing }, Cmd.none )

                ViewTransition t ->
                    ( { model | view = ViewTransition <| Editable.cancel t }, Cmd.none )

        CancelPicker ->
            ( { model | choosingPosition = Nothing }, Cmd.none )

        CbData res ->
            case res of
                Ok { transitions, positions, submissions, topics } ->
                    ( { model
                        | transitions = listToDict transitions
                        , positions = listToDict positions
                        , submissions = listToDict submissions
                        , topics = listToDict topics
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbPosition res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewPosition <| Editable.ReadOnly data
                        , positions = set data model.positions
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbPositionDelete res ->
            case res of
                Ok id ->
                    ( { model
                        | view = ViewAll
                        , positions = del id model.positions
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbSubmission res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewSubmission <| Editable.ReadOnly data
                        , submissions = set data model.submissions
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbSubmissionDelete res ->
            case res of
                Ok data ->
                    let
                        view =
                            get data.position model.positions
                                |> unwrap ViewAll (Editable.ReadOnly >> ViewPosition)
                    in
                        ( { model
                            | view = view
                            , submissions = del data.id model.submissions
                          }
                        , Cmd.none
                        )

                Err err ->
                    ( model, log err )

        CbTopic res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewTopics Nothing
                        , topics = set data model.topics
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTopicDelete res ->
            case res of
                Ok id ->
                    ( { model
                        | view = ViewTopics Nothing
                        , topics = del id model.topics
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTransition res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewTransition <| Editable.ReadOnly data
                        , transitions = set data model.transitions
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTransitionDelete res ->
            case res of
                Ok data ->
                    let
                        view =
                            get data.startPosition model.positions
                                |> unwrap ViewAll (Editable.ReadOnly >> ViewPosition)
                    in
                        ( { model
                            | view = view
                            , transitions = del data.id model.transitions
                          }
                        , Cmd.none
                        )

                Err err ->
                    ( model, log err )

        ChoosePosition cb ->
            ( { model | choosingPosition = Just cb }, Cmd.none )

        CreatePosition ->
            ( { model
                | view =
                    ViewCreatePosition emptyForm
              }
            , Cmd.none
            )

        CreateSubmission p ->
            ( { model
                | view =
                    ViewCreateSubmission
                        { emptyForm | startPosition = Just p }
              }
            , Cmd.none
            )

        CreateTopic ->
            ( { model
                | view =
                    ViewCreateTopic emptyForm
              }
            , Cmd.none
            )

        CreateTransition p ->
            ( { model
                | view =
                    ViewCreateTransition
                        { emptyForm | startPosition = Just p }
              }
            , Cmd.none
            )

        DeletePosition id ->
            let
                request =
                    Data.deletePosition id
                        |> mutate model.url model.token
            in
                ( model, Task.attempt CbPositionDelete request )

        DeleteSubmission id ->
            let
                request =
                    Data.deleteSubmission id
                        |> mutate model.url model.token
            in
                ( model, Task.attempt CbSubmissionDelete request )

        DeleteTopic id ->
            let
                request =
                    Data.deleteTopic id
                        |> mutate model.url model.token
            in
                ( model, Task.attempt CbTopicDelete request )

        DeleteTransition id ->
            let
                request =
                    Data.deleteTransition id
                        |> mutate model.url model.token
            in
                ( model, Task.attempt CbTransitionDelete request )

        EditPosition p ->
            case model.view of
                ViewPosition editP ->
                    ( { model
                        | view = ViewPosition <| Editable.map (always p) <| Editable.edit editP
                      }
                    , Cmd.none
                    )

                _ ->
                    Debug.crash "EditPosition"

        EditSubmission s ->
            case model.view of
                ViewSubmission editS ->
                    ( { model
                        | view = ViewSubmission <| Editable.map (always s) <| Editable.edit editS
                        , choosingPosition = Nothing
                      }
                    , Cmd.none
                    )

                _ ->
                    Debug.crash "EditSubmission"

        EditTransition t ->
            case model.view of
                ViewTransition editT ->
                    ( { model
                        | view = ViewTransition <| Editable.map (always t) <| Editable.edit editT
                        , choosingPosition = Nothing
                      }
                    , Cmd.none
                    )

                _ ->
                    Debug.crash "EditTransition"

        EditTopic t ->
            ( { model | view = ViewTopics <| Just t }, Cmd.none )

        TokenEdit mT ->
            case mT of
                Nothing ->
                    ( { model | tokenForm = mT }, Cmd.none )

                Just "" ->
                    ( { model | tokenForm = mT }, Cmd.none )

                Just t ->
                    ( { model | tokenForm = Nothing, token = t }
                    , Ports.saveToken t
                    )

        FormUpdate form ->
            case model.view of
                ViewCreatePosition _ ->
                    ( { model | view = ViewCreatePosition form, choosingPosition = Nothing }, Cmd.none )

                ViewCreateSubmission _ ->
                    ( { model | view = ViewCreateSubmission form, choosingPosition = Nothing }, Cmd.none )

                ViewCreateTopic _ ->
                    ( { model | view = ViewCreateTopic form, choosingPosition = Nothing }, Cmd.none )

                ViewCreateTransition _ ->
                    ( { model | view = ViewCreateTransition form, choosingPosition = Nothing }, Cmd.none )

                _ ->
                    Debug.crash "FormUpdate"

        SetRoute route ->
            router model route

        Save ->
            case model.view of
                ViewPosition p ->
                    if Editable.isDirty p then
                        ( model
                        , Task.attempt CbPosition (mutate model.url model.token (updatePosition (Editable.value p)))
                        )
                    else
                        ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewTransition t ->
                    if Editable.isDirty t then
                        ( model
                        , Task.attempt CbTransition (mutate model.url model.token (updateTransition (Editable.value t)))
                        )
                    else
                        ( { model | view = ViewTransition <| Editable.cancel t }, Cmd.none )

                ViewCreateTransition { name, steps, notes, startPosition, endPosition } ->
                    case ( startPosition, endPosition ) of
                        ( Just start, Just end ) ->
                            let
                                request =
                                    createTransition name (Array.toList steps) (Array.toList notes) start.id end.id
                                        |> mutate model.url model.token
                            in
                                ( model, Task.attempt CbTransition request )

                        _ ->
                            ( model, log "missing position" )

                ViewCreateSubmission { name, steps, notes, startPosition } ->
                    startPosition
                        |> unwrap ( model, log "missing position" )
                            (\{ id } ->
                                let
                                    request =
                                        createSubmission name (Array.toList steps) (Array.toList notes) id
                                            |> mutate model.url model.token
                                in
                                    ( model, Task.attempt CbSubmission request )
                            )

                ViewCreatePosition form ->
                    ( model, Task.attempt CbPosition <| mutate model.url model.token <| createPosition form )

                ViewCreateTopic { name, notes } ->
                    let
                        request =
                            createTopic name (Array.toList notes)
                                |> mutate model.url model.token
                    in
                        ( model, Task.attempt CbTopic request )

                ViewTopics (Just topic) ->
                    ( model, Task.attempt CbTopic (mutate model.url model.token (updateTopic topic)) )

                _ ->
                    Debug.crash "Save"

        WindowSize size ->
            let
                device =
                    if size |> Element.classifyDevice |> .phone then
                        Mobile
                    else
                        Desktop
            in
                ( { model | device = device }, Cmd.none )
