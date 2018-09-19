module Style exposing (a, actionIcon, b, bigIcon, block, c, choice, d, e, field, font, header, link, mattIcon)

import Element exposing (Attribute, Color, fill, height, mouseOver, padding, pointer, px, rgb255, width)
import Element.Background as Background
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
    , mouseOver
        [ Font.color a
        ]
    , padding 10
    , width fill
    ]


choice : List (Attribute msg)
choice =
    [ Font.size 50
    , font
    , pointer
    , Font.color a
    , width fill
    , mouseOver
        [ Font.color e
        ]
    ]


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


header : List (Attribute msg)
header =
    [ Font.size 55
    , Font.color e
    , pointer
    , mouseOver
        [ Font.color a
        ]
    ]


actionIcon : List (Attribute msg)
actionIcon =
    [ Font.color e
    , Font.size 35
    , pointer
    , width <| px 60
    , height <| px 60
    , mouseOver
        [ Font.color a
        ]
    ]


font : Attribute msg
font =
    Font.family
        [ Font.typeface "Cuprum"
        , Font.sansSerif
        ]


{-| light red
-}
a : Color
a =
    rgb255 195 106 104


{-| grey
-}
b : Color
b =
    rgb255 108 109 104


{-| red
-}
c : Color
c =
    rgb255 182 55 48


{-| bright red
-}
d : Color
d =
    rgb255 217 56 49


{-| yellow
-}
e : Color
e =
    rgb255 231 191 122
