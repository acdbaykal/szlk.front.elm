module LoginFormAdapter exposing(render)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))
import Html exposing (Html)

import LoginForm exposing (configure)

translations : LoginForm.Translations
translations = {
        cancel = "Cancel"
        ,login = "Login"
        ,passLabel = "Password"
        ,userNameLabel = "User name"
    }

ids : LoginForm.Ids
ids = {userNameInput = "daafdsdagsdhgndmdnydfacrg", passInput = "dlkjsflskdnslkfdnaldfnknqwqr"}

adaptModel : SzlkModel -> LoginForm.Model
adaptModel model =
    {
        userNameInputValue = model.userNameInput
        ,passInputValue = model.passInput
    }

render: SzlkModel -> Html SzlkMsg
render model =
    let
        render_ = configure UserNameChange PassWordChange LoginRequest LoginCancelRequest
    in
        render_ ids translations (adaptModel model)


