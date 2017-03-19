module SzlkMsg exposing (SzlkMsg(..))

import Navigation
import Http
import Keyboard
import Date exposing (Date)
import Dom
import TranslationProperty exposing (TranslationProperty)
import TranslationType exposing (TranslationType)
import Translation exposing (Translation)
import Account exposing (Account)
import UpdateTranslationParameter exposing (UpdateTranslationParameter, UpdateTranslationAttemptParameter)

type SzlkMsg = UrlUpdate Navigation.Location| KeyDown Keyboard.KeyCode
    | ThrowAwayError String
    | SearchInputChanged String
    | SortBy TranslationProperty
    | PassWordChange String | UserNameChange String
    | LoginCancelRequest | LoginRequest
    | UpdateTranslationType (UpdateTranslationParameter (Maybe TranslationType))
    | UpdateTranslationOriginText (UpdateTranslationParameter String)
    | UpdateTranslationTranslationText (UpdateTranslationParameter String)
    | UpdateTranslationAttempt UpdateTranslationAttemptParameter
    | UpdateTranslationAttemptCancellation UpdateTranslationAttemptParameter
    --requests to fire a command
    |SearchRequested
    |AddRequest
        |AddRequestOriginText String
        |AddRequestTranslationText String
        |AddRequestTranslationType (Maybe TranslationType)
    |DeleteRequest Translation
    |UpdateCancel Translation
    -- Msgs to Answer an HTTP Request
    |SearchSuccess (List Translation)| SearchFail Http.Error
    |AddSuccess Translation Translation | AddFail Translation Http.Error
    |DeleteSuccess Translation | DeleteFail Translation Http.Error
    |UpdateSuccess Translation Translation | UpdateFail Translation Http.Error
    |LoginSuccess | LoginDenied | LoginFail Http.Error
    --commands
    |UpdateDates Date
    |SearchTranslation String | Delete Translation | Update Translation
    |Add Translation | Login Account
    --task results
    |FocusResult (Result Dom.Error ())