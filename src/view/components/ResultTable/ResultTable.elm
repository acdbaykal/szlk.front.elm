module ResultTable exposing (configure)

import Html exposing (Html, table)
import List
import Translation exposing (Translation)

configure:  Html a -> (b -> Html a) -> List b -> Html a
configure tableHeader renderRow =
    \results -> table[]
        (List.concat [[tableHeader], (List.map renderRow results)])
