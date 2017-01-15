-- contains the complete model for this app
module SzlkModel exposing (SzlkModel)

import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty)
import SortDirection exposing (SortDirection)


type alias SzlkModel =
    {
         searchInputValue: String
        ,sortBy: TranslationProperty
        ,sortDirection: SortDirection
        ,translations: List Translation
    }