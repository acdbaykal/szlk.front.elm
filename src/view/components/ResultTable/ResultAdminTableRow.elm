module ResultAdminTableRow exposing (render, RenderTypeSelectBoxFunction)

import Html exposing (Attribute, Html, button, input, text, tr, td)
import Html.Events exposing (on, onClick, onInput, keyCode, targetValue)
import Html.Attributes exposing (..)
import Translation exposing (Translation, hasId)
import TranslationProperty exposing (TranslationProperty(..))
import TranslationType exposing (TranslationType)
import Date exposing (Date)
import Json.Decode as Json

type alias RenderComponentFunction a = Translation -> Html a
type alias RenderTypeSelectBoxFunction a = Translation -> Html a

onInputBlur: Translation -> (String -> msg) -> Attribute msg
onInputBlur translation tagger =
    on "blur" (Json.map tagger targetValue)

onKeyDown: Translation -> msg -> (String -> msg) -> Attribute msg
onKeyDown translation onEscMsg tagger =
    let
            keyDownDecoder code =
                if code == 13
                then (Json.map tagger targetValue)
                else
                    if code == 27
                    then Json.succeed onEscMsg
                    else Json.fail "pressed key not relevant"
    in
    on "keydown" (Json.andThen keyDownDecoder keyCode)

createAttr: Bool -> List (Attribute msg) -> List (Attribute msg)
createAttr hasId props = if hasId then props else []

render:  (Maybe Date -> String) ->
            String ->
            (Translation -> msg) -> -- delete translation request
            (Translation -> msg) -> -- update origin text attempt
            (Translation -> msg) -> -- update translation text attempt
            (Translation -> msg) -> -- cancel translation edit
            (Translation -> String -> msg) -> -- update origin text
            (Translation -> String -> msg) -> -- update translation text
            (Translation -> Html msg) ->
            (TranslationType -> String) ->
            Translation ->
            Maybe TranslationProperty ->
            Bool ->
            Html msg

render  formatDate
        focusId
        deleteTranslationRequest
        updateOriginTextAttempt
        updateTranslationTextAttempt
        cancelTranslationEdit
        updateOriginTextMsg
        updateTranslationTextMsg
        renderTypeSelectBox
        translationTypeToString
        translation
        editedProperty
        editable
          =
            let
                typeSelectBoxCell =
                    if editable then renderTypeSelectBox translation
                    else (td[][text (translationTypeToString translation.translationType)])
                createAttr_  = createAttr editable

                originTextCellAttr = createAttr_ [onClick (updateOriginTextAttempt translation)]
                defaultOriginTextCell = td originTextCellAttr[text translation.originText]
                translationTextCellAttr = createAttr_ [onClick (updateTranslationTextAttempt translation)]
                defaultTranslationTextCell = td translationTextCellAttr [text translation.translationText]
                creationDateCell = td[][text (formatDate translation.creationDate)]
                editDateCell = td[][text (formatDate translation.editDate)]
                deleteButtonCell =
                    if editable
                    then td[][button [onClick (deleteTranslationRequest translation)][text "-"]]
                    else td[][]

                onInputBlur_ = onInputBlur translation
                onKeyDown_ = onKeyDown translation
                updateOriginTextMsg_ = updateOriginTextMsg translation
                updateTranslationTextMsg_ = updateTranslationTextMsg translation
                cancelTranslationEdit_ = cancelTranslationEdit translation
                defaultTableRow =
                    [
                       defaultOriginTextCell
                      ,defaultTranslationTextCell
                      ,typeSelectBoxCell
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
                                           ,    onInputBlur_ updateOriginTextMsg_
                                           ,    onKeyDown_ cancelTranslationEdit_ updateOriginTextMsg_
                                           ,    value translation.originText
                                           ][]
                                        ]
                                  ,defaultTranslationTextCell
                                  ,typeSelectBoxCell
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
                                            ,   onInputBlur_ updateTranslationTextMsg_
                                            ,   onKeyDown_ cancelTranslationEdit_ updateTranslationTextMsg_
                                            ,   value translation.translationText
                                            ][]
                                          ]
                                      ,typeSelectBoxCell
                                      ,creationDateCell
                                      ,editDateCell
                                      ,deleteButtonCell
                                    ]
                            _ -> tr[] defaultTableRow
