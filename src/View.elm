module View exposing (view)

import Date
import Element exposing (Element, button, column, downloadAs, empty, grid, h1, hairline, header, image, layout, mainContent, modal, row, table, text, when, whenJust)
import Element.Attributes as Attr exposing (center, padding, percent, px, spread, vary, verticalCenter, width)
import Element.Input as Input
import Element.Events as Events
import List.Extra exposing (transpose)
import Model
    exposing
        ( EditEvent(..)
        , EditingStatus(..)
        , File
        , FileData
        , FileEdited(..)
        , FileValidationError(..)
        , Model
        , Msg(..)
        )
import Styles exposing (Styles(..), Variations(Disabled), stylesheet)
import Html exposing (Html, input)
import Html.Attributes exposing (class, id, title, type_)
import Html.Events exposing (on)
import Json.Decode as JD
import Time.Date
import Time.DateTime


view : Model -> Html Msg
view model =
    layout stylesheet <|
        column MainStyle
            [ center, width (percent 100) ]
            [ header MainStyle [ center ] <| text "Demo for Prototype"
            , row Upload
                [ center ]
                [ Element.html <|
                    input
                        [ type_ "file"
                        , id model.id
                        , on "change"
                            (JD.succeed FileSelected)
                        ]
                        []
                ]
            , table FileList
                [ center ]
              <|
                transpose
                    (tableHeader
                        :: List.map fileRow model.files
                    )
            , editingModal model.fileEdited
            ]


editingModal : FileEdited -> Element Styles Variations Msg
editingModal fileEdited =
    case fileEdited of
        NotEditing ->
            empty

        Editing data status ->
            internalEditingModal data status


internalEditingModal : FileData -> EditingStatus -> Element Styles Variations Msg
internalEditingModal data status =
    modal Modal [ center, verticalCenter, width (px 375), padding 20 ] <|
        column FileEdit
            [ center, spread ]
            [ row Header
                [ spread ]
                [ h1 Header [] <| text "Edit File Data", button CloseButton [ Events.onClick CancelUpload ] <| text "x" ]
            , hairline FileEdit
            , Input.text FileEditInput
                []
                { onChange = EditUpload << ChangeFileName
                , value = data.file.filename
                , label = Input.labelLeft <| text "File name"
                , options = []
                }
            , Input.text FileEditInput
                []
                { onChange = EditUpload << ChangeOwner
                , value = data.owner
                , label = Input.labelLeft <| text "Owner"
                , options = []
                }
            , Input.multiline FileEditInput
                []
                { onChange = EditUpload << ChangeDescription
                , value = data.description
                , label = Input.labelLeft <| text "Description"
                , options = []
                }
            , button SubmitButton
                ([ Events.onClick <| SaveFile data
                 , width (px 50)
                 , vary Disabled (not <| fileCanBeSubmitted status || status == Sending)
                 ]
                    ++ if not <| fileCanBeSubmitted status || status == Sending then
                        [ Attr.attribute "disabled" "false" ]
                       else
                        []
                )
              <|
                if status == Sending then
                    text "Sending..."
                else
                    text "Upload"
            , when (status /= EditingOk) <| row Error [] <| errors status
            ]


fileCanBeSubmitted : EditingStatus -> Bool
fileCanBeSubmitted status =
    status == EditingOk


errors : EditingStatus -> List (Element Styles Variations Msg)
errors status =
    case status of
        ValidationError errors ->
            List.map (\err -> text <| toErrorMessage err) errors

        _ ->
            []


toErrorMessage : FileValidationError -> String
toErrorMessage error =
    case error of
        NoFile ->
            "No file was selected"

        UnsupportedFile ->
            "File type not supported. Only PDF, XML, and JPG are supported"


tableHeader : List (Element Styles Variations Msg)
tableHeader =
    [ empty
    , text "File name"
    , text "Description"
    , text "Name"
    , text "Date"
    ]


fileRow : FileData -> List (Element Styles Variations Msg)
fileRow data =
    [ text ""
    , downloadAs { src = data.file.content, filename = data.file.filename } <| text data.file.filename
    , text data.description
    , text data.owner
    , text <| Maybe.withDefault "" <| Maybe.map Time.DateTime.toISO8601 data.createdAt
    ]
