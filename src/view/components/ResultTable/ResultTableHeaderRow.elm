module ResultTableHeaderRow exposing (render)

import Html exposing (Html, text, th, tr)
import Html.Events exposing (onClick)
import List
import ResultTableHeaderCellModel exposing (ResultTableHeaderCellModel)

renderSingleCell: ResultTableHeaderCellModel a -> Html a
renderSingleCell model = th[onClick model.message][text model.value]

render: List (ResultTableHeaderCellModel a)   -> Html a
render headerContentList =
    tr [] (List.map renderSingleCell headerContentList)