module Update exposing (update)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))

update: SzlkMsg -> SzlkModel -> SzlkModel
update msg model =
    case msg of
        SearchInputChanged value ->
            {model | searchInputValue = value}
        SortBy value ->
            {model | sortBy = value}
        _ -> model