-- Main.elm


module Main exposing (..)

import Html exposing (program)
import Http
import Json.Encode as JE
import Json.Decode as JD
import Model
    exposing
        ( EditEvent(..)
        , EditingStatus(..)
        , File
        , FileData
        , FileEdited(..)
        , FileValidationError(UnsupportedFile)
        , Model
        , Msg(..)
        )
import Ports exposing (FilePortData, fileSelected, fileContentRead)
import Set
import Task
import Time
import Time.Date
import Time.DateTime as DateTime
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
      , errors = ""
      }
    , getFiles
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

                status =
                    if validFileName data.filename then
                        EditingOk
                    else
                        ValidationError [ UnsupportedFile ]
            in
                ( { model
                    | fileEdited =
                        Editing { file = newFile, owner = "", description = "", createdAt = Nothing, id = Nothing } status
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
            Debug.log ("Save failed " ++ toString x) ( { model | fileEdited = NotEditing, errors = toString x }, Cmd.none )

        SaveResponse (Ok fileData) ->
            ( { model
                | files = fileData :: model.files
                , fileEdited = NotEditing
              }
            , Cmd.none
            )

        ListFiles (Err x) ->
            Debug.log ("List failed " ++ toString x) ( { model | errors = toString x }, Cmd.none )

        ListFiles (Ok files) ->
            ( { model
                | files = files
              }
            , Cmd.none
            )


getFiles : Cmd Msg
getFiles =
    Http.send ListFiles <| Http.get "/files" (JD.list fileDataDecoder)


sendSaveRequest : FileData -> Cmd Msg
sendSaveRequest data =
    Task.attempt SaveResponse (compileSaveRequest data)


compileSaveRequest : FileData -> Task.Task Http.Error FileData
compileSaveRequest data =
    Time.now
        |> Task.andThen (\time -> Task.succeed <| { data | createdAt = Just (DateTime.fromTimestamp time) })
        |> Task.andThen (\data -> Task.succeed <| Http.jsonBody <| encodeFileData data)
        |> Task.andThen (\encodedData -> Http.toTask <| Http.post "/files" encodedData fileDataDecoder)


encodeFileData : FileData -> JE.Value
encodeFileData data =
    JE.object
        [ ( "filename", JE.string data.file.filename )
        , ( "owner", JE.string data.owner )
        , ( "content", JE.string data.file.content )
        , ( "description", JE.string data.description )
        , ( "createdAt", Maybe.withDefault (JE.null) (Maybe.map (DateTime.toISO8601 >> JE.string) data.createdAt) )
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
            (JD.field "createdAt" (JD.string |> JD.map DateTime.fromISO8601 |> JD.map Result.toMaybe))
            (JD.field "id" (JD.int |> JD.map Just))


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
            ( { data | owner = newOwner }, status )

        ChangeDescription newDesc ->
            ( { data | description = newDesc }, status )

        ChangeFileName newName ->
            let
                file =
                    data.file

                newFile =
                    { file | filename = newName }

                newStatus =
                    if validFileName newFile.filename then
                        clearError UnsupportedFile status
                    else
                        addError UnsupportedFile status
            in
                ( { data | file = newFile }, newStatus )


addError : FileValidationError -> EditingStatus -> EditingStatus
addError error oldStatus =
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


clearError : FileValidationError -> EditingStatus -> EditingStatus
clearError error oldStatus =
    let
        existingErrors =
            case oldStatus of
                ValidationError errors ->
                    errors

                _ ->
                    []

        newErrors =
            List.filter ((/=) error) existingErrors
    in
        if List.isEmpty newErrors then
            EditingOk
        else
            ValidationError newErrors


validFileName : String -> Bool
validFileName name =
    List.any (\extension -> String.endsWith extension (String.toLower name))
        [ ".jpg", ".jpeg", ".pdf", ".xml" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileRead
