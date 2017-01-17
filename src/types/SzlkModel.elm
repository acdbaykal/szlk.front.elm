-- contains the complete model for this app
module SzlkModel exposing (SzlkModel)

import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty)
import SortDirection exposing (SortDirection)
import Account exposing (Account)


type alias SzlkModel =
    {
         loggedIn: (Maybe Account)
        ,searchInputValue: String
        ,sortBy: TranslationProperty
        ,sortDirection: SortDirection
        ,translations: List Translation
    }