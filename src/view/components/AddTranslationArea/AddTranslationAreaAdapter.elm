module AddTranslationAreaAdapter exposing (render)

import Html exposing (Html)
import SzlkMsg exposing (SzlkMsg(..))
import SzlkModel exposing (SzlkModel)
import TranslationType exposing (TranslationType(..))
import AddTranslationArea exposing (configure)

dropBoxContent:List (TranslationType, String)
dropBoxContent =
    [
         (NOUN_MASK, "Noun (mask.)")
        ,(NOUN_FEM, "Noun (fem.)")
        ,(NOUN_NEUT, "Noun (neut.)")
        ,(SAYING, "Saying")
        ,(DIRECTIVE, "Directive")
        ,(VERB, "Verb")
    ]

render: SzlkModel -> Html SzlkMsg
render model = configure  AddRequest
                    AddRequestOriginText
                    AddRequestTranslationText
                    AddRequestTranslationType
                    dropBoxContent
                    model