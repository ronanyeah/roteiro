module Styling exposing (..)

import Color exposing (Color, rgb)
import Element exposing (Attribute, height, padding, pointer, px, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


bigIcon : List (Attribute msg)
bigIcon =
    [ Font.color e
    , Font.size 40
    ]


block : List (Attribute msg)
block =
    [ Font.size 40
    , font
    , pointer
    , Background.color e
    , Font.color c
    , Font.mouseOverColor Color.darkGrey
    , padding 10
    ]


choice : List (Attribute msg)
choice =
    [ Font.size 50
    , font
    , pointer
    , Font.color Color.darkGrey
    , Font.mouseOverColor e
    ]


dot : List (Attribute msg)
dot =
    [ Font.color e ]


mattIcon : List (Attribute msg)
mattIcon =
    [ Font.color e
    , Font.size 35
    ]


field : List (Attribute msg)
field =
    [ Font.color e
    , Background.color a
    ]


link : List (Attribute msg)
link =
    [ Font.underline, pointer ]


line : List (Attribute msg)
line =
    [ Background.color e ]


header : List (Attribute msg)
header =
    [ Font.size 55
    , Font.color e
    , pointer
    , Font.mouseOverColor a
    ]


picker : List (Attribute msg)
picker =
    [ Background.color c
    ]


subtitle : List (Attribute msg)
subtitle =
    [ Font.size 35
    , Font.color e
    ]


home : List (Attribute msg)
home =
    [ Font.size 45, Font.color e ]


actionIcon : List (Attribute msg)
actionIcon =
    [ Font.color e
    , Font.size 35
    , pointer
    , Font.mouseOverColor a
    ]


ballIcon : List (Attribute msg)
ballIcon =
    [ Font.color c
    , Font.size 35
    , pointer
    , Background.color e
    , Border.rounded 30
    , width <| px 60
    , height <| px 60
    , Font.mouseOverColor a
    ]


ball : List (Attribute msg)
ball =
    [ Background.color e, pointer ]


font : Attribute msg
font =
    Font.family
        [ Font.external
            { name = "Cuprum"
            , url = "https://fonts.googleapis.com/css?family=Cuprum"
            }
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
