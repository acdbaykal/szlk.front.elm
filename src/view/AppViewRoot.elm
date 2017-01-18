module AppViewRoot exposing (render)

import Html exposing (Html, div)
import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg)
import SearchAreaAdapter
import ResultTableAdapter
import AddTranslationAreaAdapter

render: SzlkModel -> Html SzlkMsg
render szlk_model =
    div[][
         SearchAreaAdapter.render szlk_model
        ,AddTranslationAreaAdapter.render szlk_model
        ,ResultTableAdapter.render szlk_model
    ]