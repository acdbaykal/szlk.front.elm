module SzlkMsg exposing (SzlkMsg(..))

import Date exposing (Date)
import Dom
import TranslationProperty exposing (TranslationProperty)
import TranslationType exposing (TranslationType)
import Translation exposing (Translation)
import Account exposing (Account)
import UpdateTranslationParameter exposing (UpdateTranslationParameter, UpdateTranslationAttemptParameter)

type SzlkMsg = ThrowAwayError String|SearchInputChanged String | SearchRequested
    | SortBy TranslationProperty
    | UpdateTranslationType (UpdateTranslationParameter (Maybe TranslationType))
    | UpdateTranslationOriginText (UpdateTranslationParameter String)
    | UpdateTranslationTranslationText (UpdateTranslationParameter String)
    | UpdateTranslationAttempt UpdateTranslationAttemptParameter
    | UpdateTranslationAttemptCancellation UpdateTranslationAttemptParameter
    --requests to fire a command
    |AddRequest
        |AddRequestOriginText String
        |AddRequestTranslationText String
        |AddRequestTranslationType (Maybe TranslationType)
    |DeleteRequest Translation
    --commands
    |UpdateDates Date
    |SearchTranslation String | Delete Translation | Update Translation
    |Add Translation | Login Account
    --task results
    |FocusResult (Result Dom.Error ())