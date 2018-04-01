module Router exposing (router)

import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import UrlParser exposing ((</>), Parser, map, oneOf, parsePath, s, string)


routes : List (Parser (Route -> a) a)
routes =
    [ map Positions (s "positions")
    , map Submissions (s "submissions")
    , map TagsRoute (s "tags")
    , map Topics (s "topics")
    , map Transitions (s "transitions")
    , map (Id >> PositionRoute) (s "positions" </> string)
    , map (Id >> SubmissionRoute) (s "submissions" </> string)
    , map (Id >> TagRoute) (s "tags" </> string)
    , map (Id >> TopicRoute) (s "topics" </> string)
    , map (Id >> TransitionRoute) (s "transitions" </> string)
    , map Start (s "start")
    , map Login (s "login")
    , map SignUp (s "sign-up")
    ]


router : Location -> Route
router =
    parsePath (oneOf routes)
        >> Maybe.withDefault NotFound
