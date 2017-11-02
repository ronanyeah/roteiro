module Update exposing (..)

import Array exposing (Array)
import Editable exposing (Editable)
import Data exposing (createPosition, fetchData, updatePosition, createTransition, updateTransition)
import GraphQL.Client.Http as GQLH
import Task
import Types exposing (..)
import Utils exposing (listToDict, log, set)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Cancel ->
            case model.view of
                ViewPosition p ->
                    ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewCreateTransition { startPosition } ->
                    ( { model | view = ViewPosition <| Editable.ReadOnly startPosition }, Cmd.none )

                ViewCreateSubmission { position } ->
                    ( { model | view = ViewPosition <| Editable.ReadOnly position }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CbData res ->
            case res of
                Ok { transitions, positions, submissions, topics } ->
                    ( { model
                        | transitions = listToDict transitions
                        , positions = listToDict positions
                        , submissions = listToDict submissions
                        , topics = topics |> Array.fromList
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

        CreatePosition ->
            ( { model
                | view =
                    ViewCreatePosition
                        { name = ""
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        CreateSubmission p ->
            ( { model
                | view =
                    ViewCreateSubmission
                        { name = ""
                        , position = p
                        , steps = Array.empty
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        CreateTransition p ->
            ( { model
                | view =
                    ViewCreateTransition
                        { name = ""
                        , startPosition = p
                        , endPosition = Waiting
                        , steps = Array.empty
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

        InputCreatePosition form ->
            ( { model | view = ViewCreatePosition form }, Cmd.none )

        InputCreateSubmission form ->
            ( { model | view = ViewCreateSubmission form }, Cmd.none )

        InputCreateTransition form ->
            ( { model | view = ViewCreateTransition form }, Cmd.none )

        InputTopic t ->
            ( { model | view = ViewTopics (Just t) }, Cmd.none )

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

                ViewCreateTransition form ->
                    ( model, Task.attempt CbTransition (GQLH.sendMutation model.url (createTransition form)) )

                ViewCreatePosition form ->
                    ( model, Task.attempt CbPosition <| GQLH.sendMutation model.url <| createPosition form )

                _ ->
                    ( model, Cmd.none )

        SelectPosition p ->
            ( { model | view = ViewPosition (Editable.ReadOnly p) }, Cmd.none )

        SelectSubmission s ->
            ( { model | view = ViewSubmission s }, Cmd.none )

        SelectTopics ->
            ( { model | view = ViewTopics Nothing }, Cmd.none )

        SelectTransition t ->
            ( { model | view = ViewTransition (Editable.ReadOnly t) }, Cmd.none )
