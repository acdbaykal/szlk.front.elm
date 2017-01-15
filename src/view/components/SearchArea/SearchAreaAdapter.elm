module SearchAreaAdapter exposing (render)

import Html exposing (Html)
import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))
import SearchArea exposing (SearchAreaModel)

adapt: SzlkModel -> SearchAreaModel
adapt model =
    {
        searchInputValue = model.searchInputValue
    }


render: SzlkModel -> Html SzlkMsg
render model = (SearchArea.configure (\val -> SearchInputChanged val) SearchRequested) (adapt model)