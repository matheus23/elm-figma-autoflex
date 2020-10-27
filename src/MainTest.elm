module MainTest exposing (main)

import Browser
import Codec
import Color exposing (Color)
import Figma
import Html exposing (..)
import Html.Attributes exposing (id, style)
import Json.Decode as Json
import Json.Decode.Extra as Json
import Maybe.Extra as Maybe
import Tree exposing (Tree)
import Tree.Extra as Tree


type alias Model =
    Html Never


type Msg
    = NoOp


type alias Flags =
    { figmaFile : Json.Value
    , nodeName : String
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    ( flags
        |> parse
        |> Maybe.map (\tree -> view tree Nothing)
        |> Maybe.map (List.singleton >> div [ id "test" ])
        |> Maybe.withDefault (div [ id "test" ] [ text "Couldn't parse." ])
    , Cmd.none
    )


interpretSimpleSolidPaint : Figma.Paint -> Maybe Color
interpretSimpleSolidPaint paint =
    case ( paint.blendMode, paint.type_ ) of
        ( "NORMAL", "SOLID" ) ->
            Just paint.color

        _ ->
            Nothing


parse : Flags -> Maybe Figma.Tree
parse { figmaFile, nodeName } =
    (case
        figmaFile
            |> Json.decodeValue parseFigmaFile
     of
        Err error ->
            let
                _ =
                    Debug.log "error" error
            in
            Nothing

        Ok tree ->
            Just tree
    )
        |> Maybe.andThen (findNodeNamed nodeName)


parseFigmaFile : Json.Decoder (List Figma.Tree)
parseFigmaFile =
    Json.at [ "document", "children" ] (Json.index 0 pageDecoder)


pageDecoder : Json.Decoder (List Figma.Tree)
pageDecoder =
    Json.field "children" (Json.list Figma.decodeTree)


findNodeNamed : String -> List Figma.Tree -> Maybe Figma.Tree
findNodeNamed needle trees =
    trees
        |> List.map (findFrame (\{ name } -> name == needle))
        |> Maybe.orList


findFrame : (Figma.FrameNode -> Bool) -> Figma.Tree -> Maybe Figma.Tree
findFrame predicate tree =
    case tree of
        Figma.Frame frameNode children ->
            if predicate frameNode then
                Just tree

            else
                children
                    |> List.map (findFrame predicate)
                    |> Maybe.orList

        _ ->
            Nothing


view : Figma.Tree -> Maybe Figma.BoundingBox -> Html msg
view tree parentBoundingBox =
    case tree of
        Figma.Frame frame children ->
            div
                (List.concat
                    [ [ style "position" "absolute"
                      , style "overflow" "hidden"
                      ]
                    , frame.background
                        |> List.head
                        |> Maybe.andThen interpretSimpleSolidPaint
                        |> backgroundColorAttributes
                    , frame.absoluteBoundingBox
                        |> sizeAttributes
                    ]
                )
                (List.map (\subtree -> view subtree (Just frame.absoluteBoundingBox)) children)

        Figma.Rectangle rectangle ->
            div
                (List.concat
                    [ [ style "position" "absolute"
                      ]
                    , rectangle.fills
                        |> List.head
                        |> Maybe.andThen interpretSimpleSolidPaint
                        |> backgroundColorAttributes
                    , parentBoundingBox
                        |> Maybe.map
                            (\parent ->
                                positioningAttributes
                                    { parent = parent
                                    , element = rectangle.absoluteBoundingBox
                                    }
                            )
                        |> Maybe.withDefault []
                    ]
                )
                []

        Figma.Other ->
            text ""


type alias Insets a =
    { left : a
    , top : a
    , right : a
    , bottom : a
    }


boundingBoxInsets : { parent : Figma.BoundingBox, element : Figma.BoundingBox } -> Insets Float
boundingBoxInsets { parent, element } =
    { left = element.x - parent.x
    , top = element.y - parent.y
    , right = parent.x + parent.width - (element.x + element.width)
    , bottom = parent.y + parent.height - (element.y + element.height)
    }


positioningAttributes : { parent : Figma.BoundingBox, element : Figma.BoundingBox } -> List (Html.Attribute msg)
positioningAttributes bounds =
    let
        { left, top } =
            boundingBoxInsets bounds
    in
    [ style "left" (px left)
    , style "top" (px top)
    , style "width" (px bounds.element.width)
    , style "height" (px bounds.element.height)
    ]


backgroundColorAttributes : Maybe Color -> List (Html.Attribute msg)
backgroundColorAttributes maybeColor =
    maybeColor
        |> Maybe.map (\c -> [ style "background-color" (Color.toCssString c) ])
        |> Maybe.withDefault []


sizeAttributes : Figma.BoundingBox -> List (Html.Attribute msg)
sizeAttributes { width, height } =
    [ style "width" (px width)
    , style "height" (px height)
    ]


px : Float -> String
px f =
    String.fromFloat f ++ "px"



--


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = \msg model -> ( model, Cmd.none )
        , view = \model -> Html.map never model
        , subscriptions = \model -> Sub.none
        }
