module Update exposing (..)

import Api
import Api.Mutation
import Api.Query
import Api.Scalar exposing (Id(..))
import Array
import Json.Encode as Encode
import List.Nonempty as Ne
import Navigation
import Ports
import RemoteData exposing (RemoteData(..))
import Router exposing (router)
import Types exposing (..)
import Utils exposing (addErrors, arrayRemove, clearErrors, emptyForm, formatErrors, goTo, log, setWaiting, unwrap)
import Validate


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
                    ( { model | previousRoute = Nothing }
                    , model.previousRoute
                        |> Maybe.withDefault Positions
                        |> goTo
                    )

                ViewApp ViewCreateSubmission ->
                    ( { model | previousRoute = Nothing }
                    , model.previousRoute
                        |> Maybe.withDefault Submissions
                        |> goTo
                    )

                ViewApp ViewCreateTag ->
                    ( { model | previousRoute = Nothing }
                    , model.previousRoute
                        |> Maybe.withDefault TagsRoute
                        |> goTo
                    )

                ViewApp ViewCreateTopic ->
                    ( { model | previousRoute = Nothing }
                    , model.previousRoute
                        |> Maybe.withDefault Topics
                        |> goTo
                    )

                ViewApp ViewCreateTransition ->
                    ( { model | previousRoute = Nothing }
                    , model.previousRoute
                        |> Maybe.withDefault Transitions
                        |> goTo
                    )

                ViewApp (ViewEditPosition p) ->
                    ( { model | confirm = Nothing, view = ViewApp (ViewPosition (Success p)) }
                    , goTo <| PositionRoute p.id
                    )

                ViewApp (ViewEditSubmission s) ->
                    ( { model | confirm = Nothing, view = ViewApp (ViewSubmission (Success s)) }
                    , goTo <| SubmissionRoute s.id
                    )

                ViewApp (ViewEditTag t) ->
                    ( { model | confirm = Nothing, view = ViewApp (ViewTag (Success t)) }
                    , goTo <| TagRoute t.id
                    )

                ViewApp (ViewEditTopic t) ->
                    ( { model | confirm = Nothing, view = ViewApp (ViewTopic (Success t)) }
                    , goTo <| TopicRoute t.id
                    )

                ViewApp (ViewEditTransition t) ->
                    ( { model | confirm = Nothing, view = ViewApp (ViewTransition (Success t)) }
                    , goTo <| TransitionRoute t.id
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
                        , Api.mutation
                            model.apiUrl
                            auth.token
                            (Api.Mutation.changePassword { password = model.form.password })
                            CbChangePassword
                        )
                    else
                        ( { model
                            | form =
                                model.form
                                    |> (\f ->
                                            { f
                                                | status =
                                                    "Lame pw effort"
                                                        |> Ne.fromElement
                                                        |> Errors
                                            }
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
                    ( { model | form = setWaiting model.form }
                    , Api.mutation
                        model.apiUrl
                        auth.token
                        (Api.Mutation.deletePosition { id = id })
                        CbDeletePosition
                    )
                )

        DeleteSubmission id ->
            protect
                (\auth ->
                    ( { model | form = setWaiting model.form }
                    , Api.mutation
                        model.apiUrl
                        auth.token
                        (Api.Mutation.deleteSubmission { id = id })
                        CbDeleteSubmission
                    )
                )

        DeleteTag id ->
            protect
                (\auth ->
                    ( { model | form = setWaiting model.form }
                    , Api.mutation
                        model.apiUrl
                        auth.token
                        (Api.Mutation.deleteTag { id = id })
                        CbDeleteTag
                    )
                )

        DeleteTopic id ->
            protect
                (\auth ->
                    ( { model | form = setWaiting model.form }
                    , Api.mutation
                        model.apiUrl
                        auth.token
                        (Api.Mutation.deleteTopic { id = id })
                        CbDeleteTopic
                    )
                )

        DeleteTransition id ->
            protect
                (\auth ->
                    ( { model | form = setWaiting model.form }
                    , Api.mutation
                        model.apiUrl
                        auth.token
                        (Api.Mutation.deleteTransition { id = id })
                        CbDeleteTransition
                    )
                )

        LoginSubmit ->
            ( { model | form = setWaiting model.form }
            , Api.login model.apiUrl model.form
            )

        Logout ->
            ( { model | auth = Nothing, sidebarOpen = False, confirm = Nothing }
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
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.createPosition
                                    { name = name
                                    , notes = notes
                                    }
                                    Api.position
                                )
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
                        Ok ( name, startId, steps, notes, tags ) ->
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.createSubmission
                                    { name = name
                                    , steps = steps
                                    , notes = notes
                                    , position = startId
                                    , tags = tags
                                    }
                                    Api.submission
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
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.createTag { name = name }
                                    Api.tag
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
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.createTopic
                                    { name = name
                                    , notes = notes
                                    }
                                    Api.topic
                                )
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
                        Ok ( name, startId, endId, steps, notes, tags ) ->
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.createTransition
                                    { name = name
                                    , startPosition = startId
                                    , endPosition = endId
                                    , steps = steps
                                    , notes = notes
                                    , tags = tags
                                    }
                                    Api.transition
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
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.updatePosition
                                    { id = model.form.id
                                    , name = name
                                    , notes = notes
                                    }
                                    Api.position
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
                        Ok ( name, position, steps, notes, tags ) ->
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.updateSubmission
                                    { id = model.form.id
                                    , name = name
                                    , steps = steps
                                    , notes = notes
                                    , position = position
                                    , tags = tags
                                    }
                                    Api.submission
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
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.updateTag
                                    { id = model.form.id
                                    , name = name
                                    }
                                    Api.tag
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
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.updateTopic
                                    { id = model.form.id
                                    , name = name
                                    , notes = notes
                                    }
                                    Api.topic
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
                        Ok ( name, startId, endId, steps, notes, tags ) ->
                            ( { model | form = setWaiting model.form }
                            , Api.mutation
                                model.apiUrl
                                auth.token
                                (Api.Mutation.updateTransition
                                    { id = model.form.id
                                    , name = name
                                    , startPosition = startId
                                    , endPosition = endId
                                    , steps = steps
                                    , notes = notes
                                    , tags = tags
                                    }
                                    Api.transition
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
            ( { model | form = setWaiting model.form }
            , Api.signUp model.apiUrl model.form
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

                CreateSubmissionRoute ->
                    protect
                        (\auth ->
                            let
                                start =
                                    case model.view of
                                        ViewApp (ViewPosition (Success { id, name })) ->
                                            Just <| Info id name

                                        _ ->
                                            Nothing

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
                                [ maybeFetchPositions model.apiUrl auth.token model.positions
                                , maybeFetchTags model.apiUrl auth.token model.tags
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

                CreateTransitionRoute ->
                    protect
                        (\auth ->
                            let
                                start =
                                    case model.view of
                                        ViewApp (ViewPosition (Success { id, name })) ->
                                            Just <| Info id name

                                        _ ->
                                            Nothing

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
                                [ maybeFetchPositions model.apiUrl auth.token model.positions
                                , maybeFetchTags model.apiUrl auth.token model.tags
                                ]
                            )
                        )

                EditPositionRoute id ->
                    (case model.view of
                        ViewApp (ViewPosition (Success x)) ->
                            if x.id == id then
                                Just x
                            else
                                Nothing

                        _ ->
                            Nothing
                    )
                        |> unwrap ( model, goTo <| PositionRoute id )
                            (\x ->
                                ( { model
                                    | view = ViewApp (ViewEditPosition x)
                                    , form =
                                        { emptyForm
                                            | name = x.name
                                            , notes = x.notes
                                            , id = x.id
                                        }
                                  }
                                , Cmd.none
                                )
                            )

                EditSubmissionRoute id ->
                    protect
                        (\auth ->
                            (case model.view of
                                ViewApp (ViewSubmission (Success x)) ->
                                    if x.id == id then
                                        Just x
                                    else
                                        Nothing

                                _ ->
                                    Nothing
                            )
                                |> unwrap ( model, goTo <| SubmissionRoute id )
                                    (\x ->
                                        ( { model
                                            | view = ViewApp (ViewEditSubmission x)
                                            , form =
                                                { emptyForm
                                                    | name = x.name
                                                    , steps = x.steps
                                                    , notes = x.notes
                                                    , startPosition = Just x.position
                                                    , id = x.id
                                                    , tags = x.tags |> Array.fromList
                                                }
                                          }
                                        , Cmd.batch
                                            [ maybeFetchPositions model.apiUrl auth.token model.positions
                                            , maybeFetchTags model.apiUrl auth.token model.tags
                                            ]
                                        )
                                    )
                        )

                EditTransitionRoute id ->
                    protect
                        (\auth ->
                            (case model.view of
                                ViewApp (ViewTransition (Success x)) ->
                                    if x.id == id then
                                        Just x
                                    else
                                        Nothing

                                _ ->
                                    Nothing
                            )
                                |> unwrap ( model, goTo <| TransitionRoute id )
                                    (\x ->
                                        ( { model
                                            | view = ViewApp (ViewEditTransition x)
                                            , form =
                                                { emptyForm
                                                    | name = x.name
                                                    , id = x.id
                                                    , steps = x.steps
                                                    , notes = x.notes
                                                    , startPosition = Just x.startPosition
                                                    , endPosition = Just x.endPosition
                                                    , tags = x.tags |> Array.fromList
                                                }
                                          }
                                        , Cmd.batch
                                            [ maybeFetchPositions model.apiUrl auth.token model.positions
                                            , maybeFetchTags model.apiUrl auth.token model.tags
                                            ]
                                        )
                                    )
                        )

                EditTagRoute id ->
                    (case model.view of
                        ViewApp (ViewTag (Success x)) ->
                            if x.id == id then
                                Just x
                            else
                                Nothing

                        _ ->
                            Nothing
                    )
                        |> unwrap ( model, goTo <| TagRoute id )
                            (\x ->
                                ( { model
                                    | view = ViewApp (ViewEditTag x)
                                    , form =
                                        { emptyForm
                                            | name = x.name
                                            , id = x.id
                                        }
                                  }
                                , Cmd.none
                                )
                            )

                EditTopicRoute id ->
                    (case model.view of
                        ViewApp (ViewTopic (Success x)) ->
                            if x.id == id then
                                Just x
                            else
                                Nothing

                        _ ->
                            Nothing
                    )
                        |> unwrap ( model, goTo <| TopicRoute id )
                            (\x ->
                                ( { model
                                    | view = ViewApp (ViewEditTopic x)
                                    , form =
                                        { emptyForm
                                            | name = x.name
                                            , id = x.id
                                            , notes = x.notes
                                        }
                                  }
                                , Cmd.none
                                )
                            )

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
                                (case model.view of
                                    ViewApp (ViewEditPosition position) ->
                                        if position.id == id then
                                            Just position
                                        else
                                            Nothing

                                    _ ->
                                        Nothing
                                )
                                    |> unwrap
                                        ( { model | view = ViewApp <| ViewPosition Loading }
                                        , Api.fetch model.apiUrl auth.token (Api.Query.position { id = id } Api.position) CbPosition
                                        )
                                        (\p ->
                                            ( { model | view = ViewApp <| ViewPosition <| Success p }
                                            , Cmd.none
                                            )
                                        )
                            )

                Positions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp ViewPositions, positions = Loading }
                            , Api.fetch model.apiUrl auth.token (Api.Query.positions Api.positionInfo) CbPositions
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
                                , Api.fetch model.apiUrl auth.token (Api.Query.submission { id = id } Api.submission) CbSubmission
                                )
                            )

                Submissions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewSubmissions Loading }
                            , Api.fetch model.apiUrl auth.token (Api.Query.submissions Api.submission) CbSubmissions
                            )
                        )

                Start ->
                    ( { model | view = ViewApp ViewStart }, Cmd.none )

                TagRoute id ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTag Loading }
                            , Api.fetch model.apiUrl auth.token (Api.Query.tag { id = id } Api.tag) CbTag
                            )
                        )

                TagsRoute ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp ViewTags, tags = Loading }
                            , Api.fetch model.apiUrl auth.token (Api.Query.tags Api.tagInfo) CbTags
                            )
                        )

                TopicRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewTopic Loading }
                                , Api.fetch model.apiUrl auth.token (Api.Query.topic { id = id } Api.topic) CbTopic
                                )
                            )

                Topics ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTopics Loading }
                            , Api.fetch model.apiUrl auth.token (Api.Query.topics Api.topicInfo) CbTopics
                            )
                        )

                TransitionRoute id ->
                    if dataIsLoaded model.view id then
                        doNothing
                    else
                        protect
                            (\auth ->
                                ( { model | view = ViewApp <| ViewTransition Loading }
                                , Api.fetch model.apiUrl auth.token (Api.Query.transition { id = id } Api.transition) CbTransition
                                )
                            )

                Transitions ->
                    protect
                        (\auth ->
                            ( { model | view = ViewApp <| ViewTransitions Loading }
                            , Api.fetch model.apiUrl auth.token (Api.Query.transitions Api.transition) CbTransitions
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
    , ( "token"
      , case auth.token of
            Token token ->
                Encode.string token
      )
    , ( "email", Encode.string auth.email )
    ]
        |> Encode.object
        |> Encode.encode 0
        |> Ports.saveAuth


maybeFetchTags : Url -> Token -> RemoteData.WebData a -> Cmd Msg
maybeFetchTags apiUrl token data =
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
        Api.fetch apiUrl token (Api.Query.tags Api.tagInfo) CbTags
    else
        Cmd.none


maybeFetchPositions : Url -> Token -> RemoteData.WebData a -> Cmd Msg
maybeFetchPositions apiUrl token data =
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
        Api.fetch apiUrl token (Api.Query.positions Api.positionInfo) CbPositions
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
