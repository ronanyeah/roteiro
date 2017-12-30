module Router exposing (..)

import Data exposing (fetchPosition, fetchPositions, fetchSubmission, fetchSubmissions, fetchTopic, fetchTopics, fetchTransition, fetchTransitions, query)
import Navigation exposing (Location)
import Paths
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import UrlParser exposing ((</>), Parser, map, oneOf, parseHash, s, string)
import Utils exposing (appendCmd, log, taskToGcData)


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


route : Parser (Route -> a) a
route =
    oneOf
        [ map Ps (s positions)
        , map Ss (s submissions)
        , map Ts (s topics)
        , map Trs (s transitions)
        , map (Id >> P) (s positions </> string)
        , map (Id >> S) (s submissions </> string)
        , map (Id >> To) (s topics </> string)
        , map (Id >> T) (s transitions </> string)
        , map Start (s start)
        ]


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


router : Model -> Route -> ( Model, Cmd Msg )
router model route =
    let
        redirectToStart =
            ( model, Navigation.newUrl Paths.start )

        doNothing =
            ( model, Cmd.none )
    in
    case route of
        Ps ->
            ( { model | view = ViewPositions, positions = Loading }
            , fetchPositions
                |> query model.url model.token
                |> taskToGcData CbPositions
            )

        P id ->
            if dataIsLoaded model.view id then
                doNothing
            else
                ( { model | view = ViewPosition Loading }
                , fetchPosition id
                    |> query model.url model.token
                    |> taskToGcData CbPosition
                )

        Ss ->
            ( { model | view = ViewSubmissions Loading }
            , fetchSubmissions
                |> query model.url model.token
                |> taskToGcData CbSubmissions
            )

        Ts ->
            ( { model | view = ViewTopics Loading }
            , fetchTopics
                |> query model.url model.token
                |> taskToGcData CbTopics
            )

        Trs ->
            ( { model | view = ViewTransitions Loading }
            , fetchTransitions
                |> query model.url model.token
                |> taskToGcData CbTransitions
            )

        To id ->
            if dataIsLoaded model.view id then
                doNothing
            else
                ( { model | view = ViewTopic Loading }
                , fetchTopic id
                    |> query model.url model.token
                    |> taskToGcData CbTopic
                )

        T id ->
            if dataIsLoaded model.view id then
                doNothing
            else
                ( { model | view = ViewTransition Loading }
                , fetchTransition id
                    |> query model.url model.token
                    |> taskToGcData CbTransition
                )

        Top ->
            redirectToStart

        S id ->
            if dataIsLoaded model.view id then
                doNothing
            else
                ( { model | view = ViewSubmission Loading }
                , fetchSubmission id
                    |> query model.url model.token
                    |> taskToGcData CbSubmission
                )

        Start ->
            ( { model | view = ViewStart }, Cmd.none )

        NotFound ->
            redirectToStart
                |> appendCmd (log "route not found")


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFound
