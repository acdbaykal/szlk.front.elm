module ResultAdminTableRow exposing (configure)

import Html exposing (Html, button, text, tr, td)
import Html.Events exposing (onClick)
import Translation exposing (Translation)
import Date exposing (Date)

configure: (Translation -> String) -> (Maybe Date -> String) -> (Translation -> a) -> Translation -> Html a
configure labelType formatDate deleteTranslationRequest =
    \translation -> tr[]
                    [
                        td[][text translation.originText]
                       ,td[][text translation.translationText]
                       ,td[][text (labelType translation)]
                       ,td[][text (formatDate translation.creationDate)]
                       ,td[][text (formatDate translation.editDate)]
                       ,td[][button [onClick (deleteTranslationRequest translation)][text "-"]]
                    ]