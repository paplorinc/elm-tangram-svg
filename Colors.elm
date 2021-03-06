module Colors exposing (..)

import Color exposing (rgb)


type alias Color =
    Color.Color


elmGreen : Color
elmGreen =
    rgb 141 215 55


elmTurquoise : Color
elmTurquoise =
    rgb 96 181 204


elmOrange : Color
elmOrange =
    rgb 239 165 0


elmGray : Color
elmGray =
    rgb 90 99 120


red : Color
red =
    rgb 255 0 0


white : Color
white =
    Color.white


ugliest : Color
ugliest =
    rgb 0x4A 0x41 0x2A


toCss : Color -> String
toCss color =
    let
        rgb =
            Color.toRgb color
    in
        "rgb(" ++ toString rgb.red ++ "," ++ toString rgb.green ++ "," ++ toString rgb.blue ++ ")"
