module MainTest exposing (main)

import Html exposing (..)
import Html.Attributes exposing (id, style)


main : Html msg
main =
    div
        [ id "test"
        , style "background-color" "#FFFFFF"
        , style "width" "600px"
        , style "height" "572px"
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
