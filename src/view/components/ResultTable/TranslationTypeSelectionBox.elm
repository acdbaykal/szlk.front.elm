module TranslationTypeSelectionBox exposing (render, OnChangeMsg, RenderFunction, OptionsData)

import Html exposing (Html, button, div, input, option, select, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode
import TranslationType exposing (TranslationType, toTranslationType)

type alias OptionTuple = (TranslationType, String)
type alias OptionsData = List OptionTuple
type alias OnChangeMsg a = (Maybe TranslationType -> a)
type alias RenderFunction a = OnChangeMsg a -> OptionsData -> Html a

renderDropBoxOption: OptionTuple -> Html a
renderDropBoxOption content =
    let
        (ttype, typeText) = content
    in
        option [value (toString ttype)][text typeText]


changeEventToType: Decode.Decoder (Maybe TranslationType)
changeEventToType =
    Decode.map toTranslationType (Decode.at [ "target", "value" ] Decode.string)

render: RenderFunction a
render onChangeTypeMsg typeBoxContent =
    let
        renderedOptions = (List.map renderDropBoxOption typeBoxContent)
    in
        select
            [on "change" (Decode.map onChangeTypeMsg changeEventToType)] renderedOptions
