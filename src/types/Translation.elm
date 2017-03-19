module Translation exposing (Translation, TranslationId, hasId)

import TranslationType exposing (TranslationType)
import Date exposing (Date)


type alias TranslationId = String

type alias Translation =
    {
        id: Maybe TranslationId
        ,originText: String
        ,originShort: Maybe String
        ,translationText: String
        ,translationType: TranslationType
        ,creationDate: Maybe Date
        ,editDate: Maybe Date
    }

hasId: Translation -> Bool
hasId t = case t.id of
       Just _ -> True
       Nothing -> False