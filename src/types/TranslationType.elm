module TranslationType exposing (TranslationType(..), toTranslationType)

type TranslationType = NOUN_MASK | NOUN_FEM | NOUN_NEUT
    | VERB | DIRECTIVE | SAYING


toTranslationType: String -> Maybe TranslationType
toTranslationType str =
    case str of
        "NOUN_MASK" -> Just NOUN_MASK
        "NOUN_FEM" -> Just NOUN_FEM
        "NOUN_NEUT" -> Just NOUN_NEUT
        "VERB" -> Just VERB
        "DIRECTIVE" -> Just DIRECTIVE
        "SAYING" -> Just SAYING
        _ -> Nothing