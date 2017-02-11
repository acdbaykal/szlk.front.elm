module AddTranslationArea exposing (configure)

import Json.Decode as Decode
import Html exposing (Html, button, div, input, option, select, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (on, onClick, onInput)
import Html.Events.Extra exposing (targetValueIntParse)
import Translation exposing (Translation)
import TranslationType exposing (TranslationType, toTranslationType)

configure: a ->
          (String -> a) ->
          (String -> a) ->
          (Html a -> b -> Html a)
configure addRequestMsg
          onOriginChangeMsg
          onTranslationChangeMsg =
    \ttypeBoxHtml model -> div[]
            [
                 input [placeholder "German", onInput onOriginChangeMsg][]
                ,input [placeholder "Turkish", onInput onTranslationChangeMsg][]
                ,ttypeBoxHtml
                ,button [onClick addRequestMsg][text "Add"]
            ]
