module MainTest exposing (main)

import Browser
import Codec
import Color exposing (Color)
import Figma
import Html exposing (..)
import Html.Attributes exposing (id, style)
import Json.Decode as Json
import Json.Decode.Extra as Json


type alias Model =
    { info : Maybe FrameInterpretation }


type Msg
    = NoOp


type alias Flags =
    String


type alias FrameInterpretation =
    { width : Float
    , height : Float
    , backgroundColor : Maybe Color
    }


interpretFrame : Figma.Frame -> Maybe FrameInterpretation
interpretFrame frame =
    frame.background
        |> List.head
        |> Maybe.map interpretSimpleSolidPaint
        |> Maybe.map
            (\backgroundColor ->
                { width = frame.absoluteBoundingBox.width
                , height = frame.absoluteBoundingBox.height
                , backgroundColor = backgroundColor
                }
            )


interpretSimpleSolidPaint : Figma.Paint -> Maybe Color
interpretSimpleSolidPaint paint =
    case ( paint.blendMode, paint.type_ ) of
        ( "NORMAL", "SOLID" ) ->
            Just paint.color

        _ ->
            Nothing


parse : String -> Maybe FrameInterpretation
parse figmaFileJson =
    figmaFileJson
        |> Json.decodeString parseFigmaFile
        |> Result.toMaybe


parseFigmaFile : Json.Decoder FrameInterpretation
parseFigmaFile =
    Json.at [ "document", "children" ] (Json.index 0 pageDecoder)


pageDecoder : Json.Decoder FrameInterpretation
pageDecoder =
    Json.field "children" (Json.index 0 (Codec.decoder Figma.codecFrame))
        |> Json.andThen
            (interpretFrame
                >> Maybe.map Json.succeed
                >> Maybe.withDefault (Json.fail "")
            )


view : FrameInterpretation -> Html msg
view { width, height, backgroundColor } =
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


backgroundColorAttributes : Maybe Color -> List (Html.Attribute msg)
backgroundColorAttributes maybeColor =
    maybeColor
        |> Maybe.map (\c -> [ style "background-color" (Color.toCssString c) ])
        |> Maybe.withDefault []


sizeAttributes : Float -> Float -> List (Html.Attribute msg)
sizeAttributes width height =
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
        { init = \flags -> ( { info = parse flags }, Cmd.none )
        , update = \msg model -> ( model, Cmd.none )
        , view =
            \model ->
                model.info
                    |> Maybe.map view
                    |> Maybe.withDefault
                        (div
                            [ id "test" ]
                            [ text "Couldn't parse." ]
                        )
        , subscriptions = \model -> Sub.none
        }
