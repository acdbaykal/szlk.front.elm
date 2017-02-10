module ResultTable exposing (render)

import Html exposing (Html, table)
import List

render:  Html a -> (b -> Html a) -> List b -> Html a
render tableHeader renderRow rowDataList =
    table[]
        (List.concat [[tableHeader], (List.map renderRow rowDataList)])
