module AddTranslationArea exposing (configure)

import Json.Decode as Decode
import Html exposing (Html, button, div, input, option, select, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (on, onClick, onInput)
import Html.Events.Extra exposing (targetValueIntParse)
import Translation exposing (Translation)
import TranslationType exposing (TranslationType, toTranslationType)

renderDropBoxOption: (TranslationType, String) -> Html a
renderDropBoxOption content =
    let
        (ttype, typeText) = content
    in
        option [value (toString ttype)][text typeText]


changeEventToType: Decode.Decoder (Maybe TranslationType)
changeEventToType =
    Decode.map toTranslationType (Decode.at [ "target", "value" ] Decode.string)

    --"targetValue" value ->Json.Decode.succeed (toTranslationType value)

configure: a ->
          (String -> a) ->
          (String -> a) ->
          (Maybe TranslationType -> a) ->
          List (TranslationType, String) ->
          (b -> Html a)
configure addRequestMsg
          onOriginChangeMsg
          onTranslationChangeMsg
          onChangeTypeMsg
          typeBoxContent =
    \model -> div[]
            [
                 input [placeholder "German", onInput onOriginChangeMsg][]
                ,input [placeholder "Turkish", onInput onTranslationChangeMsg][]
                ,select [on "change" (Decode.map onChangeTypeMsg changeEventToType)]
                    (List.map renderDropBoxOption typeBoxContent)
                ,button [onClick addRequestMsg][text "Add"]
            ]
