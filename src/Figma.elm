module Figma exposing (..)

import Codec exposing (Codec)
import Color exposing (Color)
import Json.Decode as D
import Json.Decode.Extra as D


type Tree
    = Frame FrameNode (List Tree)
    | Other


decodeTree : D.Decoder Tree
decodeTree =
    D.field "type" D.string
        |> D.andThen
            (\type_ ->
                let
                    decodeFrameNode =
                        D.succeed Frame
                            |> D.andMap (Codec.decoder codecFrameNode)
                            |> D.andMap (D.field "children" (D.list decodeTree))
                in
                case type_ of
                    "COMPONENT" ->
                        decodeFrameNode

                    "INSTANCE" ->
                        decodeFrameNode

                    "FRAME" ->
                        decodeFrameNode

                    _ ->
                        D.succeed Other
            )


{-| Represents Figma frames
-}
type alias FrameNode =
    { name : String
    , absoluteBoundingBox : BoundingBox
    , clipsContent : Bool
    , background : List Paint
    }


codecFrameNode : Codec FrameNode
codecFrameNode =
    Codec.object FrameNode
        |> Codec.field "name" .name Codec.string
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
