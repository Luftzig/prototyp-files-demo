module Styles exposing (..)

import Style exposing (style, variation)
import Color
import Style.Border
import Style.Color
import Style.Font


type Styles
    = Upload
    | MainStyle
    | Error
    | FileList
    | FileListHeader
    | FileItem
    | FileEdit
    | FileEditInput
    | Icon
    | Header
    | Modal
    | SubmitButton
    | CloseButton
    | DeleteButton


type Variations
    = Disabled
    | MiddleBorder


stylesheet =
    Style.styleSheet
        [ style Upload []
        , style Header
            [ Style.Font.size 24
            , Style.Font.center
            ]
        , style FileList []
        , style FileListHeader
            [ Style.Font.bold
            , Style.Border.bottom 2
            , variation MiddleBorder
                [ Style.Border.left 1
                ]
            ]
        , style FileItem [ Style.Border.all 1 ]
        , style Modal
            [ Style.Color.background <| Color.greyscale 0.1
            , Style.Border.rounded 20
            ]
        , style MainStyle []
        , style SubmitButton
            [ variation Disabled
                [ Style.Color.background <| Color.greyscale 0.25 ]
            , Style.Color.background Color.green
            , Style.Border.rounded 5
            , Style.Border.all 2
            , Style.Color.border Color.white
            ]
        , style DeleteButton
            [ Style.Color.background <| Color.rgba 127 127 127 0
            ]
        , style Error
            [ Style.Color.text Color.red
            , Style.Font.size 10
            ]
        , style Icon
            [ Style.Color.background <| Color.rgba 127 127 127 0
            ]
        , style FileEditInput
            [ Style.Color.background Color.white
            , Style.Border.rounded 5
            , Style.Border.all 2
            , Style.Color.border <| Color.greyscale 0.85
            ]
        ]
