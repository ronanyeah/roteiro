module Router exposing (parseLocation, router)

import Editable
import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing (Parser, (</>), map, oneOf, parseHash, s, string)
import Utils


route : Parser (Route -> a) a
route =
    oneOf
        [ map Ps (s "ps")
        , map Ts (s "ts")
        , map (Id >> P) (s "ps" </> string)
        , map (Id >> T) (s "t" </> string)
        , map (Id >> S) (s "s" </> string)
        ]


router : Model -> Route -> ( Model, Cmd Msg )
router model route =
    let
        ( view, cmd ) =
            case route of
                Ps ->
                    ( ViewAll, Cmd.none )

                P id ->
                    case Utils.get id model.positions of
                        Just p ->
                            ( ViewPosition <| Editable.ReadOnly p, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                Ts ->
                    ( ViewTopics Nothing, Cmd.none )

                T id ->
                    case Utils.get id model.transitions of
                        Just t ->
                            ( ViewTransition <| Editable.ReadOnly t, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                S id ->
                    case Utils.get id model.submissions of
                        Just s ->
                            ( ViewSubmission <| Editable.ReadOnly s, Cmd.none )

                        Nothing ->
                            ( ViewAll, Navigation.newUrl "/#/ps" )

                NotFoundRoute ->
                    ( ViewAll, Navigation.newUrl "/#/ps" )
    in
        ( { model | view = view }, cmd )


parseLocation : Location -> Route
parseLocation =
    parseHash route
        >> Maybe.withDefault NotFoundRoute
