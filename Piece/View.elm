module Piece.View exposing (view)

import Colors
import Piece.Model exposing (Model, getPosition, getRotation)
import Piece.Types exposing (Msg(DragStart), Shape(..), Drag(..), Position)


--

import Json.Decode as Json exposing ((:=))
import Mouse
import String
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import VirtualDom


view : Model -> Svg Msg
view model =
    let
        realPosition =
            getPosition model

        realRotation =
            getRotation model

        ds =
            model.drag
    in
        Svg.node "svg"
            [ VirtualDom.on "mousedown" (Json.map DragStart offsetPosition)
            ]
            [ case model.shape of
                Triangle color scale ->
                    polygon trianglePoints color scale realRotation ( toFloat realPosition.x, toFloat realPosition.y ) ds

                Square color scale ->
                    polygon squarePoints color scale realRotation ( toFloat realPosition.x, toFloat realPosition.y ) ds

                Parallelogram color scale ->
                    polygon paraPoints color scale realRotation ( toFloat realPosition.x, toFloat realPosition.y ) ds
            ]


{-| Extract the *offset* position from the mouse event, giving coords relative
to the SVG space of the node rather than global window coords.
-}
offsetPosition : Json.Decoder Position
offsetPosition =
    Json.object2 Position ("offsetX" := Json.int) ("offsetY" := Json.int)


{-| Define the vertices of the shapes.  Define each such that origin at their
50% point so that rotation is natural. Triangle is defined with the hypotenuse
is horizontal.
-}
trianglePoints =
    [ ( 0, -0.5 ), ( 1, 0.5 ), ( -1, 0.5 ) ]


squarePoints =
    [ ( 0, -0.5 ), ( 0.5, 0 ), ( 0, 0.5 ), ( -0.5, 0 ) ]


paraPoints =
    [ ( 0.25, -0.25 ), ( -0.75, -0.25 ), ( -0.25, 0.25 ), ( 0.75, 0.25 ) ]



{- Do transformations explicitly in Elm rather than using the SVG `transform`
   attribute. My scheme of defining the shapes with origin at their center does
   not seem to place nice with SVG transformation, causing clipping when coords
   are negative.
-}


polygon : List ( Float, Float ) -> Colors.Color -> Float -> Float -> ( Float, Float ) -> Maybe Drag -> Svg Msg
polygon shape color scale rotation position drag =
    let
        vertices =
            shape |> List.map (scalePoint scale >> rotatePoint rotation >> translatePoint position)

        cursorVal =
            case drag of
                Just (Dragging _) ->
                    "move"

                Just (Rotating _) ->
                    "crosshair"

                _ ->
                    "pointer"
    in
        Svg.polygon
            [ points <| pointsToString vertices
            , fill <| Colors.toCss color
            , stroke "lightgray"
            , strokeWidth (toString (6))
            , strokeLinejoin "round"
            , cursor cursorVal
            ]
            []


rotatePoint : Float -> ( Float, Float ) -> ( Float, Float )
rotatePoint angle ( x, y ) =
    let
        x' =
            x * cos angle - y * sin angle

        y' =
            x * sin angle + y * cos angle
    in
        ( x', y' )


scalePoint : Float -> ( Float, Float ) -> ( Float, Float )
scalePoint factor ( x, y ) =
    ( x * factor, y * factor )


translatePoint : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
translatePoint ( dx, dy ) ( x, y ) =
    ( x + dx, y + dy )


{-| Construct the value needed for the SVG `points` attribute.
-}
pointsToString : List ( Float, Float ) -> String
pointsToString list =
    List.map (\( x, y ) -> toString x ++ " " ++ toString y) list |> String.join " "
