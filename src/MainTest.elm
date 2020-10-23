module MainTest exposing (main)

import Browser
import Figma
import Html exposing (..)
import Html.Attributes exposing (id, style)
import Json.Decode as Json
import Json.Decode.Extra as Json


type alias Model =
    { info : Maybe ViewInfo }


type Msg
    = NoOp


type alias Flags =
    String


type alias ViewInfo =
    { width : Float, height : Float }


parse : String -> Maybe ViewInfo
parse figmaFileJson =
    figmaFileJson
        |> Json.decodeString parseFigmaFile
        |> Result.toMaybe


parseFigmaFile : Json.Decoder ViewInfo
parseFigmaFile =
    Json.at [ "document", "children" ] (Json.index 0 pageDecoder)


pageDecoder : Json.Decoder ViewInfo
pageDecoder =
    Json.field "children" (Json.index 0 Figma.decodeFrame)
        |> Json.map
            (\frame ->
                { width = frame.absoluteBoundingBox.width
                , height = frame.absoluteBoundingBox.height
                }
            )


view : ViewInfo -> Html msg
view { width, height } =
    div
        [ id "test"
        , style "background-color" "#FFFFFF"
        , style "width" (px width) -- "600px"
        , style "height" (px height) -- "572px"
        , style "position" "relative"
        , style "overflow" "hidden"
        ]
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
