module Router exposing (..)

import Data exposing (fetchPosition, fetchPositions, fetchSubmissions, query)
import Navigation exposing (Location)
import RemoteData
import Types exposing (..)
import UrlParser exposing ((</>), Parser, map, oneOf, parseHash, s, string)
import Utils exposing (unwrap)


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
            ( model.view, Navigation.newUrl "/#/start" )

        ( view, cmd ) =
            case route of
                Ps ->
                    ( ViewPositions RemoteData.Loading
                    , fetchPositions |> query model.url model.token CbPositions
                    )

                P id ->
                    ( ViewPosition False RemoteData.Loading
                    , fetchPosition id
                        |> query model.url model.token CbPosition
                    )

                Ss ->
                    ( ViewSubmissions RemoteData.Loading
                    , fetchSubmissions |> query model.url model.token CbSubmissions
                    )

                Ts ->
                    ( ViewTopics, Cmd.none )

                Trs ->
                    ( ViewTransitions, Cmd.none )

                To id ->
                    model.topics
                        |> Utils.get id
                        |> unwrap default
                            (\topic ->
                                ( ViewTopic False topic, Cmd.none )
                            )

                T id ->
                    model.transitions
                        |> Utils.get id
                        |> unwrap default
                            (\transition ->
                                ( ViewTransition False transition, Cmd.none )
                            )

                Top ->
                    default

                S id ->
                    model.submissions
                        |> Utils.get id
                        |> unwrap default
                            (\submission ->
                                ( ViewSubmission False submission, Cmd.none )
                            )

                Start ->
                    ( ViewStart, Cmd.none )

                NotFound ->
                    default
    in
    ( { model | view = view }, cmd )


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFound
