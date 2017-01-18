module SzlkMsg exposing (SzlkMsg(..))

import Date exposing (Date)
import TranslationProperty exposing (TranslationProperty)
import TranslationType exposing (TranslationType)
import Translation exposing (Translation)
import Account exposing (Account)

type SzlkMsg = ThrowAwayError String|SearchInputChanged String | SearchRequested
    | SortBy TranslationProperty
    --requests to fire a command
    |AddRequest
        |AddRequestOriginText String
        |AddRequestTranslationText String
        |AddRequestTranslationType (Maybe TranslationType)
    |DeleteRequest Translation
    --commands
    |UpdateDates (Maybe Date)
    |SearchTranslation String | Delete Translation | Update Translation
    |Add Translation | Login Account