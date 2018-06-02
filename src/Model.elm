module Model exposing (..)

import Http
import Time.Date exposing (Date)
import Ports exposing (FilePortData)
import Set exposing (Set)
import Time.DateTime exposing (DateTime)


type Msg
    = FileSelected
    | FileRead FilePortData
    | SaveFile FileData
    | CancelUpload
    | EditUpload EditEvent
    | SaveResponse (Result Http.Error FileData)
    | ListFiles (Result Http.Error (List FileData))


type EditEvent
    = ChangeOwner String
    | ChangeDescription String
    | ChangeFileName String


type alias File =
    { content : String
    , filename : String
    }


type alias FileData =
    { file : File
    , owner : String
    , description : String
    , createdAt : Maybe DateTime
    , id : Maybe FileID
    }


type alias FileID =
    Int


type FileEdited
    = NotEditing
    | Editing FileData EditingStatus


type EditingStatus
    = EditingOk
    | ValidationError (List FileValidationError)
    | Sending


type FileValidationError
    = NoFile
    | UnsupportedFile


type alias Model =
    { id : String
    , files : List FileData
    , fileEdited : FileEdited
    , errors : String
    }
