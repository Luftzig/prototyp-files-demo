module Styles exposing (..)

import Style exposing (style)
import Color
import Style.Border
import Style.Color


type Styles
    = Upload
    | MainStyle
    | FileList
    | FileListHeader
    | FileItem
    | FileEdit
    | FileEditInput
    | Header
    | Modal
    | SubmitButton
    | CloseButton


stylesheet =
    Style.styleSheet
        [ style Upload []
        , style FileList []
        , style FileListHeader []
        , style FileItem []
        , style Modal
            [ Style.Color.background Color.lightYellow
            , Style.Border.rounded 20
            ]
        , style MainStyle []
        ]
