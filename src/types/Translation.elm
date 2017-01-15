module Translation exposing (Translation)

import TranslationType exposing (TranslationType)
import Date exposing (Date)

type alias Translation =
    {
         originText: String
        ,translationText: String
        ,translationType: TranslationType
        ,creationDate: Date
        ,editDate: Date
    }