module ResultAdminTableRow exposing (configure, RenderTypeSelectBoxFunction)

import Html exposing (Html, button, text, tr, td)
import Html.Events exposing (onClick)
import Html.Attributes exposing (contenteditable)
import VirtualDom exposing (Node)
import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty(..))
import UpdateTranslationParameter exposing (UpdateTranslationAttemptParameter, UpdateTranslationParameter)
import Date exposing (Date)

type alias RenderComponentFunction a = Translation -> Html a
type alias RenderTypeSelectBoxFunction a = Translation -> Html a

configure:  (Maybe Date -> String) ->
            (Translation -> a) -> -- delete translation request
            (Translation -> a) -> -- update origin text attempt
            (Translation -> a) -> -- update translation text attempt
            (Translation -> Html a) ->
            Translation -> Html a

configure formatDate
          deleteTranslationRequest
          updateOriginTextAttempt
          updateTranslationTextAttempt
          =
    \renderTypeSelectBox translation -> --render component function
            tr[][
               td[contenteditable True, onClick (updateOriginTextAttempt translation)][text translation.originText]
              ,td[contenteditable True, onClick (updateTranslationTextAttempt translation)][text translation.translationText]
              ,(renderTypeSelectBox translation)
              ,td[][text (formatDate translation.creationDate)]
              ,td[][text (formatDate translation.editDate)]
              ,td[][button [onClick (deleteTranslationRequest translation)][text "-"]]
            ]