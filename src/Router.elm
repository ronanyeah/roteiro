module Router exposing (parseLocation, router)

import Editable
import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing (Parser, (</>), map, oneOf, parseHash, s, string, top)
import Utils exposing (unwrap)


route : Parser (Route -> a) a
route =
    oneOf
        [ map Ps (s "ps")
        , map Ts (s "ts")
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
                                ( ViewPosition <| Editable.ReadOnly p, Cmd.none )
                            )

                Ts ->
                    ( ViewTopics, Cmd.none )

                To id ->
                    Utils.get id model.topics
                        |> unwrap err
                            (\p ->
                                ( ViewTopic <| Editable.ReadOnly p, Cmd.none )
                            )

                T id ->
                    case Utils.get id model.transitions of
                        Just t ->
                            ( ViewTransition <| Editable.ReadOnly t, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                S id ->
                    case Utils.get id model.submissions of
                        Just sub ->
                            ( ViewSubmission <| Editable.ReadOnly sub, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                Top ->
                    ( ViewAll, Cmd.none )

                NotFound ->
                    ( ViewAll, Navigation.newUrl "/#/" )
    in
        ( { model | view = view }, cmd )


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFound
