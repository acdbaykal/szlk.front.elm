-- contains the complete model for this app
module SzlkModel exposing (SzlkModel)

import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty)
import TranslationType exposing (TranslationType)
import SortDirection exposing (SortDirection)
import Account exposing (Account)


type alias SzlkModel =
    {
         addTranslationTranslationText: String
        ,addTranslationOriginText: String
        ,addTranslationType:Maybe TranslationType
        ,loggedIn: (Maybe Account)
        ,searchInputValue: String
        ,sortBy: TranslationProperty
        ,sortDirection: SortDirection
        ,translations: List Translation
    }