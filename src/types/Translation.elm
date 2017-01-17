module Translation exposing (Translation, TranslationId)

import TranslationType exposing (TranslationType)
import Date exposing (Date)


type alias TranslationId = Float
type alias Translation =
    {
         id: Maybe TranslationId
        ,originText: String
        ,translationText: String
        ,translationType: TranslationType
        ,creationDate: Maybe Date
        ,editDate: Maybe Date
    }