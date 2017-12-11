module Router exposing (..)

import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing (Parser, (</>), map, oneOf, parseHash, s, string, top)
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
        , map Top top
        , map (Id >> T) (s "t" </> string)
        , map (Id >> To) (s "to" </> string)
        , map (Id >> S) (s "s" </> string)
        ]


router : Model -> Route -> ( Model, Cmd Msg )
router model route =
    let
        err =
            ( model.view, Navigation.newUrl "/#/" )

        ( view, cmd ) =
            case route of
                Ps ->
                    ( ViewPositions, Cmd.none )

                P id ->
                    Utils.get id model.positions
                        |> unwrap err
                            (\p ->
                                ( ViewPosition False p, Cmd.none )
                            )

                Ss ->
                    ( ViewSubmissions, Cmd.none )

                Ts ->
                    ( ViewTopics, Cmd.none )

                Trs ->
                    ( ViewTransitions, Cmd.none )

                To id ->
                    Utils.get id model.topics
                        |> unwrap err
                            (\p ->
                                ( ViewTopic False p, Cmd.none )
                            )

                T id ->
                    case Utils.get id model.transitions of
                        Just t ->
                            ( ViewTransition False t, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                Top ->
                    ( ViewAll, Cmd.none )

                S id ->
                    case Utils.get id model.submissions of
                        Just sub ->
                            ( ViewSubmission False sub, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                NotFound ->
                    err
    in
        ( { model | view = view }, cmd )


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFound
