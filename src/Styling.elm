module Styling exposing (..)

import Color exposing (Color, rgb)
import Style exposing (Property, StyleSheet, hover, style, styleSheet)
import Style.Border as Border
import Style.Font as Font
import Style.Color as Color
import Types exposing (Styles(..))


styling : StyleSheet Styles vs
styling =
    styleSheet
        [ style None []
        , style SetBox
            [ Border.all 2
            , Border.solid
            ]
        , style Button
            [ Border.rounded 15
            , pointer
            , Color.background b
            ]
        , style Body
            [ Font.typeface
                [ Font.font "Cuprum"
                , Font.sansSerif
                ]
            , Font.size 25
            ]
        , style Icon
            [ Color.text e
            , Border.rounded 15
            , pointer
            , hover [ Color.text a ]
            ]
        , style Link [ Font.underline, pointer ]
        , style Line [ Color.background e ]
        , style Header
            [ Font.size 55
            , Color.text e
            , pointer
            , hover [ Color.text a ]
            ]
        , style Picker
            [ Color.background c
            ]
        , style Subtitle
            [ Font.size 35
            , Color.text e
            ]
        , style Title [ Font.size 45, Color.text e ]
        , style Topics [ Color.text e, pointer, hover [ Color.text a ] ]
        ]


pointer : Property class variation
pointer =
    Style.cursor "pointer"


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
