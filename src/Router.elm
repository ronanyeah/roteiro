module Router exposing (..)

import Data exposing (fetchPosition, fetchPositions, fetchSubmission, fetchSubmissions, fetchTopic, fetchTopics, fetchTransition, fetchTransitions, query)
import Navigation exposing (Location)
import Paths
import RemoteData
import Types exposing (..)
import UrlParser exposing ((</>), Parser, map, oneOf, parseHash, s, string)
import Utils exposing (appendCmd, log)


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


router : Model -> Route -> ( Model, Cmd Msg )
router model route =
    let
        default =
            ( model, Navigation.newUrl Paths.start )
    in
    case route of
        Ps ->
            ( { model | view = ViewPositions, positions = RemoteData.Loading }
            , fetchPositions |> query model.url model.token CbPositions
            )

        P id ->
            ( { model | view = ViewPosition RemoteData.Loading }
            , fetchPosition id
                |> query model.url model.token CbPosition
            )

        Ss ->
            ( { model | view = ViewSubmissions RemoteData.Loading }
            , fetchSubmissions |> query model.url model.token CbSubmissions
            )

        Ts ->
            ( { model | view = ViewTopics RemoteData.Loading }
            , fetchTopics |> query model.url model.token CbTopics
            )

        Trs ->
            ( { model | view = ViewTransitions RemoteData.Loading }
            , fetchTransitions |> query model.url model.token CbTransitions
            )

        To id ->
            ( { model | view = ViewTopic RemoteData.Loading }
            , fetchTopic id |> query model.url model.token CbTopic
            )

        T id ->
            ( { model | view = ViewTransition RemoteData.Loading }
            , fetchTransition id
                |> query model.url model.token CbTransition
            )

        Top ->
            default

        S id ->
            ( { model | view = ViewSubmission RemoteData.Loading }
            , fetchSubmission id
                |> query model.url model.token CbSubmission
            )

        Start ->
            ( { model | view = ViewStart }, Cmd.none )

        NotFound ->
            default
                |> appendCmd (log "route not found")


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFound
