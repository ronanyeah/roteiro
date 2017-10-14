module Main exposing (main)

import Element exposing (Element, column, el, html, row, text, viewport)
import Element.Attributes exposing (center, fill, height, padding, paddingBottom, px, spacing, width)
import Element.Events exposing (onClick)
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import List.Extra exposing (greedyGroupsOf)
import Style exposing (StyleSheet, style, styleSheet, variation)
import Style.Border as Border


type Msg
    = SelectSet Set


type Styles
    = None
    | SetBox


type Var
    = Top
    | Bottom


type Tech
    = Tech String (List String)


type Position
    = HalfGuard Var


type Set
    = Set Position (List String) (List Tech)


type alias Model =
    { techs : List Set
    , view : View
    }


type View
    = ViewAll
    | ViewSet Set
    | ViewTech Tech


styling : StyleSheet Styles vs
styling =
    styleSheet
        [ style None []
        , style SetBox
            [ Border.all 2
            , Border.solid
            ]
        ]


emptyModel : Model
emptyModel =
    Model [] ViewAll


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init =
            \json ->
                case Decode.decodeValue (Decode.list decodeSet) json of
                    Ok data ->
                        ( { emptyModel | techs = data }, Cmd.none )

                    Err err ->
                        ( emptyModel, log err )
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


decodeTech : Decoder Tech
decodeTech =
    Decode.map2 Tech
        (Decode.field "name" Decode.string)
        (Decode.field "steps" <| Decode.list Decode.string)


decodeSet : Decoder Set
decodeSet =
    Decode.field "position" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "halfGuardBottom" ->
                        Decode.map2 (Set (HalfGuard Bottom))
                            (Decode.field "tips" (Decode.list Decode.string))
                            (Decode.field "techs" (Decode.list decodeTech))

                    "halfGuardTop" ->
                        Decode.map2 (Set (HalfGuard Top))
                            (Decode.field "tips" (Decode.list Decode.string))
                            (Decode.field "techs" (Decode.list decodeTech))

                    _ ->
                        Decode.fail "uh oh"
            )


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewAll ->
                    model.techs
                        |> List.map viewSet
                        |> greedyGroupsOf 3
                        |> List.map (row None [ center, spacing 5, padding 5, width fill ])
                        |> column None [ center, width fill ]

                ViewSet (Set position _ _) ->
                    text <| toString position

                _ ->
                    text "err"
    in
        viewport styling <|
            content


viewSet : Set -> Element Styles vs Msg
viewSet ((Set position _ _) as s) =
    el SetBox
        [ padding 5
        , height <| px 100
        , onClick <| SelectSet s
        ]
    <|
        text <|
            toString position



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectSet set ->
            ( { model | view = ViewSet set }, Cmd.none )


log : a -> Cmd Msg
log a =
    let
        _ =
            Debug.log "Log" a
    in
        Cmd.none
