module ResultTableHeaderRow exposing (configure)

import Html exposing (Html, text, th, tr)
import Html.Events exposing (onClick)
import List
import ResultTableHeaderCellModel exposing (ResultTableHeaderCellModel)

renderSingleCell: ResultTableHeaderCellModel a -> Html a
renderSingleCell model = th[onClick model.message][text model.value]

configure: List (ResultTableHeaderCellModel a)   -> Html a
configure headerContentList =
    tr [] (List.map renderSingleCell headerContentList)