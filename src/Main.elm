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
    = SelectPosition Id
    | SelectTech String
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


type alias Tech =
    { techType : TechType
    , id : String
    , position : String
    , name : String
    , steps : List String
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
    , techs : Dict String Tech
    , notes : Dict String (List String)
    , transitions : Dict String Transition
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

    --, submissions : List Submission
    }


type View
    = ViewAll
    | ViewPosition Position
    | ViewTech Tech
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
    Model ViewAll Dict.empty Dict.empty Dict.empty Dict.empty


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
        resetButton =
            el Button [ padding 10, onClick Reset ] <| text "Positions"

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
                        ( subs, sweeps ) =
                            model.techs
                                |> Dict.values
                                --|> List.filter (.position >> (==) id)
                                |> List.partition (.techType >> (==) Sub)
                    in
                        [ resetButton
                        , el None [] <| text name
                        , when (not <| List.isEmpty notes) <|
                            column None
                                []
                                [ el None [ center ] <| text "Tips:"
                                , column None [] <| List.map ((++) "- " >> text) notes
                                ]
                        , viewTechList "Sweeps:" sweeps
                        , viewTechList "Subs:" subs
                        ]

                ViewTech { name, steps, position, techType } ->
                    let
                        positionName =
                            Dict.get position model.positions
                                |> unwrap "???" .name

                        --transition =
                        --case techType of
                        --Sweep id ->
                        --let
                        --nameOfTransition =
                        --Dict.get id model.positions
                        --|> unwrap "???" .name
                        --in
                        --row None
                        --[]
                        --[ text "Transitions to: "
                        --, el Link [ onClick <| SelectPosition id ] <|
                        --text nameOfTransition
                        --]
                        --Sub ->
                        --empty
                    in
                        [ resetButton
                        , row None
                            []
                            [ text (name ++ " from ")

                            --, el Link [ onClick <| SelectPosition position ] <| text positionName
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

                        --, transition
                        ]

                ViewNotes ->
                    model.notes
                        |> Dict.toList
                        |> List.map viewList
                        |> (::) resetButton
    in
        viewport styling <|
            column Body [ center, width fill, spacing 30, padding 15 ] content


viewList : ( String, List String ) -> Element Styles vs Msg
viewList ( title, notes ) =
    when (List.length notes |> flip (>) 0) <|
        column None
            [ center ]
            [ el None [] <| text title
            , column None [] <| List.map ((++) "- " >> text) notes
            ]


viewTechList : String -> List Tech -> Element Styles vs Msg
viewTechList title techs =
    when (List.length techs |> flip (>) 0) <|
        column None
            []
            [ el None [] <| text title
            , column None [] <|
                List.map viewTechLink techs
            ]


viewTechLink : Tech -> Element Styles vs Msg
viewTechLink tech =
    row None [] [ text "- ", el Link [ onClick <| SelectTech tech.id ] <| text tech.name ]


viewPosition : Position -> Element Styles vs Msg
viewPosition { name, id } =
    el Button
        [ padding 10
        , onClick <| SelectPosition id
        ]
    <|
        text name



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectPosition (Id id) ->
            let
                view =
                    Dict.get id model.positions
                        |> unwrap ViewAll ViewPosition
            in
                ( { model | view = view }, Cmd.none )

        SelectTech id ->
            let
                view =
                    Dict.get id model.techs
                        |> unwrap ViewAll ViewTech
            in
                ( { model | view = view }, Cmd.none )

        SelectNotes ->
            ( { model | view = ViewNotes }, Cmd.none )

        Reset ->
            ( { model | view = ViewAll }, Cmd.none )

        CbData res ->
            case res of
                Ok { transitions, positions } ->
                    ( { model | transitions = listToDict transitions, positions = listToDict positions }, Cmd.none )

                Err err ->
                    ( model, log err )


unwrap : b -> (a -> b) -> Maybe a -> b
unwrap default fn =
    Maybe.map fn
        >> Maybe.withDefault default


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


position : GQLB.ValueSpec GQLB.NonNull GQLB.ObjectType Position vars
position =
    GQLB.object Position
        |> GQLB.with (GQLB.field "id" [] (GQLB.map Id GQLB.id))
        |> GQLB.with (GQLB.field "name" [] GQLB.string)
        |> GQLB.with (GQLB.field "notes" [] (GQLB.list GQLB.string))


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
