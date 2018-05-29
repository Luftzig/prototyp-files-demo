-- Main.elm


module Main exposing (..)

import Html exposing (program)
import Http
import Model exposing (EditEvent(..), File, FileData, Model, Msg(..))
import Ports exposing (FilePortData, fileSelected, fileContentRead)
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
      , fileEdited = Nothing
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
                        Just { file = newFile, owner = "", description = "", createdAt = Nothing, id = Nothing }
                  }
                , Cmd.none
                )

        SaveFile fileData ->
            ( model
            , sendSaveRequest fileData
            )

        CancelUpload ->
            ( { model | fileEdited = Nothing }
            , Cmd.none
            )

        EditUpload change ->
            ( { model | fileEdited = Maybe.map (editUpload change) model.fileEdited }
            , Cmd.none
            )


sendSaveRequest : FileData -> Cmd Msg
sendSaveRequest data =
    Http.send SaveResponse <| Http.post (jsonBody <| encodeFileData data) decodeFileData


editUpload : EditEvent -> FileData -> FileData
editUpload change data =
    case change of
        ChangeOwner newOwner ->
            { data | owner = newOwner }

        ChangeDescription newDesc ->
            { data | description = newDesc }

        ChangeFileName newName ->
            let
                file =
                    data.file

                newFile =
                    { file | filename = newName }
            in
                { data | file = newFile }


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileRead
