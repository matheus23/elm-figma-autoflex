module Figma exposing (..)

import Codec exposing (Codec)
import Color exposing (Color)
import Tree exposing (Tree)


type alias FrameTree =
    Tree Frame


codecFrameTree : Codec FrameTree
codecFrameTree =
    Codec.recursive
        (\recurse ->
            codecFrameAndChildren
                { build =
                    \node children ->
                        Tree.tree
                            node
                            (children
                                |> Maybe.withDefault []
                            )
                , children = Tree.children >> Just
                , frame = Tree.label
                , codecChildren = Codec.list recurse
                }
        )


{-| Represents Figma frames
-}
type alias Frame =
    { name : String
    , absoluteBoundingBox : BoundingBox
    , clipsContent : Bool
    , background : List Paint
    }


{-| This will assume that the list of children is empty.
-}
codecFrame : Codec Frame
codecFrame =
    codecFrameAndChildren
        { build = \frame _ -> frame
        , children = \_ -> Nothing
        , frame = \frame -> frame
        , codecChildren = Codec.succeed []
        }


codecFrameAndChildren :
    { build : Frame -> Maybe children -> a
    , children : a -> Maybe children
    , frame : a -> Frame
    , codecChildren : Codec children
    }
    -> Codec a
codecFrameAndChildren { build, children, frame, codecChildren } =
    Codec.object
        (\name absoluteBoundingBox clipsContent background ->
            build
                { name = name
                , absoluteBoundingBox = absoluteBoundingBox
                , clipsContent = clipsContent
                , background = background
                }
        )
        |> Codec.field "name" (frame >> .name) Codec.string
        |> Codec.field "absoluteBoundingBox" (frame >> .absoluteBoundingBox) codecBoundingBox
        |> Codec.field "clipsContent" (frame >> .clipsContent) Codec.bool
        |> Codec.field "background" (frame >> .background) (Codec.list codecPaint)
        |> Codec.maybeField "children" children codecChildren
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
