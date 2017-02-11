module TranslationTypeSelectionBox exposing (render, OnChangeMsg, RenderFunction, OptionsData)

import Html exposing (Html, button, div, input, option, select, text)
import Html.Attributes exposing (placeholder, selected, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode
import TranslationType exposing (TranslationType, toTranslationType)

type alias OptionTuple = (TranslationType, String)
type alias SelectedType = Maybe TranslationType
type alias OptionsData = List OptionTuple
type alias OnChangeMsg a = (SelectedType -> a)
type alias RenderFunction a = OnChangeMsg a -> OptionsData -> SelectedType -> Html a

areSame : SelectedType -> TranslationType ->Bool
areSame selected ttype =
    case selected of
        Nothing -> False
        Just value -> value == ttype

renderDropBoxOption: SelectedType -> (OptionTuple -> Html a)
renderDropBoxOption selectedOption =
    let
        isSelected = areSame selectedOption
    in
        \content ->
            let
                (ttype, typeText) = content
                selectedVal = isSelected ttype
                attributeList =
                    case selectedVal of
                        True -> [value (toString ttype), selected selectedVal]
                        False -> [value (toString ttype)]
            in

                option attributeList [text typeText]


changeEventToType: Decode.Decoder (Maybe TranslationType)
changeEventToType =
    Decode.map toTranslationType (Decode.at [ "target", "value" ] Decode.string)

render: RenderFunction a
render onChangeTypeMsg typeBoxContent selected =
    let
        renderedOptions = (List.map (renderDropBoxOption selected) typeBoxContent)
    in
        select
            [on "change" (Decode.map onChangeTypeMsg changeEventToType)] renderedOptions
