module Router exposing (..)

import Data exposing (fetchPosition, fetchPositions, fetchSubmission, fetchSubmissions, fetchTopic, fetchTopics, fetchTransition, fetchTransitions, query)
import Navigation exposing (Location)
import Paths
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import UrlParser exposing ((</>), map, oneOf, parseHash, s, string)
import Utils exposing (taskToGcData)


stripHash : String -> String
stripHash =
    String.dropLeft 3


positions : String
positions =
    stripHash Paths.positions


submissions : String
submissions =
    stripHash Paths.submissions


topics : String
topics =
    stripHash Paths.topics


transitions : String
transitions =
    stripHash Paths.transitions


start : String
start =
    stripHash Paths.start


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


handleRoute : Model -> Route -> ( Model, Cmd Msg )
handleRoute model route =
    let
        doNothing =
            ( model, Cmd.none )
    in
    case route of
        NotFound ->
            ( model, Navigation.newUrl Paths.start )

        PositionRoute id ->
            if dataIsLoaded model.view id then
                doNothing
            else
                ( { model | view = ViewPosition Loading }
                , fetchPosition id
                    |> query model.token
                    |> taskToGcData CbPosition
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
                    |> taskToGcData CbSubmission
                )

        Submissions ->
            ( { model | view = ViewSubmissions Loading }
            , fetchSubmissions
                |> query model.token
                |> taskToGcData CbSubmissions
            )

        Start ->
            ( { model | view = ViewStart }, Cmd.none )

        TopicRoute id ->
            if dataIsLoaded model.view id then
                doNothing
            else
                ( { model | view = ViewTopic Loading }
                , fetchTopic id
                    |> query model.token
                    |> taskToGcData CbTopic
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
                    |> taskToGcData CbTransition
                )

        Transitions ->
            ( { model | view = ViewTransitions Loading }
            , fetchTransitions
                |> query model.token
                |> taskToGcData CbTransitions
            )


router : Model -> Location -> ( Model, Cmd Msg )
router model =
    parseHash
        (oneOf
            [ map Positions (s positions)
            , map Submissions (s submissions)
            , map Topics (s topics)
            , map Transitions (s transitions)
            , map (Id >> PositionRoute) (s positions </> string)
            , map (Id >> SubmissionRoute) (s submissions </> string)
            , map (Id >> TopicRoute) (s topics </> string)
            , map (Id >> TransitionRoute) (s transitions </> string)
            , map Start (s start)
            ]
        )
        >> Maybe.withDefault NotFound
        >> handleRoute model
