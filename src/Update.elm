module Update exposing (..)

import Array
import Editable
import Data exposing (createTopic, createPosition, createSubmission, updatePosition, createTransition, updateTopic, updateTransition)
import GraphQL.Client.Http as GQLH
import Task
import Types exposing (..)
import Utils exposing (emptyForm, listToDict, log, set, singleton)


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
                        Picked p ->
                            ( { model | view = ViewPosition <| Editable.ReadOnly p }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                ViewCreateSubmission { startPosition } ->
                    case startPosition of
                        Picked p ->
                            ( { model | view = ViewPosition <| Editable.ReadOnly p }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                ViewEditTopic _ ->
                    ( { model | view = ViewTopics }, Cmd.none )

                ViewCreateTopic _ ->
                    ( { model | view = ViewTopics }, Cmd.none )

                ViewSubmission s ->
                    ( { model | view = ViewSubmission <| Editable.cancel s }, Cmd.none )

                ViewTopics ->
                    ( model, Cmd.none )

                ViewTransition t ->
                    ( { model | view = ViewTransition <| Editable.cancel t }, Cmd.none )

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

        CbTopic res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewTopics
                        , topics = set data model.topics
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

        CreatePosition ->
            ( { model
                | view =
                    ViewCreatePosition
                        { emptyForm
                            | name = ""
                            , notes = singleton ""
                        }
              }
            , Cmd.none
            )

        CreateSubmission p ->
            ( { model
                | view =
                    ViewCreateSubmission
                        { emptyForm
                            | name = ""
                            , startPosition = Picked p
                            , steps = singleton ""
                            , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        CreateTopic ->
            ( { model
                | view =
                    ViewCreateTopic
                        { emptyForm
                            | name = ""
                            , notes = singleton ""
                        }
              }
            , Cmd.none
            )

        CreateTransition p ->
            ( { model
                | view =
                    ViewCreateTransition
                        { name = ""
                        , startPosition = Picked p
                        , endPosition = Waiting
                        , steps = singleton ""
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        Edit ->
            case model.view of
                ViewPosition s ->
                    ( { model | view = ViewPosition <| Editable.edit s }, Cmd.none )

                ViewTransition t ->
                    ( { model | view = ViewTransition <| Editable.edit t }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        EditChange view ->
            ( { model | view = view }, Cmd.none )

        EditTopic t ->
            ( { model | view = ViewEditTopic t }, Cmd.none )

        FormUpdate form ->
            case model.view of
                ViewCreatePosition _ ->
                    ( { model | view = ViewCreatePosition form }, Cmd.none )

                ViewCreateSubmission _ ->
                    ( { model | view = ViewCreateSubmission form }, Cmd.none )

                ViewCreateTopic _ ->
                    ( { model | view = ViewCreateTopic form }, Cmd.none )

                ViewCreateTransition _ ->
                    ( { model | view = ViewCreateTransition form }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Reset ->
            ( { model | view = ViewAll }, Cmd.none )

        Save ->
            case model.view of
                ViewPosition p ->
                    if Editable.isDirty p then
                        ( model
                        , Task.attempt CbPosition (GQLH.sendMutation model.url (updatePosition (Editable.value p)))
                        )
                    else
                        ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewTransition t ->
                    if Editable.isDirty t then
                        ( model
                        , Task.attempt CbTransition (GQLH.sendMutation model.url (updateTransition (Editable.value t)))
                        )
                    else
                        ( { model | view = ViewTransition <| Editable.cancel t }, Cmd.none )

                ViewCreateTransition { name, steps, notes, startPosition, endPosition } ->
                    case ( startPosition, endPosition ) of
                        ( Picked start, Picked end ) ->
                            let
                                request =
                                    createTransition name (Array.toList steps) (Array.toList notes) start.id end.id
                                        |> GQLH.sendMutation model.url
                            in
                                ( model, Task.attempt CbTransition request )

                        _ ->
                            ( model, Cmd.none )

                ViewCreateSubmission { name, steps, notes, startPosition } ->
                    case startPosition of
                        Picked { id } ->
                            let
                                request =
                                    createSubmission name (Array.toList steps) (Array.toList notes) id
                                        |> GQLH.sendMutation model.url
                            in
                                ( model, Task.attempt CbSubmission request )

                        _ ->
                            ( model, Cmd.none )

                ViewCreatePosition form ->
                    ( model, Task.attempt CbPosition <| GQLH.sendMutation model.url <| createPosition form )

                ViewCreateTopic { name, notes } ->
                    let
                        request =
                            createTopic name (Array.toList notes)
                                |> GQLH.sendMutation model.url
                    in
                        ( model, Task.attempt CbTopic request )

                ViewEditTopic topic ->
                    ( model, Task.attempt CbTopic (GQLH.sendMutation model.url (updateTopic topic)) )

                _ ->
                    ( model, Cmd.none )

        SelectPosition p ->
            ( { model | view = ViewPosition <| Editable.ReadOnly p }, Cmd.none )

        SelectSubmission s ->
            ( { model | view = ViewSubmission <| Editable.ReadOnly s }, Cmd.none )

        SelectTopics ->
            ( { model | view = ViewTopics }, Cmd.none )

        SelectTransition t ->
            ( { model | view = ViewTransition (Editable.ReadOnly t) }, Cmd.none )
