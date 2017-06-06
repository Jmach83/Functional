import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import List
import Json.Decode as Decode
import Json.Encode as Encode

main : Program Never Model Msg --Annotatiom says main has type program and should never expect flags argument
main =
  program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

 -- MODEL
type alias Model =
  { chatMessage : List String
  , userMessage : String
  , username : String
  , userList : List String
  }

init : (Model, Cmd Msg)
init =
  ( Model [] "" "" []
  , Cmd.none
  )

-- UPDATE
type Msg
  = PostChatMessage
  | UpdateUserMessage String
  | UpdateUserName String
  | NewChatMessage String
  | PostLogin
  | LogoutUser

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PostChatMessage ->
      let
        message =
          Encode.object [ ("command", Encode.string "send")
                 , ("content", Encode.string model.userMessage)
                 ]
      in
        { model | userMessage = "" } ! [WebSocket.send "ws://localhost:3000/" (Encode.encode 0 message) ]

    PostLogin ->
      let
        userName =
          Encode.object [ ("command", Encode.string "login")
                 , ("content", Encode.string model.username)
                 ]
      in
        { model | username = "" } ! [WebSocket.send "ws://localhost:3000/" (Encode.encode 0 userName) ]

    UpdateUserMessage message ->
      { model | userMessage = message } ! []

    UpdateUserName message ->
      { model | username = message } ! []

    LogoutUser ->
      { model | userList = [] } ! []

    NewChatMessage message ->
      let
        command = jsonToString (Decode.decodeString (Decode.field "command" Decode.string) message)
      in
       case command of
         "login" -> { model | userList = [jsonToString (Decode.decodeString (Decode.field "content" Decode.string) message)] } ! []
         "send" -> { model | chatMessage = jsonToString (Decode.decodeString (Decode.field "content" Decode.string) message) :: model.chatMessage } ! []
         _ -> { model | chatMessage =  ["Something went wrong, try again"] } ! []




jsonToString : Result String String -> String
jsonToString result =
  case result of
    Ok result -> result
    Err result -> result

-- VIEW
view : Model -> Html Msg
view model =
  div [ style
    [ ("margin", "2px")]]
    [ input [ placeholder "Username"
    , autofocus True
    , value model.username
    , onInput UpdateUserName
    , hidden (showLogIn model.userList)
    , inputStyle
    ] []
    , button [ onClick PostLogin, hidden (showLogIn model.userList)] [ text "Login" ]
    , div [] (List.map showUser model.userList)
    , button [ onClick LogoutUser, hidden (showLogout model.userList) ] [text "Logout"]
    , div [ chatBoxStyle ] (List.reverse (List.map showMessage  model.chatMessage))
    , input [ placeholder "Message..."
            , value model.userMessage
            , onInput UpdateUserMessage
            , inputStyle
            ] []
    , button [ onClick PostChatMessage ] [ text "Submit" ]
  ]

showUser : String -> Html msg
showUser user =
  let
   userString = "Logged in as: " ++ user
  in
   div [] [text userString]

showMessage : String -> Html msg
showMessage msg =
  div [] [text msg]

showLogout : List String -> Bool
showLogout list =
  case List.isEmpty list of
    True -> True
    False -> False

showLogIn : List String -> Bool
showLogIn list =
  case List.isEmpty list of
    True -> False
    False -> True

  --STYLING
inputStyle : Attribute msg
inputStyle =
  style [ ("margin-left", "5px") ]

chatBoxStyle : Attribute msg
chatBoxStyle =
  style
    [ ("border-width", "1px")
    , ("border-style", "solid")
    , ("width", "300px")
    , ("height", "300px")
    , ("padding", "10px")
    , ("margin", "5px")
    , ("border-color", "darkblue")
    ]

 -- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:3000" NewChatMessage
