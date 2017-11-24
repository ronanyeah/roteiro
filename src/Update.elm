module Update exposing (..)

import Array
import Editable
import Editor
import Data exposing (createTopic, createPosition, createSubmission, createTransition, mutate, updatePosition, updateSubmission, updateTopic, updateTransition)
import Element
import Element.Input as Input
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

                ViewCreatePosition _ ->
                    ( { model | view = ViewPositions }, Cmd.none )

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
                    ( { model | view = ViewTopics }, Cmd.none )

                ViewPosition p ->
                    ( { model | view = ViewPosition <| Editable.cancel p, confirm = Nothing }, Cmd.none )

                ViewPositions ->
                    ( model, Cmd.none )

                ViewSubmission s ->
                    ( { model | view = ViewSubmission <| Editor.cancel s, confirm = Nothing }, Cmd.none )

                ViewSubmissions ->
                    ( model, Cmd.none )

                ViewTopics ->
                    ( model, Cmd.none )

                ViewTopic t ->
                    ( { model | view = ViewTopic <| Editable.cancel t, confirm = Nothing }, Cmd.none )

                ViewTransition t ->
                    ( { model | view = ViewTransition <| Editable.cancel t, confirm = Nothing }, Cmd.none )

                ViewTransitions ->
                    ( model, Cmd.none )

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
                        , confirm = Nothing
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbSubmission res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewSubmission <| ReadOnly data
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
                            , confirm = Nothing
                          }
                        , Cmd.none
                        )

                Err err ->
                    ( model, log err )

        CbTopic res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewTopic <| Editable.ReadOnly data
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
                            , confirm = Nothing
                          }
                        , Cmd.none
                        )

                Err err ->
                    ( model, log err )

        Confirm maybeM ->
            ( { model | confirm = maybeM }, Cmd.none )

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
                        { emptyForm | startPosition = p }
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
                        { emptyForm | startPosition = p }
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

        Edit ->
            case model.view of
                ViewSubmission (ReadOnly a) ->
                    ( { model | view = ViewSubmission (Editing emptyForm a) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

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

        EditTransition t ->
            case model.view of
                ViewTransition editT ->
                    ( { model
                        | view = ViewTransition <| Editable.map (always t) <| Editable.edit editT
                      }
                    , Cmd.none
                    )

                _ ->
                    Debug.crash "EditTransition"

        EditTopic t ->
            case model.view of
                ViewTopic editT ->
                    ( { model
                        | view = ViewTopic <| Editable.map (always t) <| Editable.edit editT
                      }
                    , Cmd.none
                    )

                _ ->
                    Debug.crash "EditTopic"

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

        Update form ->
            case model.view of
                ViewCreatePosition _ ->
                    ( { model | view = ViewCreatePosition form }, Cmd.none )

                ViewCreateSubmission _ ->
                    ( { model | view = ViewCreateSubmission form }, Cmd.none )

                ViewCreateTopic _ ->
                    ( { model | view = ViewCreateTopic form }, Cmd.none )

                ViewCreateTransition _ ->
                    ( { model | view = ViewCreateTransition form }, Cmd.none )

                ViewPosition p ->
                    ( { model | view = ViewPosition <| Editable.cancel p, confirm = Nothing }, Cmd.none )

                ViewSubmission s ->
                    ( { model | view = ViewSubmission <| Editor.cancel s, confirm = Nothing }, Cmd.none )

                ViewTopic t ->
                    ( { model | view = ViewTopic <| Editable.cancel t, confirm = Nothing }, Cmd.none )

                ViewTransition t ->
                    ( { model | view = ViewTransition <| Editable.cancel t, confirm = Nothing }, Cmd.none )

                _ ->
                    Debug.crash "!"

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

                ViewSubmission s ->
                    case Utils.validateSubmission s of
                        Just value ->
                            ( model
                            , Task.attempt CbSubmission (mutate model.url model.token (updateSubmission value))
                            )

                        Nothing ->
                            ( { model | view = ViewSubmission s }, Cmd.none )

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

                ViewTopic t ->
                    if Editable.isDirty t then
                        ( model
                        , Task.attempt CbTopic (mutate model.url model.token (updateTopic (Editable.value t)))
                        )
                    else
                        ( { model | view = ViewTopic <| Editable.cancel t }, Cmd.none )

                _ ->
                    Debug.crash "Save"

        SelectStartPosition m ->
            case model.view of
                ViewSubmission (Editing f s) ->
                    ( { model | view = ViewSubmission <| Editing { f | startTest = Input.updateSelection m f.startTest } s }, Cmd.none )

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
