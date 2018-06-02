module View exposing (view)

import Date
import Element exposing (Element, button, column, downloadAs, empty, grid, h1, hairline, header, image, layout, mainContent, modal, row, table, text, when, whenJust)
import Element.Attributes as Attr exposing (center, padding, percent, px, spread, vary, verticalCenter, width)
import Element.Input as Input
import Element.Events as Events
import List.Extra exposing (transpose)
import Model exposing (EditEvent(..), EditingStatus(..), Field(..), File, FileData, FileEdited(..), FileValidationError(..), Model, Msg(..), SortDirection(..), Sorts)
import Styles exposing (Styles(..), Variations(Disabled, MiddleBorder), stylesheet)
import Html exposing (Html, input)
import Html.Attributes exposing (class, id, title, type_)
import Html.Events exposing (on)
import Icons
import Json.Decode as JD
import Time.Date
import Time.DateTime


view : Model -> Html Msg
view model =
    layout stylesheet <|
        column MainStyle
            [ center, width (percent 100), padding 5 ]
            [ header Header [ width Attr.fill, center ] <| text "Demo for Prototype"
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
            , column
                FileList
                [ center, width (percent 100), padding 20 ]
                ([ row FileListHeader [ width Attr.fill, spread, padding 5 ] <| tableHeader model.sorts ]
                    ++ List.map (row FileItem [ width Attr.fill, spread, padding 5 ] << fileRow) model.files
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
            [ center, spread, padding 5 ]
            [ row Header
                [ spread ]
                [ h1 Header [] <| text "Edit File Data", button CloseButton [ Events.onClick CancelUpload ] <| Icons.xSquare ]
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
                 , width (px 120)
                 , center
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


tableHeader : Sorts -> List (Element Styles Variations Msg)
tableHeader sorts =
    [ Element.el FileListHeader [ width <| Attr.fillPortion 1 ] <| empty
    , row FileListHeader
        [ width <| Attr.fillPortion 3, spread, padding 5 ]
        [ text "File name", sortIcon Filename sorts.filename ]
    , row FileListHeader
        [ width <| Attr.fillPortion 3, spread, padding 5, vary MiddleBorder True ]
        [ text "Description", sortIcon Description sorts.description ]
    , row FileListHeader
        [ width <| Attr.fillPortion 3, spread, padding 5, vary MiddleBorder True ]
        [ text "Name", sortIcon Owner sorts.owner ]
    , row FileListHeader
        [ width <| Attr.fillPortion 3, spread, padding 5, vary MiddleBorder True ]
        [ text "Date", sortIcon CreatedAt sorts.createdAt ]
    , Element.el FileListHeader [ width <| Attr.fillPortion 1 ] <| empty
    ]


sortIcon : Field -> SortDirection -> Element Styles Variations Msg
sortIcon field dir =
    let
        sortButton field nextDir icons =
            button Icon [ Events.onClick <| SortBy field nextDir ] <| row Icon [ padding -2 ] icons
    in
        case dir of
            Asc ->
                sortButton field Desc [ Icons.filter, Icons.chevronUp ]

            Desc ->
                sortButton field None [ Icons.filter, Icons.chevronDown ]

            None ->
                sortButton field Asc [ Icons.filter ]


fileRow : FileData -> List (Element Styles Variations Msg)
fileRow data =
    [ Element.el MainStyle [ width <| Attr.fillPortion 1 ] <|
        fileIcon data.file.filename
    , Element.el MainStyle [ width <| Attr.fillPortion 3 ] <|
        downloadAs { src = data.file.content, filename = data.file.filename } <|
            text data.file.filename
    , Element.el MainStyle [ width <| Attr.fillPortion 3 ] <|
        text data.description
    , Element.el MainStyle [ width <| Attr.fillPortion 3 ] <|
        text data.owner
    , Element.el MainStyle [ width <| Attr.fillPortion 3 ] <|
        text <|
            String.slice 0 10 <|
                Maybe.withDefault
                    ""
                <|
                    Maybe.map Time.DateTime.toISO8601 data.createdAt
    , Element.el MainStyle [ width <| Attr.fillPortion 1 ] <|
        whenJust data.id (\id -> button DeleteButton [ Events.onClick <| DeleteFile id ] Icons.trash)
    ]


fileIcon : String -> Element Styles Variations Msg
fileIcon name =
    let
        split =
            String.split "." (String.toLower name) |> List.reverse
    in
        case split of
            "jpg" :: _ ->
                Icons.image

            "jpeg" :: _ ->
                Icons.image

            "pdf" :: _ ->
                Icons.book

            "xml" :: _ ->
                Icons.code

            _ ->
                empty
