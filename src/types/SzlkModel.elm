-- contains the complete model for this app
module SzlkModel exposing (SzlkModel)

import Translation exposing (Translation)
import TranslationSet exposing (TranslationSet)
import TranslationProperty exposing (TranslationProperty)
import TranslationType exposing (TranslationType)
import UpdateTranslationParameter exposing (UpdateTranslationAttemptParameter)
import SortDirection exposing (SortDirection)
import Account exposing (Account)
import View exposing (View)
import Navigation


type alias SzlkModel =
    {
         activeView: View
        ,addId: Int
        ,addTranslationTranslationText: String
        ,addTranslationOriginText: String
        ,addTranslationType:Maybe TranslationType
        ,focusId:String
        ,host: String
        ,history: List Navigation.Location
        ,loggedIn: (Maybe Account)
        ,passInput: String
        ,searchInputValue: String
        ,sortBy: TranslationProperty
        ,sortDirection: SortDirection
        ,routes: List (View, String)
        ,translations: TranslationSet
        ,addRequestedTranslations: List Translation
        ,updateAttempt: Maybe UpdateTranslationAttemptParameter
        ,userNameInput: String
    }
