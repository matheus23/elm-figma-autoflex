module Figma exposing (..)

import Codec exposing (Codec)
import Color exposing (Color)


{-| Represents Figma frames
-}
type alias Frame =
    { absoluteBoundingBox : BoundingBox
    , clipsContent : Bool
    , background : List Paint
    }


codecFrame : Codec Frame
codecFrame =
    Codec.object Frame
        |> Codec.field "absoluteBoundingBox" .absoluteBoundingBox codecBoundingBox
        |> Codec.field "clipsContent" .clipsContent Codec.bool
        |> Codec.field "background" .background (Codec.list codecPaint)
        |> Codec.buildObject


{-| A rectangle expressing a bounding box in absolute coordinates.
-}
type alias BoundingBox =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


codecBoundingBox : Codec BoundingBox
codecBoundingBox =
    Codec.object BoundingBox
        |> Codec.field "x" .x Codec.float
        |> Codec.field "y" .y Codec.float
        |> Codec.field "width" .width Codec.float
        |> Codec.field "height" .height Codec.float
        |> Codec.buildObject


type alias Paint =
    { -- TODO: Add custom types
      blendMode : String

    -- TODO: Add custom types
    , type_ : String
    , color : Color
    }


codecPaint : Codec Paint
codecPaint =
    Codec.object Paint
        |> Codec.field "blendMode" .blendMode Codec.string
        |> Codec.field "type" .type_ Codec.string
        |> Codec.field "color" .color codecColor
        |> Codec.buildObject


codecColor : Codec Color
codecColor =
    Codec.object Color.rgba
        |> Codec.field "r" (Color.toRgba >> .red) Codec.float
        |> Codec.field "g" (Color.toRgba >> .green) Codec.float
        |> Codec.field "b" (Color.toRgba >> .blue) Codec.float
        |> Codec.field "a" (Color.toRgba >> .alpha) Codec.float
        |> Codec.buildObject
