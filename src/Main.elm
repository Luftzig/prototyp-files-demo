-- Main.elm


module Main exposing (..)

import Html exposing (program)
import Http
import Json.Encode as JE
import Json.Decode as JD
import Model exposing (EditEvent(..), EditingStatus(EditingOk, Pristine, ValidationError), File, FileData, FileEdited(Editing, NotEditing), FileValidationError(UnsupportedFile), Model, Msg(..))
import Ports exposing (FilePortData, fileSelected, fileContentRead)
import Set
import Time.Date
import View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { id = "ImageInputId"
      , files = []
      , fileEdited = NotEditing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected ->
            ( model
            , fileSelected model.id
            )

        FileRead data ->
            let
                newFile =
                    { content = data.content
                    , filename = data.filename
                    }
            in
                ( { model
                    | fileEdited =
                        Editing { file = newFile, owner = "", description = "", createdAt = Nothing, id = Nothing } Pristine
                  }
                , Cmd.none
                )

        SaveFile fileData ->
            ( model
            , sendSaveRequest fileData
            )

        CancelUpload ->
            ( { model | fileEdited = NotEditing }
            , Cmd.none
            )

        EditUpload change ->
            ( { model | fileEdited = editUpload change model.fileEdited }
            , Cmd.none
            )

        SaveResponse (Err x) ->
            Debug.log ("Save failed " ++ toString x) ( model, Cmd.none )

        SaveResponse (Ok fileData) ->
            ( { model
                | files = fileData :: model.files
                , fileEdited = NotEditing
              }
            , Cmd.none
            )


sendSaveRequest : FileData -> Cmd Msg
sendSaveRequest data =
    Http.send SaveResponse <| Http.post "/files" (Http.jsonBody <| encodeFileData data) fileDataDecoder


encodeFileData : FileData -> JE.Value
encodeFileData data =
    JE.object
        [ ( "filename", JE.string data.file.filename )
        , ( "owner", JE.string data.owner )
        , ( "content", JE.string data.file.content )
        , ( "description", JE.string data.description )
        ]


fileDataDecoder : JD.Decoder FileData
fileDataDecoder =
    let
        fileDecoder =
            JD.map2
                File
                (JD.field "content" JD.string)
                (JD.field "filename" JD.string)
    in
        JD.map5
            FileData
            fileDecoder
            (JD.field "owner" JD.string)
            (JD.field "description" JD.string)
            (JD.field "createdAt" (JD.string |> JD.map Time.Date.fromISO8601 |> JD.map Result.toMaybe))
            (JD.field "_id" (JD.string |> JD.map Just))


editUpload : EditEvent -> FileEdited -> FileEdited
editUpload change data =
    case data of
        NotEditing ->
            data

        Editing fileData status ->
            uncurry Editing <| updateEditingField change ( fileData, status )


updateEditingField : EditEvent -> ( FileData, EditingStatus ) -> ( FileData, EditingStatus )
updateEditingField change ( data, status ) =
    case change of
        ChangeOwner newOwner ->
            ( { data | owner = newOwner }, updateStatus Nothing status )

        ChangeDescription newDesc ->
            ( { data | description = newDesc }, updateStatus Nothing status )

        ChangeFileName newName ->
            let
                file =
                    data.file

                newFile =
                    { file | filename = newName }

                error =
                    if validFileName newName then
                        Nothing
                    else
                        Just UnsupportedFile
            in
                ( { data | file = newFile }, updateStatus error status )


updateStatus : Maybe FileValidationError -> EditingStatus -> EditingStatus
updateStatus error oldStatus =
    case error of
        Nothing ->
            if oldStatus /= Pristine then
                oldStatus
            else
                EditingOk

        Just error ->
            let
                existingErrors =
                    case oldStatus of
                        ValidationError errors ->
                            errors

                        _ ->
                            []
            in
                ValidationError <|
                    if List.member error existingErrors then
                        existingErrors
                    else
                        error :: existingErrors


validFileName : String -> Bool
validFileName name =
    List.any (\extension -> String.endsWith extension (String.toLower name))
        [ ".jpg", ".jpeg", ".pdf", ".xml" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileRead
