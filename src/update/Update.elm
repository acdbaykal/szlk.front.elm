module Update exposing (update)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))
import List
import Translation exposing (Translation)


removeTranslation : List Translation -> Translation -> List Translation
removeTranslation list translation =
    List.filter (\a -> a /= translation) list

update: SzlkMsg -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
update msg model =
    case msg of
        SearchInputChanged value ->
            ({model | searchInputValue = value}, Cmd.none)
        SortBy value ->
            ({model | sortBy = value}, Cmd.none)
        DeleteRequest transl ->
            (
                {model | translations = removeTranslation model.translations transl},
                Cmd.none
            )
        _ -> (model, Cmd.none)