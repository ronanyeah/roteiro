module Router exposing (..)

import Data exposing (fetchPosition, fetchPositions, fetchSubmission, fetchSubmissions, fetchTopic, fetchTopics, fetchTransition, fetchTransitions, query)
import Navigation exposing (Location)
import RemoteData
import Types exposing (..)
import UrlParser exposing ((</>), Parser, map, oneOf, parseHash, s, string)


position : Id -> String
position (Id id) =
    "/#/p/" ++ id


submission : Id -> String
submission (Id id) =
    "/#/s/" ++ id


topic : Id -> String
topic (Id id) =
    "/#/to/" ++ id


transition : Id -> String
transition (Id id) =
    "/#/t/" ++ id


route : Parser (Route -> a) a
route =
    oneOf
        [ map Ps (s "ps")
        , map Ts (s "ts")
        , map Trs (s "trs")
        , map Ss (s "ss")
        , map (Id >> P) (s "p" </> string)
        , map Start (s "start")
        , map (Id >> T) (s "t" </> string)
        , map (Id >> To) (s "to" </> string)
        , map (Id >> S) (s "s" </> string)
        ]


router : Model -> Route -> ( Model, Cmd Msg )
router model route =
    let
        default =
            ( model, Navigation.newUrl "/#/start" )
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


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFound
