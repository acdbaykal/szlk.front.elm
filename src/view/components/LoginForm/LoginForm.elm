module LoginForm exposing (configure, Ids, Translations, Model)

import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (for, id, value)
import Html.Events exposing (onInput, onClick)

type alias Translations = {
        cancel: String, login: String, passLabel: String, userNameLabel: String
    }

type alias Ids ={
        userNameInput: String, passInput: String
    }

type alias Model ={
        userNameInputValue: String, passInputValue: String
    }
configure:
    (String -> msg) -> -- on user name change
    (String -> msg) -> -- on pass change
    msg -> -- on send button activate
    msg -> -- on cancel button activate
    (Ids -> Translations -> Model -> Html msg) -- render function
configure onUserNameChange onPassChange onLoginRequest onCancelRequest =
    \ids translations model ->
        div[][
            div[][
                div[][
                    label[for ids.userNameInput][text translations.userNameLabel]
                    ,input[
                        id  ids.userNameInput
                        ,value model.userNameInputValue
                        ,onInput onUserNameChange
                    ][]
                ]
                ,div[][
                    label[for ids.passInput][text translations.passLabel]
                    ,input[
                        id ids.passInput
                        ,value model.passInputValue
                        ,onInput onPassChange
                    ][]
                ]
            ]
            ,div[][
                button[onClick onCancelRequest][text translations.cancel]
                ,button[onClick onLoginRequest][text translations.login]
            ]
        ]
