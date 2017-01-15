module ResultTableRow exposing (configure)

import Html exposing (Html, text, tr, td)
import Translation exposing (Translation)

configure: (Translation -> String) -> Translation -> Html a
configure labelType =
    \model -> tr[]
                    [
                        td[][text model.originText]
                       ,td[][text model.translationText]
                       ,td[][text (labelType model)]
                    ]