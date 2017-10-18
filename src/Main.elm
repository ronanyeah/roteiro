module Main exposing (main)

import Color exposing (black)
import Dict exposing (Dict)
import Element exposing (Element, column, el, empty, row, text, viewport, when)
import Element.Attributes exposing (center, fill, height, padding, px, spacing, width)
import Element.Events exposing (onClick)
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Style exposing (StyleSheet, style, styleSheet)
import Style.Border as Border
import Style.Font as Font
import Style.Color as Color


type Msg
    = SelectPosition String
    | SelectTech String
    | SelectNotes
    | Reset


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
    { id : String
    , name : String
    , tips : List String
    }


type alias Model =
    { view : View
    , positions : Dict String Position
    , techs : Dict String Tech
    , notes : Dict String (List String)
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
    Model ViewAll Dict.empty Dict.empty Dict.empty


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init =
            \json ->
                case Decode.decodeValue decodeModel json of
                    Ok model ->
                        ( model, Cmd.none )

                    Err err ->
                        ( emptyModel, log err )
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

                ViewPosition { id, name, tips } ->
                    let
                        ( subs, sweeps ) =
                            model.techs
                                |> Dict.values
                                |> List.filter (.position >> (==) id)
                                |> List.partition (.techType >> (==) Sub)
                    in
                        [ resetButton
                        , el None [] <| text name
                        , when (not <| List.isEmpty tips) <|
                            column None
                                []
                                [ el None [ center ] <| text "Tips:"
                                , column None [] <| List.map ((++) "- " >> text) tips
                                ]
                        , viewTechList "Sweeps:" sweeps
                        , viewTechList "Subs:" subs
                        ]

                ViewTech { name, steps, position, techType } ->
                    let
                        positionName =
                            Dict.get position model.positions
                                |> unwrap "???" .name

                        transition =
                            case techType of
                                Sweep id ->
                                    let
                                        nameOfTransition =
                                            Dict.get id model.positions
                                                |> unwrap "???" .name
                                    in
                                        row None
                                            []
                                            [ text "Transitions to: "
                                            , el Link [ onClick <| SelectPosition id ] <|
                                                text nameOfTransition
                                            ]

                                Sub ->
                                    empty
                    in
                        [ resetButton
                        , row None
                            []
                            [ text (name ++ " from ")
                            , el Link [ onClick <| SelectPosition position ] <| text positionName
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
                        , transition
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
        SelectPosition id ->
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



-- DECODERS


decodeModel : Decoder Model
decodeModel =
    let
        listToDict : List { r | id : String } -> Dict String { r | id : String }
        listToDict =
            List.foldl (\r -> Dict.insert r.id r) Dict.empty
    in
        Decode.map3 (Model ViewAll)
            (Decode.field "positions" (Decode.list decodePosition |> Decode.map listToDict))
            (Decode.field "techs" (Decode.list decodeTech |> Decode.map listToDict))
            (Decode.field "notes" (Decode.dict (Decode.list Decode.string)))


decodePosition : Decoder Position
decodePosition =
    Decode.map3 Position
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "tips" (Decode.list Decode.string))


decodeTech : Decoder Tech
decodeTech =
    Decode.map5 Tech
        (Decode.field "sweep-to" decodeTechType)
        (Decode.field "id" Decode.string)
        (Decode.field "position" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "steps" (Decode.list Decode.string))


decodeTechType : Decoder TechType
decodeTechType =
    Decode.nullable Decode.string
        |> Decode.andThen
            (\sweep ->
                case sweep of
                    Just id ->
                        Decode.succeed <| Sweep id

                    Nothing ->
                        Decode.succeed <| Sub
            )
