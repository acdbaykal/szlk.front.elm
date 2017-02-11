module ResultAdminTableRow exposing (render, RenderTypeSelectBoxFunction)

import Html exposing (Html, button, input, text, tr, td)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty(..))
import Date exposing (Date)

type alias RenderComponentFunction a = Translation -> Html a
type alias RenderTypeSelectBoxFunction a = Translation -> Html a

render:  (Maybe Date -> String) ->
            String ->
            (Translation -> a) -> -- delete translation request
            (Translation -> a) -> -- update origin text attempt
            (Translation -> a) -> -- update translation text attempt
            (String -> a) -> -- update origin text
            (String -> a) -> -- update translation text
            (Translation -> Html a) ->
            Translation ->
            Maybe TranslationProperty ->
            Html a

render  formatDate
        focusId
        deleteTranslationRequest
        updateOriginTextAttempt
        updateTranslationTextAttempt
        updateOriginTextMsg
        updateTranslationTextMsg
        renderTypeSelectBox
        translation
        editedProperty
          =
            let
                typeSelectBoxHtml = renderTypeSelectBox translation
                defaultOriginTextCell = td[onClick (updateOriginTextAttempt translation)][text translation.originText]
                defaultTranslationTextCell = td[onClick (updateTranslationTextAttempt translation)][text translation.translationText]
                creationDateCell = td[][text (formatDate translation.creationDate)]
                editDateCell = td[][text (formatDate translation.editDate)]
                deleteButtonCell = td[][button [onClick (deleteTranslationRequest translation)][text "-"]]
                defaultTableRow =
                    [
                       defaultOriginTextCell
                      ,defaultTranslationTextCell
                      ,typeSelectBoxHtml
                      ,creationDateCell
                      ,editDateCell
                      ,deleteButtonCell
                    ]
            in
                case editedProperty of
                    Nothing ->
                        tr[] defaultTableRow
                    Just property ->
                        case property of
                            OriginText ->
                                tr[][
                                   td[]
                                        [
                                           input[
                                                id focusId
                                           ,    onInput updateOriginTextMsg
                                           ,    value translation.originText
                                           ][]
                                        ]
                                  ,defaultTranslationTextCell
                                  ,typeSelectBoxHtml
                                  ,creationDateCell
                                  ,editDateCell
                                  ,deleteButtonCell
                                ]
                            TranslationText ->
                                    tr[][
                                       defaultOriginTextCell
                                      ,td[]
                                          [
                                            input[
                                                id focusId
                                            ,   onInput updateTranslationTextMsg
                                            ,   value translation.translationText
                                            ][]
                                          ]
                                      ,typeSelectBoxHtml
                                      ,creationDateCell
                                      ,editDateCell
                                      ,deleteButtonCell
                                    ]
                            _ -> tr[] defaultTableRow
