module SearchArea exposing (SearchAreaModel, configure)

import Html exposing (Html, Attribute, button, div, input, p, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import String

type alias SearchAreaModel =
    {
        searchInputValue: String
    }


configure: (String -> a) -> a -> SearchAreaModel -> Html a
configure onInputChange onSearchRequest =
    \model -> div[]
                      [
                          input[placeholder "Search term", onInput onInputChange, value model.searchInputValue][]
                          , button[onClick onSearchRequest][text "Search"]
                      ]