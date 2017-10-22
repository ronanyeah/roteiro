module Main exposing (main)

import Color exposing (black)
import Dict exposing (Dict)
import Element exposing (Element, column, el, empty, row, text, viewport, when)
import Element.Attributes exposing (center, fill, height, padding, px, spacing, width)
import Element.Events exposing (onClick)
import GraphQL.Client.Http as GQLH
import GraphQL.Request.Builder as GQLB
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Style exposing (StyleSheet, style, styleSheet)
import Style.Border as Border
import Style.Font as Font
import Style.Color as Color
import Task exposing (Task)


type Id
    = Id String


type Msg
    = SelectPosition Position
    | SelectSubmission Submission
    | SelectTransition Transition
    | SelectNotes
    | Reset
    | CbData (Result GQLH.Error AllData)


type Styles
    = None
    | SetBox
    | Body
    | Button
    | Link
    | Line


type TechType
    = Sub
    | Sweep String


type alias Topic =
    { name : String
    , content : List String
    }


type alias Position =
    { id : Id
    , name : String
    , notes : List String
    }


type alias Submission =
    { id : Id
    , name : String
    , steps : List String
    , notes : List String
    , position : Id
    }


type alias Model =
    { view : View
    , positions : Dict String Position
    , transitions : Dict String Transition
    , submissions : Dict String Submission
    , topics : List Topic
    }


type alias Transition =
    { id : Id
    , name : String
    , startPosition : Id
    , endPosition : Id
    , notes : List String
    , steps : List String
    }


type alias AllData =
    { transitions : List Transition
    , positions : List Position
    , submissions : List Submission
    , topics : List Topic
    }


type View
    = ViewAll
    | ViewPosition Position
    | ViewSubmission Submission
    | ViewTransition Transition
    | ViewNotes


styling : StyleSheet Styles vs
styling =
    let
        pointer =
            Style.cursor "pointer"
    in
        styleSheet
            [ style None []
            , style SetBox
                [ Border.all 2
                , Border.solid
                ]
            , style Button
                [ Border.all 2
                , Border.solid
                , Border.rounded 15
                , pointer
                ]
            , style Body [ Font.typeface [ Font.font "Cuprum", Font.sansSerif ], Font.size 25 ]
            , style Link [ Font.underline, pointer ]
            , style Line [ Color.background black ]
            ]


emptyModel : Model
emptyModel =
    Model ViewAll Dict.empty Dict.empty Dict.empty []


init : String -> ( Model, Cmd Msg )
init url =
    ( emptyModel, Task.attempt CbData (GQLH.sendQuery url fetchData) )


main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewAll ->
                    model.positions
                        |> Dict.values
                        |> List.map viewPosition
                        |> flip (++)
                            [ el Line [ width <| px 100, height <| px 2 ] empty
                            , el Button
                                [ padding 10
                                , onClick <| SelectNotes
                                ]
                              <|
                                text "Notes"
                            ]

                ViewPosition { id, name, notes } ->
                    let
                        transitions =
                            model.transitions
                                |> Dict.values
                                |> List.filter (.startPosition >> (==) id)

                        submissions =
                            model.submissions
                                |> Dict.values
                                |> List.filter (.position >> (==) id)
                    in
                        [ resetButton
                        , el None [] <| text name
                        , when (not <| List.isEmpty notes) <|
                            column None
                                []
                                [ el None [ center ] <| text "Tips:"
                                , column None [] <| List.map ((++) "- " >> text) notes
                                ]
                        , viewTechList "Sweeps:" transitions
                        , viewTechList "Subs:" submissions
                        ]

                ViewSubmission { name, steps, position, notes } ->
                    get position model.positions
                        |> unwrap oopsView
                            (\p ->
                                [ resetButton
                                , row None
                                    []
                                    [ text (name ++ " from ")
                                    , el Link [ onClick <| SelectPosition p ] <| text p.name
                                    ]
                                , column None [] <|
                                    List.indexedMap
                                        (\i step ->
                                            row None
                                                []
                                                [ Element.bold <| (toString (i + 1) ++ ".")
                                                , text <| " " ++ step
                                                ]
                                        )
                                        steps
                                ]
                            )

                ViewTransition { name, steps, startPosition, endPosition, notes } ->
                    unwrap2 oopsView
                        (get startPosition model.positions)
                        (get endPosition model.positions)
                        (\start end ->
                            [ resetButton
                            , row None
                                []
                                [ text (name ++ " from ")
                                , el Link [ onClick <| SelectPosition start ] <| text start.name
                                ]
                            , column None [] <|
                                List.indexedMap
                                    (\i step ->
                                        row None
                                            []
                                            [ Element.bold <| (toString (i + 1) ++ ".")
                                            , text <| " " ++ step
                                            ]
                                    )
                                    steps
                            , row None
                                []
                                [ text "Transitions to: "
                                , el Link [ onClick <| SelectPosition end ] <|
                                    text end.name
                                ]
                            ]
                        )

                ViewNotes ->
                    model.topics
                        |> List.map viewTopic
                        |> (::) resetButton
    in
        viewport styling <|
            column Body [ center, width fill, spacing 30, padding 15 ] content


resetButton : Element Styles vs Msg
resetButton =
    el Button [ padding 10, onClick Reset ] <| text "Positions"


oopsView : List (Element Styles vs Msg)
oopsView =
    [ resetButton, text "oops!" ]


get : Id -> Dict String { r | id : Id } -> Maybe { r | id : Id }
get (Id id) =
    Dict.get id


viewTopic : Topic -> Element Styles vs Msg
viewTopic { name, content } =
    when (List.length content |> flip (>) 0) <|
        column None
            [ center ]
            [ el None [] <| text name
            , column None [] <| List.map ((++) "- " >> text) content
            ]


viewList : ( String, List String ) -> Element Styles vs Msg
viewList ( title, notes ) =
    when (List.length notes |> flip (>) 0) <|
        column None
            [ center ]
            [ el None [] <| text title
            , column None [] <| List.map ((++) "- " >> text) notes
            ]


viewTechList : String -> List { r | id : Id, name : String } -> Element Styles vs Msg
viewTechList title techs =
    when (List.length techs |> flip (>) 0) <|
        column None
            []
            [ el None [] <| text title
            , column None [] <|
                List.map viewTechLink techs
            ]


viewTechLink : { r | id : Id, name : String } -> Element Styles vs Msg
viewTechLink { id, name } =
    row None [] [ text "- ", el Link [] <| text name ]


viewPosition : Position -> Element Styles vs Msg
viewPosition ({ name, id } as r) =
    el Button
        [ padding 10
        , onClick <| SelectPosition r
        ]
    <|
        text name



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectPosition p ->
            ( { model | view = ViewPosition p }, Cmd.none )

        SelectSubmission s ->
            ( { model | view = ViewSubmission s }, Cmd.none )

        SelectTransition t ->
            ( { model | view = ViewTransition t }, Cmd.none )

        SelectNotes ->
            ( { model | view = ViewNotes }, Cmd.none )

        Reset ->
            ( { model | view = ViewAll }, Cmd.none )

        CbData res ->
            case res of
                Ok { transitions, positions, submissions, topics } ->
                    ( { model
                        | transitions = listToDict transitions
                        , positions = listToDict positions
                        , submissions = listToDict submissions
                        , topics = topics
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log err )


unwrap : b -> (a -> b) -> Maybe a -> b
unwrap default fn =
    Maybe.map fn
        >> Maybe.withDefault default


unwrap2 : c -> Maybe a -> Maybe b -> (a -> b -> c) -> c
unwrap2 c maybeA maybeB fn =
    Maybe.map2 fn maybeA maybeB
        |> Maybe.withDefault c


log : a -> Cmd Msg
log a =
    let
        _ =
            Debug.log "Log" a
    in
        Cmd.none



-- HELPERS


listToDict : List { r | id : Id } -> Dict String { r | id : Id }
listToDict =
    List.foldl
        (\r ->
            let
                (Id id) =
                    r.id
            in
                Dict.insert id r
        )
        Dict.empty



-- API


fetchData : GQLB.Request GQLB.Query AllData
fetchData =
    (GQLB.object AllData
        |> GQLB.with (GQLB.field "allTransitions" [] (GQLB.list transition))
        |> GQLB.with (GQLB.field "allPositions" [] (GQLB.list position))
        |> GQLB.with (GQLB.field "allSubmissions" [] (GQLB.list submission))
        |> GQLB.with (GQLB.field "allTopics" [] (GQLB.list topic))
    )
        |> GQLB.queryDocument
        |> GQLB.request ()


fetchTransitions : GQLB.Request GQLB.Query (List Transition)
fetchTransitions =
    GQLB.list transition
        |> GQLB.field "allTransitions" []
        |> GQLB.extract
        |> GQLB.queryDocument
        |> GQLB.request ()


topic : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Topic vars
topic =
    GQLB.object Topic
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "content" [] (GQLB.list GQLB.string))


position : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Position vars
position =
    GQLB.object Position
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string))


submission : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Submission vars
submission =
    GQLB.object Submission
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string))
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string))
        |> GQLB.with
            (GQLB.field "position"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )


transition : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Transition vars
transition =
    GQLB.object Transition
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with
            (GQLB.field "startPosition"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )
        |> GQLB.with
            (GQLB.field "endPosition"
                []
                (GQLB.field "id" [] (GQLB.map Id GQLB.id) |> GQLB.extract)
            )
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string))
        |> GQLB.with (GQLB.field "steps" [] (GQLB.list GQLB.string))
