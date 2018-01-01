module Styling exposing (..)

import Color exposing (Color, rgb)
import Style exposing (Property, StyleSheet, hover, importUrl, style, styleSheet, variation)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Types exposing (Styles(..), Variations(..))


styling : StyleSheet Styles Variations
styling =
    styleSheet
        [ importUrl "https://fonts.googleapis.com/css?family=Cuprum"
        , style None []
        , style BigIcon
            [ Color.text e
            , Font.size 40
            ]
        , style Button
            [ Border.rounded 15
            , pointer
            , Color.background b
            ]
        , style Body
            [ font
            , Font.size 25
            ]
        , style Choice
            [ Font.size 30
            , font
            , pointer
            , hover [ Color.text e ]
            ]
        , style ChooseBox
            [ Border.rounded 15
            , Border.all 3
            , Color.border e
            , Color.background c
            ]
        , style Dot [ Color.text e ]
        , style MattIcon
            [ Color.text e
            , Font.size 35
            ]
        , style Field
            [ Color.text e
            , Color.background a
            ]
        , style Link [ Font.underline, pointer ]
        , style Line [ Color.background e ]
        , style Header
            [ Font.size 55
            , Color.text e
            , pointer
            , hover [ Color.text a ]
            , variation Small [ Font.size 45 ]
            ]
        , style Picker
            [ Color.background c
            ]
        , style Subtitle
            [ Font.size 35
            , Color.text e
            ]
        , style Home [ Font.size 55, Color.text e ]
        , style ActionIcon
            [ Color.text e
            , Font.size 35
            , pointer
            , hover [ Color.text a ]
            ]
        , style BallIcon [ Font.size 35, Color.text c ]
        , style Ball [ Color.background e, pointer ]
        ]


pointer : Property class variation
pointer =
    Style.cursor "pointer"


font : Property class variation
font =
    Font.typeface
        [ Font.font "Cuprum"
        , Font.sansSerif
        ]


a : Color
a =
    rgb 195 106 104


b : Color
b =
    rgb 108 109 104


c : Color
c =
    rgb 182 55 48


d : Color
d =
    rgb 217 56 49


e : Color
e =
    rgb 231 191 122
