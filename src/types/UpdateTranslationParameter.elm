module UpdateTranslationParameter exposing (UpdateTranslationAttemptParameter, UpdateTranslationParameter)

import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty)

type alias UpdateTranslationAttemptParameter =
    {
        translation: Translation,
        property: TranslationProperty
    }

type alias UpdateTranslationParameter a =
    {
        translation: Translation,
        property: TranslationProperty,
        value: a
    }