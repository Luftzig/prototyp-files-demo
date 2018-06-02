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
    | Header
    | Modal
    | SubmitButton
    | CloseButton


type Variations
    = Disabled


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
        , style SubmitButton
            [ variation Disabled
                []
            ]
        , style Error
            [ Style.Color.text Color.red
            , Style.Font.size 10
            ]
        ]
