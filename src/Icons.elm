module Icons
    exposing
        ( book
        , code
        , image
        , trash
        , xSquare
        )

import Element exposing (Element, html)
import Styles exposing (Styles(Icon))
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (..)


svgFeatherIcon : String -> List (Svg msg) -> Element Styles variations msg
svgFeatherIcon className =
    html
        << (svg
                [ class <| "feather feather-" ++ className
                , fill "none"
                , height "24"
                , stroke "currentColor"
                , strokeLinecap "round"
                , strokeLinejoin "round"
                , strokeWidth "2"
                , viewBox "0 0 24 24"
                , width "24"
                ]
           )


book : Element Styles variations msg
book =
    svgFeatherIcon "book"
        [ Svg.path [ d "M4 19.5A2.5 2.5 0 0 1 6.5 17H20" ] []
        , Svg.path [ d "M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" ] []
        ]


code : Element Styles variations msg
code =
    svgFeatherIcon "code"
        [ Svg.polyline [ points "16 18 22 12 16 6" ] []
        , Svg.polyline [ points "8 6 2 12 8 18" ] []
        ]


image : Element Styles variations msg
image =
    svgFeatherIcon "image"
        [ Svg.rect [ Svg.Attributes.x "3", y "3", width "18", height "18", rx "2", ry "2" ] []
        , Svg.circle [ cx "8.5", cy "8.5", r "1.5" ] []
        , Svg.polyline [ points "21 15 16 10 5 21" ] []
        ]


trash : Element Styles variations msg
trash =
    svgFeatherIcon "trash"
        [ Svg.polyline [ points "3 6 5 6 21 6" ] []
        , Svg.path [ d "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" ] []
        ]


xSquare : Element Styles variations msg
xSquare =
    svgFeatherIcon "x-square"
        [ Svg.rect [ Svg.Attributes.x "3", y "3", width "18", height "18", rx "2", ry "2" ] []
        , Svg.line [ x1 "9", y1 "9", x2 "15", y2 "15" ] []
        , Svg.line [ x1 "15", y1 "9", x2 "9", y2 "15" ] []
        ]
