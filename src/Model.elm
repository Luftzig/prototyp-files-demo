module Model exposing (..)

import Http
import Time.Date exposing (Date)
import Ports exposing (FilePortData)


type Msg
    = FileSelected
    | FileRead FilePortData
    | SaveFile FileData
    | CancelUpload
    | EditUpload EditEvent
    | SaveResponse (Result Http.Error FileData)


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
    , createdAt : Maybe Date
    , id : Maybe FileID
    }


type alias FileID =
    String


type alias Model =
    { id : String
    , files : List FileData
    , fileEdited : Maybe FileData
    }
