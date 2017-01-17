module SzlkMsg exposing (SzlkMsg(..))

import TranslationProperty exposing (TranslationProperty)
import Translation exposing (Translation)
import Account exposing (Account)

type SzlkMsg = SearchInputChanged String | SearchRequested
    | SortBy TranslationProperty
    --requests to fire a command
    |DeleteRequest Translation
    --commands
    | SearchTranslation String | Delete Translation | Update Translation
    | Add Translation | Login Account