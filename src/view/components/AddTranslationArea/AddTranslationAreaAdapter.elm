module AddTranslationAreaAdapter exposing (render)

import Html exposing (Html)
import SzlkMsg exposing (SzlkMsg(..))
import SzlkModel exposing (SzlkModel)
import TranslationType exposing (TranslationType(..))
import AddTranslationArea exposing (configure)
import TranslationTypeSelectionBox

dropBoxContent:List (TranslationType, String)
dropBoxContent =
    [
         (NOUN_MASK, "Noun (mask.)")
        ,(NOUN_FEM, "Noun (fem.)")
        ,(NOUN_NEUT, "Noun (neut.)")
        ,(ADJECTIVE, "Adjective")
        ,(VERB, "Verb")
        ,(PLURAL, "PLURAL")
        ,(PREFIX, "Prefix")
        ,(DIRECTIVE, "Directive")
    ]

onChangeMsg : TranslationTypeSelectionBox.OnChangeMsg SzlkMsg
onChangeMsg ttype = AddRequestTranslationType ttype

renderTranslationTypeBox: Html SzlkMsg
renderTranslationTypeBox = TranslationTypeSelectionBox.render
                                onChangeMsg dropBoxContent Nothing

render: SzlkModel -> Html SzlkMsg
render model = configure  AddRequest
                    AddRequestOriginText
                    AddRequestTranslationText
                    renderTranslationTypeBox
                    model