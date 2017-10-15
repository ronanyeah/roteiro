module Main exposing (main)

import Dict exposing (Dict)
import Element exposing (Element, column, el, html, row, text, viewport)
import Element.Attributes exposing (center, fill, height, padding, paddingBottom, px, spacing, width)
import Element.Events exposing (onClick)
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import List.Extra exposing (greedyGroupsOf)
import Style exposing (StyleSheet, style, styleSheet, variation)
import Style.Border as Border


type Msg
    = SelectPosition String
    | SelectTech String


type Styles
    = None
    | SetBox


type Var
    = Top
    | Bottom


type alias Tech =
    { var : Var
    , id : String
    , position : String
    , name : String
    , steps : List String
    }


type alias Position =
    { id : String
    , name : String
    , attack : List String
    , defence : List String
    }


type alias Model =
    { view : View
    , positions : Dict String Position
    , techs : Dict String Tech
    }


type View
    = ViewAll
    | ViewPosition Position
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
    Model ViewAll Dict.empty Dict.empty


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


decodeModel : Decoder Model
decodeModel =
    Decode.map2 (Model ViewAll)
        (Decode.field "positions" (Decode.dict decodePosition))
        (Decode.field "techs" (Decode.dict decodeTech))


decodePosition : Decoder Position
decodePosition =
    Decode.map4 Position
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "attack" (Decode.list Decode.string))
        (Decode.field "defence" (Decode.list Decode.string))


decodeTech : Decoder Tech
decodeTech =
    Decode.field "top" Decode.bool
        |> Decode.andThen
            (\top ->
                let
                    var =
                        if top then
                            Top
                        else
                            Bottom
                in
                    Decode.map4 (Tech var)
                        (Decode.field "id" Decode.string)
                        (Decode.field "position" Decode.string)
                        (Decode.field "name" Decode.string)
                        (Decode.field "steps" (Decode.list Decode.string))
            )


view : Model -> Html Msg
view model =
    let
        content =
            case model.view of
                ViewAll ->
                    model.positions
                        |> Dict.values
                        |> List.map viewPosition
                        |> greedyGroupsOf 3
                        |> List.map (row None [ center, spacing 5, padding 5, width fill ])
                        |> column None [ center, width fill ]

                ViewPosition { id, name, attack, defence } ->
                    let
                        techs =
                            model.techs
                                |> Dict.values
                                |> List.filter
                                    (.id >> (==) id)
                    in
                        column None
                            [ center, width fill ]
                            [ el None [] <| text name
                            , column None [] <| List.map text attack
                            , column None [] <| List.map text defence
                            , column None [] <|
                                List.map
                                    (\tech ->
                                        el None [ onClick <| SelectTech tech.id ] <| text tech.name
                                    )
                                    techs
                            ]

                ViewTech { name, steps } ->
                    column None
                        []
                        [ el None [] <| text name
                        , column None [] <| List.map text steps
                        ]
    in
        viewport styling <|
            content


viewPosition : Position -> Element Styles vs Msg
viewPosition { name, id } =
    el SetBox
        [ padding 5
        , height <| px 100
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
