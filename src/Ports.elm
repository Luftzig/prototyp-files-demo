port module Ports exposing (..)


type alias FilePortData =
  { content: String
  , filename: String
  }

port fileSelected : String -> Cmd msg

port fileContentRead : (FilePortData -> msg) -> Sub msg
