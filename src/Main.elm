module Main exposing (main)

import Array exposing (Array)
import Data exposing (fetchData, updatePosition, createTransition, updateTransition)
import Dict exposing (Dict)
import Editable exposing (Editable)
import Element exposing (Element, column, el, empty, paragraph, row, text, viewport, when)
import Element.Attributes exposing (center, class, fill, height, maxWidth, padding, px, spacing, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import GraphQL.Client.Http as GQLH
import Html exposing (Html)
import Task
import Types exposing (..)
import Utils exposing (listToDict, log, set)
import View exposing (view)


main : Program String Model Msg
main =
    Html.programWithFlags
        { init =
            \url ->
                ( { view = ViewAll
                  , positions = Dict.empty
                  , transitions = Dict.empty
                  , submissions = Dict.empty
                  , topics = Array.empty
                  , url = url
                  }
                , Task.attempt CbData (GQLH.sendQuery url fetchData)
                )
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddSubmissionInput form ->
            ( { model | view = ViewAddSubmission form }, Cmd.none )

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

        NewTransitionInput form ->
            ( { model | view = ViewNewTransition form }, Cmd.none )

        SelectPosition p ->
            ( { model | view = ViewPosition (Editable.ReadOnly p) }, Cmd.none )

        SelectSubmission s ->
            ( { model | view = ViewSubmission s }, Cmd.none )

        SelectTransition t ->
            ( { model | view = ViewTransition (Editable.ReadOnly t) }, Cmd.none )

        SelectNotes ->
            ( { model | view = ViewNotes Nothing }, Cmd.none )

        Reset ->
            ( { model | view = ViewAll }, Cmd.none )

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

        Save ->
            case model.view of
                ViewPosition p ->
                    if Editable.isDirty p then
                        ( model
                        , Task.attempt SavePosition (GQLH.sendMutation model.url (updatePosition (Editable.value p)))
                        )
                    else
                        ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewTransition t ->
                    if Editable.isDirty t then
                        ( model
                        , Task.attempt SaveTransition (GQLH.sendMutation model.url (updateTransition (Editable.value t)))
                        )
                    else
                        ( { model | view = ViewTransition <| Editable.cancel t }, Cmd.none )

                ViewNewTransition form ->
                    ( model, Task.attempt SaveTransition (GQLH.sendMutation model.url (createTransition form)) )

                _ ->
                    ( model, Cmd.none )

        Cancel ->
            case model.view of
                ViewPosition p ->
                    ( { model | view = ViewPosition <| Editable.cancel p }, Cmd.none )

                ViewNewTransition { startPosition } ->
                    ( { model | view = ViewPosition <| Editable.ReadOnly startPosition }, Cmd.none )

                ViewAddSubmission { position } ->
                    ( { model | view = ViewPosition <| Editable.ReadOnly position }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SavePosition res ->
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

        SaveTransition res ->
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

        AddTransition p ->
            ( { model
                | view =
                    ViewNewTransition
                        { name = ""
                        , startPosition = p
                        , endPosition = Waiting
                        , steps = Array.empty
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        AddSubmission p ->
            ( { model
                | view =
                    ViewAddSubmission
                        { name = ""
                        , position = p
                        , steps = Array.empty
                        , notes = Array.empty
                        }
              }
            , Cmd.none
            )

        NotesInput t ->
            ( { model | view = ViewNotes (Just t) }, Cmd.none )
