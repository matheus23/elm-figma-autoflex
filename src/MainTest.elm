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
    String


init : Flags -> ( Model, Cmd msg )
init figmaFileJson =
    ( figmaFileJson
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


parse : String -> Maybe Figma.Tree
parse figmaFileJson =
    figmaFileJson
        |> Json.decodeString parseFigmaFile
        |> Result.toMaybe


parseFigmaFile : Json.Decoder Figma.Tree
parseFigmaFile =
    Json.at [ "document", "children" ] (Json.index 0 pageDecoder)


pageDecoder : Json.Decoder Figma.Tree
pageDecoder =
    Json.field "children" (Json.index 0 Figma.decodeTree)


findNodeNamed : String -> List Figma.Tree -> Maybe Figma.Tree
findNodeNamed needle trees =
    trees
        |> Maybe.traverse (findFrame (\{ name } -> name == needle))
        |> Maybe.andThen List.head


findFrame : (Figma.FrameNode -> Bool) -> Figma.Tree -> Maybe Figma.Tree
findFrame predicate tree =
    case tree of
        Figma.Frame frameNode children ->
            if predicate frameNode then
                Just tree

            else
                Maybe.traverse (findFrame predicate) children
                    |> Maybe.andThen List.head

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
                [ style "background-color" "#C4C4C4"
                , style "position" "absolute"
                , style "left" "205px"
                , style "top" "48px"
                , style "width" "458px"
                , style "height" "154px"
                ]
                []

        Figma.Other ->
            div
                [ style "background-color" "#C4C4C4"
                , style "position" "absolute"
                , style "left" "205px"
                , style "top" "48px"
                , style "width" "458px"
                , style "height" "154px"
                ]
                []



{-
   div
       (List.concat
           [ [ id "test"
             , style "position" "relative"
             , style "overflow" "hidden"
             ]
           , backgroundColorAttributes backgroundColor
           , sizeAttributes width height
           ]
       )
       [ div
           [ style "background-color" "#C4C4C4"
           , style "position" "absolute"
           , style "left" "205px"
           , style "top" "48px"
           , style "width" "458px"
           , style "height" "154px"
           ]
           []
       ]
-}


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
