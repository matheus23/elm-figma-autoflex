module Figma exposing (..)

import Color exposing (Color)
import Json.Decode as Json
import Json.Decode.Extra as Json


{-| Represents Figma frames
-}
type alias Frame =
    { absoluteBoundingBox : BoundingBox
    , clipsContent : Bool
    , background : List Paint
    }


decodeFrame : Json.Decoder Frame
decodeFrame =
    Json.succeed Frame
        |> Json.andMap (Json.field "absoluteBoundingBox" decodeBoundingBox)
        |> Json.andMap (Json.field "clipsContent" Json.bool)
        |> Json.andMap (Json.field "background" (Json.list decodePaint))


{-| A rectangle expressing a bounding box in absolute coordinates.
-}
type alias BoundingBox =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


decodeBoundingBox : Json.Decoder BoundingBox
decodeBoundingBox =
    Json.succeed BoundingBox
        |> Json.andMap (Json.field "x" Json.float)
        |> Json.andMap (Json.field "y" Json.float)
        |> Json.andMap (Json.field "width" Json.float)
        |> Json.andMap (Json.field "height" Json.float)


type alias Paint =
    { -- TODO: Add custom types
      blendMode : String

    -- TODO: Add custom types
    , type_ : String
    , color : Color
    }


decodePaint : Json.Decoder Paint
decodePaint =
    Json.succeed Paint
        |> Json.andMap (Json.field "blendMode" Json.string)
        |> Json.andMap (Json.field "type" Json.string)
        |> Json.andMap (Json.field "color" decodeColor)


decodeColor : Json.Decoder Color
decodeColor =
    Json.succeed Color.rgba
        |> Json.andMap (Json.field "r" Json.float)
        |> Json.andMap (Json.field "g" Json.float)
        |> Json.andMap (Json.field "b" Json.float)
        |> Json.andMap (Json.field "a" Json.float)
