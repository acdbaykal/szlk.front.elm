module SzlkMsg exposing (SzlkMsg(..))

import TranslationProperty exposing (TranslationProperty)
type SzlkMsg = SearchInputChanged String | SearchRequested
    | SortBy TranslationProperty