module Styling exposing (..)

import Color exposing (black)
import Style exposing (StyleSheet, style, styleSheet)
import Style.Border as Border
import Style.Font as Font
import Style.Color as Color
import Types exposing (Styles(..))


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
