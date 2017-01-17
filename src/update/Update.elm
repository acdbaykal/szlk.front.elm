module Update exposing (update)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))

update: SzlkMsg -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
update msg model =
    case msg of
        SearchInputChanged value ->
            ({model | searchInputValue = value}, Cmd.none)
        SortBy value ->
            ({model | sortBy = value}, Cmd.none)
        _ -> (model, Cmd.none)