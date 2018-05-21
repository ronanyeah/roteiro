module Router exposing (router)

import Api.Scalar exposing (Id(..))
import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import UrlParser exposing ((</>), (<?>), Parser, map, oneOf, parsePath, s, string, stringParam)


routes : List (Parser (Route -> a) a)
routes =
    [ map Positions (s "app" </> s "positions")
    , map Submissions (s "app" </> s "submissions")
    , map TagsRoute (s "app" </> s "tags")
    , map Topics (s "app" </> s "topics")
    , map Transitions (s "app" </> s "transitions")
    , map CreatePositionRoute (s "app" </> s "positions" </> s "new")
    , map CreateSubmissionRoute (s "app" </> s "submissions" </> s "new" <?> stringParam "start")
    , map CreateTagRoute (s "app" </> s "tags" </> s "new")
    , map CreateTopicRoute (s "app" </> s "topics" </> s "new")
    , map CreateTransitionRoute (s "app" </> s "transitions" </> s "new" <?> stringParam "start" <?> stringParam "end")
    , map (Id >> PositionRoute) (s "app" </> s "positions" </> string)
    , map (Id >> SubmissionRoute) (s "app" </> s "submissions" </> string)
    , map (Id >> TagRoute) (s "app" </> s "tags" </> string)
    , map (Id >> TopicRoute) (s "app" </> s "topics" </> string)
    , map (Id >> TransitionRoute) (s "app" </> s "transitions" </> string)
    , map Start (s "app" </> s "start")
    , map Login (s "app" </> s "login")
    , map SignUp (s "app" </> s "sign-up")
    ]


router : Location -> Route
router =
    parsePath (oneOf routes)
        >> Maybe.withDefault NotFound
