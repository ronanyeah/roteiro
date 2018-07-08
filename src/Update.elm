module Update exposing (..)

import Api.Mutation
import Api.Object
import Api.Object.AuthResponse
import Api.Object.Position
import Api.Object.Submission
import Api.Object.Tag
import Api.Object.Topic
import Api.Object.Transition
import Api.Query
import Api.Scalar exposing (Id(..))
import Array
import Graphqelm.Field
import Graphqelm.Http
import Graphqelm.Operation exposing (RootMutation, RootQuery)
import Graphqelm.SelectionSet exposing (SelectionSet, with)
import Json.Encode as Encode
import Navigation
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Types exposing (..)
import Utils exposing (addErrors, arrayRemove, clearErrors, emptyForm, find, formatErrors, goTo, log, unwrap)
import Validate


topicInfo : SelectionSet Info Api.Object.Topic
topicInfo =
    Api.Object.Topic.selection Info
        |> with Api.Object.Topic.id
        |> with Api.Object.Topic.name


topic : SelectionSet Topic Api.Object.Topic
topic =
    Api.Object.Topic.selection Topic
        |> with Api.Object.Topic.id
        |> with Api.Object.Topic.name
        |> with (Api.Object.Topic.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))


positionInfo : SelectionSet Info Api.Object.Position
positionInfo =
    Api.Object.Position.selection Info
        |> with Api.Object.Position.id
        |> with Api.Object.Position.name


position : SelectionSet Position Api.Object.Position
position =
    Api.Object.Position.selection Position
        |> with Api.Object.Position.id
        |> with Api.Object.Position.name
        |> with (Api.Object.Position.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Position.submissions identity submissionInfo |> Graphqelm.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Position.transitionsFrom identity transition |> Graphqelm.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Position.transitionsTo identity transition |> Graphqelm.Field.map (Maybe.withDefault []))


transition : SelectionSet Transition Api.Object.Transition
transition =
    Api.Object.Transition.selection Transition
        |> with Api.Object.Transition.id
        |> with Api.Object.Transition.name
        |> with (Api.Object.Transition.startPosition identity positionInfo)
        |> with (Api.Object.Transition.endPosition identity positionInfo)
        |> with (Api.Object.Transition.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Transition.steps |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Transition.tags identity tagInfo |> Graphqelm.Field.map (Maybe.withDefault []))


transitionInfo : SelectionSet Info Api.Object.Transition
transitionInfo =
    Api.Object.Transition.selection Info
        |> with Api.Object.Transition.id
        |> with Api.Object.Transition.name


submissionInfo : SelectionSet Info Api.Object.Submission
submissionInfo =
    Api.Object.Submission.selection Info
        |> with Api.Object.Submission.id
        |> with Api.Object.Submission.name


submission : SelectionSet Submission Api.Object.Submission
submission =
    Api.Object.Submission.selection Submission
        |> with Api.Object.Submission.id
        |> with Api.Object.Submission.name
        |> with (Api.Object.Submission.steps |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Submission.notes |> Graphqelm.Field.map (unwrap Array.empty Array.fromList))
        |> with (Api.Object.Submission.position identity positionInfo)
        |> with (Api.Object.Submission.tags identity tagInfo |> Graphqelm.Field.map (Maybe.withDefault []))


tagInfo : SelectionSet Info Api.Object.Tag
tagInfo =
    Api.Object.Tag.selection Info
        |> with Api.Object.Tag.id
        |> with Api.Object.Tag.name


tag : SelectionSet Tag Api.Object.Tag
tag =
    Api.Object.Tag.selection Tag
        |> with Api.Object.Tag.id
        |> with Api.Object.Tag.name
        |> with (Api.Object.Tag.submissions identity submissionInfo |> Graphqelm.Field.map (Maybe.withDefault []))
        |> with (Api.Object.Tag.transitions identity transitionInfo |> Graphqelm.Field.map (Maybe.withDefault []))


auth : SelectionSet Auth Api.Object.AuthResponse
auth =
    Api.Object.AuthResponse.selection Auth
        |> with Api.Object.AuthResponse.id
        |> with Api.Object.AuthResponse.email
        |> with Api.Object.AuthResponse.token


fetch : String -> Graphqelm.Field.Field a RootQuery -> (GqlResult a -> Msg) -> Cmd Msg
fetch token sel msg =
    Api.Query.selection identity
        |> with sel
        |> Graphqelm.Http.queryRequest "/api"
        |> Graphqelm.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphqelm.Http.send msg


mutation : String -> Graphqelm.Field.Field a RootMutation -> (GqlResult a -> Msg) -> Cmd Msg
mutation token sel msg =
    Api.Mutation.selection identity
        |> with sel
        |> Graphqelm.Http.mutationRequest "/api"
        |> Graphqelm.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphqelm.Http.send msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        doNothing =
            ( model, Cmd.none )

        protect =
            flip
                (unwrap
                    ( model
                    , Cmd.batch
                        [ goTo Login
                        , log <| "Message interrupted: " ++ toString msg
                        ]
                    )
                )
                model.auth
    in
    case msg of
        AddTag tag ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | tags = f.tags |> Array.push tag }
                           )
              }
            , Cmd.none
            )

        Cancel ->
            case model.view of
                ViewApp ViewCreatePosition ->
                    ( model, goTo Positions )

                ViewApp ViewCreateSubmission ->
                    ( model
                    , model.previousRoute
                        |> Maybe.withDefault Submissions
                        |> goTo
                    )

                ViewApp ViewCreateTag ->
                    ( model, goTo TagsRoute )

                ViewApp ViewCreateTopic ->
                    ( model, goTo Topics )

                ViewApp ViewCreateTransition ->
                    ( { model | previousRoute = Nothing }
                    , model.previousRoute
                        |> Maybe.withDefault Transitions
                        |> goTo
                    )

                ViewApp (ViewEditPosition _) ->
                    ( { model | confirm = Nothing }
                    , goTo
                        Positions
                    )

                ViewApp ViewEditSubmission ->
                    ( { model | confirm = Nothing }
                    , goTo
                        Submissions
                    )

                ViewApp ViewEditTag ->
                    ( { model | confirm = Nothing }
                    , goTo
                        TagsRoute
                    )

                ViewApp ViewEditTopic ->
                    ( { model | confirm = Nothing }
                    , goTo
                        Topics
                    )

                ViewApp ViewEditTransition ->
                    ( { model | confirm = Nothing }
                    , goTo
                        Transitions
                    )

                _ ->
                    ( model, goTo Start )

        CbAuth res ->
            case res of
                Ok auth ->
                    ( { model | auth = Just auth }
                    , Cmd.batch
                        [ saveAuth auth
                        , goTo Start
                        ]
                    )

                Err err ->
                    ( { model
                        | form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbChangePassword res ->
            case res of
                Ok _ ->
                    ( model
                    , goTo Start
                    )

                Err err ->
                    ( { model
                        | form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbCreateOrUpdatePosition res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewPosition <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| PositionRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbCreateOrUpdateSubmission res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewSubmission <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| SubmissionRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateTag res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewTag <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| TagRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateTopic res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewTopic <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| TopicRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbCreateOrUpdateTransition res ->
            case res of
                Ok a ->
                    ( { model
                        | view = ViewApp <| ViewTransition <| Success a
                        , confirm = Nothing
                      }
                    , goTo <| TransitionRoute a.id
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , Cmd.none
                    )

        CbDeletePosition res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                      -- Forces reload of previous page so deleted data won't be visible.
                    , Navigation.back 1
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteSubmission res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo Submissions
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteTag res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo TagsRoute
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteTopic res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo Topics
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbDeleteTransition res ->
            case res of
                Ok _ ->
                    ( { model | confirm = Nothing }
                    , goTo Transitions
                    )

                Err err ->
                    ( { model
                        | confirm = Nothing
                        , form =
                            model.form
                                |> addErrors (formatErrors err)
                      }
                    , log err
                    )

        CbPosition res ->
            case res of
                Ok (Just data) ->
                    ( { model
                        | view = ViewApp <| ViewPosition <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Ok Nothing ->
                    ( model
                    , goTo Start
                    )

                Err err ->
                    ( model, log err )

        CbPositions res ->
            case res of
                Ok data ->
                    ( { model
                        | positions = RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbSubmission res ->
            case res of
                Ok (Just data) ->
                    ( { model
                        | view = ViewApp <| ViewSubmission <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Ok Nothing ->
                    ( model
                    , goTo Start
                    )

                Err err ->
                    ( model, log err )

        CbSubmissions res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewApp <| ViewSubmissions <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTag res ->
            case res of
                Ok (Just data) ->
                    ( { model
                        | view = ViewApp <| ViewTag <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Ok Nothing ->
                    ( model
                    , goTo Start
                    )

                Err err ->
                    ( model, log err )

        CbTags res ->
            case res of
                Ok data ->
                    ( { model
                        | tags = RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTopic res ->
            case res of
                Ok (Just data) ->
                    ( { model
                        | view = ViewApp <| ViewTopic <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Ok Nothing ->
                    ( model
                    , goTo Start
                    )

                Err err ->
                    ( model, log err )

        CbTopics res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewApp <| ViewTopics <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        CbTransition res ->
            case res of
                Ok (Just data) ->
                    ( { model
                        | view = ViewApp <| ViewTransition <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Ok Nothing ->
                    ( model
                    , goTo Start
                    )

                Err err ->
                    ( model, log err )

        CbTransitions res ->
            case res of
                Ok data ->
                    ( { model
                        | view = ViewApp <| ViewTransitions <| RemoteData.Success data
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )

        ChangePasswordSubmit ->
            protect
                (\auth ->
                    if
                        String.length model.form.password
                            > 0
                            && model.form.password
                            == model.form.confirmPassword
                    then
                        ( { model | form = clearErrors model.form }
                        , mutation auth.token
                            (Api.Mutation.changePassword { password = model.form.password })
                            CbChangePassword
                        )
                    else
                        ( { model
                            | form =
                                model.form
                                    |> (\f ->
                                            { f | errors = Just [ "Lame pw effort" ] }
                                       )
                          }
                        , Cmd.none
                        )
                )

        Confirm maybeM ->
            ( { model | confirm = maybeM }, Cmd.none )

        DeletePosition id ->
            protect
                (\auth ->
                    ( model
                    , mutation auth.token
                        (Api.Mutation.deletePosition { id = id })
                        CbDeletePosition
                    )
                )

        DeleteSubmission id ->
            protect
                (\auth ->
                    ( model
                    , mutation auth.token
                        (Api.Mutation.deleteSubmission { id = id })
                        CbDeleteSubmission
                    )
                )

        DeleteTag id ->
            protect
                (\auth ->
                    ( model
                    , mutation auth.token
                        (Api.Mutation.deleteTag { id = id })
                        CbDeleteTag
                    )
                )

        DeleteTopic id ->
            protect
                (\auth ->
                    ( model
                    , mutation auth.token
                        (Api.Mutation.deleteTopic { id = id })
                        CbDeleteTopic
                    )
                )

        DeleteTransition id ->
            protect
                (\auth ->
                    ( model
                    , mutation auth.token
                        (Api.Mutation.deleteTransition { id = id })
                        CbDeleteTransition
                    )
                )

        EditPosition p ->
            let
                form =
                    { emptyForm
                        | name = p.name
                        , notes = p.notes
                        , id = p.id
                    }
            in
            ( { model
                | view = ViewApp (ViewEditPosition p)
                , form = form
              }
            , Cmd.none
            )

        EditSubmission s ->
            protect
                (\auth ->
                    let
                        form =
                            { emptyForm
                                | name = s.name
                                , steps = s.steps
                                , notes = s.notes
                                , startPosition = Just s.position
                                , id = s.id
                                , tags = s.tags |> Array.fromList
                            }
                    in
                    ( { model
                        | view = ViewApp ViewEditSubmission
                        , form = form
                      }
                    , Cmd.batch
                        [ maybeFetchPositions auth.token model.positions
                        , maybeFetchTags auth.token model.tags
                        ]
                    )
                )

        EditTag t ->
            let
                form =
                    { emptyForm
                        | name = t.name
                        , id = t.id
                    }
            in
            ( { model
                | view = ViewApp ViewEditTag
                , form = form
              }
            , Cmd.none
            )

        EditTopic t ->
            let
                form =
                    { emptyForm
                        | name = t.name
                        , notes = t.notes
                        , id = t.id
                    }
            in
            ( { model
                | view = ViewApp ViewEditTopic
                , form = form
              }
            , Cmd.none
            )

        EditTransition t ->
            protect
                (\auth ->
                    let
                        form =
                            { emptyForm
                                | name = t.name
                                , id = t.id
                                , steps = t.steps
                                , notes = t.notes
                                , startPosition = Just t.startPosition
                                , endPosition = Just t.endPosition
                            }
                    in
                    ( { model
                        | view = ViewApp ViewEditTransition
                        , form = form
                      }
                    , Cmd.batch
                        [ maybeFetchPositions auth.token model.positions
                        , maybeFetchTags auth.token model.tags
                        ]
                    )
                )

        LoginSubmit ->
            ( { model | form = model.form |> (\f -> { f | errors = Nothing }) }
            , Api.Mutation.selection identity
                |> with
                    (Api.Mutation.authenticateUser
                        { email = model.form.email
                        , password = model.form.password
                        }
                        auth
                    )
                |> Graphqelm.Http.mutationRequest "/api"
                |> Graphqelm.Http.send CbAuth
            )

        Logout ->
            ( { model | auth = Nothing }
            , Cmd.batch
                [ Ports.clearAuth ()
                , goTo Login
                ]
            )

        NavigateTo route ->
            ( model, goTo route )

        RemoveTag i ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | tags = arrayRemove i f.tags }
                           )
              }
            , Cmd.none
            )

        SaveCreatePosition ->
            protect
                (\auth ->
                    case Validate.position model.form of
                        Ok ( name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.createPosition { name = name, notes = notes } position)
                                CbCreateOrUpdatePosition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateSubmission ->
            protect
                (\auth ->
                    case Validate.submission model.form of
                        Ok ( name, startId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.createSubmission
                                    { name = name
                                    , steps = steps
                                    , notes = notes
                                    , position = startId
                                    }
                                    submission
                                )
                                CbCreateOrUpdateSubmission
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateTag ->
            protect
                (\auth ->
                    case Validate.tag model.form of
                        Ok name ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.createTag { name = name }
                                    tag
                                )
                                CbCreateOrUpdateTag
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateTopic ->
            protect
                (\auth ->
                    case Validate.topic model.form of
                        Ok ( name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.createTopic { name = name, notes = notes } topic)
                                CbCreateOrUpdateTopic
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveCreateTransition ->
            protect
                (\auth ->
                    case Validate.transition model.form of
                        Ok ( name, startId, endId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.createTransition
                                    { name = name
                                    , startPosition = startId
                                    , endPosition = endId
                                    , steps = steps
                                    , notes = notes
                                    }
                                    transition
                                )
                                CbCreateOrUpdateTransition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditPosition ->
            protect
                (\auth ->
                    case Validate.position model.form of
                        Ok ( name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.updatePosition
                                    { id = model.form.id
                                    , name = name
                                    , notes = notes
                                    }
                                    position
                                )
                                CbCreateOrUpdatePosition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditSubmission ->
            protect
                (\auth ->
                    case Validate.submission model.form of
                        Ok ( name, position, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.updateSubmission
                                    { id = model.form.id
                                    , name = name
                                    , steps = steps
                                    , notes = notes
                                    , position = position
                                    }
                                    submission
                                )
                                CbCreateOrUpdateSubmission
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditTag ->
            protect
                (\auth ->
                    case Validate.tag model.form of
                        Ok name ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.updateTag
                                    { id = model.form.id
                                    , name = name
                                    }
                                    tag
                                )
                                CbCreateOrUpdateTag
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditTopic ->
            protect
                (\auth ->
                    case Validate.topic model.form of
                        Ok ( name, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.updateTopic
                                    { id = model.form.id
                                    , name = name
                                    , notes = notes
                                    }
                                    topic
                                )
                                CbCreateOrUpdateTopic
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SaveEditTransition ->
            protect
                (\auth ->
                    case Validate.transition model.form of
                        Ok ( name, startId, endId, steps, notes ) ->
                            ( { model | form = clearErrors model.form }
                            , mutation auth.token
                                (Api.Mutation.updateTransition
                                    { id = model.form.id
                                    , name = name
                                    , startPosition = startId
                                    , endPosition = endId
                                    , steps = steps
                                    , notes = notes
                                    }
                                    transition
                                )
                                CbCreateOrUpdateTransition
                            )

                        Err errs ->
                            ( { model | form = addErrors errs model.form }
                            , Cmd.none
                            )
                )

        SetRouteThenNavigate route nextRoute ->
            ( { model | previousRoute = Just route }, goTo nextRoute )

        SidebarSignOut ->
            update Logout { model | sidebarOpen = False }

        SidebarNavigate route ->
            update (NavigateTo route) { model | sidebarOpen = False }

        SignUpSubmit ->
            ( model
            , Api.Mutation.selection identity
                |> with
                    (Api.Mutation.signUpUser
                        { email = model.form.email
                        , password = model.form.password
                        }
                        auth
                    )
                |> Graphqelm.Http.mutationRequest "/api"
                |> Graphqelm.Http.send CbAuth
            )

        ToggleEndPosition ->
            ( { model | selectingEndPosition = not model.selectingEndPosition }, Cmd.none )

        ToggleSidebar ->
            ( { model | sidebarOpen = not model.sidebarOpen }, Cmd.none )

        ToggleStartPosition ->
            ( { model | selectingStartPosition = not model.selectingStartPosition }, Cmd.none )

        UpdateForm f ->
            ( { model | form = f }, Cmd.none )

        UpdateEmail str ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | email = str }
                           )
              }
            , Cmd.none
            )

        UpdateEndPosition selection ->
            let
                form =
                    model.form |> (\f -> { f | endPosition = Just selection })
            in
            ( { model | form = form, selectingEndPosition = False }, Cmd.none )

        UpdateConfirmPassword str ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | confirmPassword = str }
                           )
              }
            , Cmd.none
            )

        UpdatePassword str ->
            ( { model
                | form =
                    model.form
                        |> (\f ->
                                { f | password = str }
                           )
              }
            , Cmd.none
            )

        UpdateStartPosition selection ->
            let
                form =
                    model.form |> (\f -> { f | startPosition = Just selection })
            in
            ( { model | form = form, selectingStartPosition = False }, Cmd.none )

        UrlChange location ->
            case router location of
                Login ->
                    case model.auth of
                        Just _ ->
                            ( model, goTo Start )

                        Nothing ->
                            ( { model | view = ViewLogin, form = emptyForm }, Cmd.none )

                SignUp ->
                    case model.auth of
                        Just _ ->
                            ( model, goTo Start )

                        Nothing ->
                            ( { model | view = ViewSignUp, form = emptyForm }, Cmd.none )

                CreatePositionRoute ->
                    ( { model
                        | view = ViewApp ViewCreatePosition
                        , form = emptyForm
                      }
                    , Cmd.none
                    )

                CreateSubmissionRoute maybeStart ->
                    protect
                        (\auth ->
                            let
                                start =
                                    model.positions
                                        |> RemoteData.toMaybe
                                        |> Maybe.map2 (,) maybeStart
                                        |> Maybe.andThen
                                            (\( p, positions ) ->
                                                positions
                                                    |> find (.id >> (==) (Id p))
                                            )
                                        |> Maybe.map
                                            (\{ id, name } ->
                                                Info id name
                                            )

                                form =
                                    { emptyForm
                                        | startPosition = start
                                    }
                            in
                            ( { model
                                | view = ViewApp ViewCreateSubmission
                                , form = form
                              }
                            , Cmd.batch
                                [ maybeFetchPositions auth.token model.positions
                                , maybeFetchTags auth.token model.tags
                                ]
                            )
                        )

                CreateTagRoute ->
                    ( { model
                        | view = ViewApp ViewCreateTag
                        , form = emptyForm
                      }
                    , Cmd.none
                    )

                CreateTopicRoute ->
                    ( { model
                        | view = ViewApp ViewCreateTopic
                        , form = emptyForm
                      }
                    , Cmd.none
                    )

                CreateTransitionRoute maybeStart _ ->
                    protect
                        (\auth ->
                            let
                                start =
                                    model.positions
                                        |> RemoteData.toMaybe
                                        |> Maybe.map2 (,) maybeStart
                                        |> Maybe.andThen
                                            (\( p, positions ) ->
                                                positions
                                                    |> find (.id >> (==) (Id p))
                                            )
                                        |> Maybe.map
                                            (\{ id, name } ->
                                                Info id name
                                            )

                                form =
                                    { emptyForm
                                        | startPosition = start
                                    }
                            in
                            ( { model
                                | view = ViewApp ViewCreateTransition
                                , form = form
                              }
                            , Cmd.batch
                                [ maybeFetchPositions auth.token model.positions
                                , maybeFetchTags auth.token model.tags
                                ]
                            )
                        )

                EditPositionRoute id ->
                    ( model, Cmd.none )

                EditSubmissionRoute _ ->
                    ( model, Cmd.none )

                EditTransitionRoute _ ->
                    ( model, Cmd.none )

                EditTagRoute _ ->
                    ( model, Cmd.none )

                EditTopicRoute _ ->
                    ( model, Cmd.none )

                NotFound ->
                    ( model
                    , Cmd.batch
                        [ log "redirecting..."
                        , goTo
                            (model.auth |> unwrap Login (always Start))
                        ]
                    )

                PositionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewPosition Loading }
                                , fetch auth.token (Api.Query.position { id = id } position) CbPosition
                                )
                            )

                Positions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp ViewPositions, positions = Loading }
                            , fetch auth.token (Api.Query.positions positionInfo) CbPositions
                            )
                        )

                SettingsRoute ->
                    ( { model | form = emptyForm, view = ViewApp ViewSettings }
                    , Cmd.none
                    )

                SubmissionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewSubmission Loading }
                                , fetch auth.token (Api.Query.submission { id = id } submission) CbSubmission
                                )
                            )

                Submissions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewSubmissions Loading }
                            , fetch auth.token (Api.Query.submissions submission) CbSubmissions
                            )
                        )

                Start ->
                    ( { model | view = ViewApp ViewStart }, Cmd.none )

                TagRoute id ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTag Loading }
                            , fetch auth.token (Api.Query.tag { id = id } tag) CbTag
                            )
                        )

                TagsRoute ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp ViewTags, tags = Loading }
                            , fetch auth.token (Api.Query.tags tagInfo) CbTags
                            )
                        )

                TopicRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewTopic Loading }
                                , fetch auth.token (Api.Query.topic { id = id } topic) CbTopic
                                )
                            )

                Topics ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTopics Loading }
                            , fetch auth.token (Api.Query.topics topicInfo) CbTopics
                            )
                        )

                TransitionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewTransition Loading }
                                , fetch auth.token (Api.Query.transition { id = id } transition) CbTransition
                                )
                            )

                Transitions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTransitions Loading }
                            , fetch auth.token (Api.Query.transitions transition) CbTransitions
                            )
                        )

        WindowSize size ->
            ( { model
                | device = size |> Utils.classifyDevice
                , size = size
              }
            , Cmd.none
            )


saveAuth : Auth -> Cmd msg
saveAuth auth =
    [ ( "id", Encode.string (auth.id |> (\(Id id) -> id)) )
    , ( "token", Encode.string auth.token )
    , ( "email", Encode.string auth.email )
    ]
        |> Encode.object
        |> Ports.saveAuth


maybeFetchTags : String -> RemoteData.WebData a -> Cmd Msg
maybeFetchTags token data =
    if
        case data of
            RemoteData.NotAsked ->
                True

            RemoteData.Failure _ ->
                True

            RemoteData.Loading ->
                False

            RemoteData.Success _ ->
                False
    then
        fetch token (Api.Query.tags tagInfo) CbTags
    else
        Cmd.none


maybeFetchPositions : String -> RemoteData.WebData a -> Cmd Msg
maybeFetchPositions token data =
    if
        case data of
            RemoteData.NotAsked ->
                True

            RemoteData.Failure _ ->
                True

            RemoteData.Loading ->
                False

            RemoteData.Success _ ->
                False
    then
        fetch token (Api.Query.positions positionInfo) CbPositions
    else
        Cmd.none


dataIsLoaded : View -> Id -> Bool
dataIsLoaded view id =
    case view of
        ViewApp (ViewPosition (Success d)) ->
            id == d.id

        ViewApp (ViewSubmission (Success d)) ->
            id == d.id

        ViewApp (ViewTopic (Success d)) ->
            id == d.id

        ViewApp (ViewTransition (Success d)) ->
            id == d.id

        _ ->
            False
