module Router exposing (router)

import Navigation exposing (Location)
import Paths
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import UrlParser exposing ((</>), Parser, map, oneOf, parsePath, s, string)


routes : List (Parser (Route -> a) a)
routes =
    [ map Positions (s Paths.positions)
    , map Submissions (s Paths.submissions)
    , map TagsRoute (s Paths.tags)
    , map Topics (s Paths.topics)
    , map Transitions (s Paths.transitions)
    , map (Id >> PositionRoute) (s Paths.positions </> string)
    , map (Id >> SubmissionRoute) (s Paths.submissions </> string)
    , map (Id >> TagRoute) (s Paths.tags </> string)
    , map (Id >> TopicRoute) (s Paths.topics </> string)
    , map (Id >> TransitionRoute) (s Paths.transitions </> string)
    , map Start (s Paths.start)
    , map Login (s Paths.login)
    , map SignUp (s Paths.signUp)
    ]


router : Location -> Route
router =
    parsePath (oneOf routes)
        >> Maybe.withDefault NotFound
