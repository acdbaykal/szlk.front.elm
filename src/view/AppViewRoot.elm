module AppViewRoot exposing (render)

import Html exposing (Html, div)
import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg)
import SearchAreaAdapter
import ResultTableAdapter
import AddTranslationAreaAdapter
import LoginFormAdapter
import View exposing (View(..))


renderSearch: SzlkModel -> Html SzlkMsg
renderSearch szlk_model = div[][
        SearchAreaAdapter.render szlk_model
        ,AddTranslationAreaAdapter.render szlk_model
        ,ResultTableAdapter.render szlk_model
    ]

renderLogin = LoginFormAdapter.render

render: SzlkModel -> Html SzlkMsg
render szlk_model =
    case szlk_model.activeView of
        Login -> renderLogin szlk_model
        _ -> renderSearch szlk_model
