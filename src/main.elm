import Html exposing (Html)
import Html.App as App
import Date exposing (Date)
--model related
import SzlkModel exposing (SzlkModel)
import SortDirection exposing (SortDirection(Ascending))
import TranslationProperty exposing (TranslationProperty(OriginText))
import Translation exposing (Translation)
import TranslationType exposing (TranslationType)
--update related
import SzlkMsg exposing (SzlkMsg)
import Update
--view related
import AppViewRoot

translations: List Translation
translations =
        [
            {
                translationType = TranslationType.NOUN_MASK,
                originText = "höflich",
                translationText = "nazik",
                creationDate = Date.fromTime 0,
                editDate = Date.fromTime 0
            },
            {
                translationType = TranslationType.NOUN_MASK,
                originText = "löwe",
                translationText = "aslan",
                creationDate = Date.fromTime 0,
                editDate = Date.fromTime 0
            }

        ]

model: SzlkModel
model = {
             searchInputValue = ""
            ,sortBy = OriginText
            ,sortDirection = Ascending
            ,translations = translations
        }

update: SzlkMsg -> SzlkModel -> ( SzlkModel, Cmd SzlkMsg )
update = Update.update

view: SzlkModel -> Html SzlkMsg
view = AppViewRoot.render

init : (SzlkModel, Cmd SzlkMsg)
init = (model, Cmd.none)

subscriptions : SzlkModel -> Sub SzlkMsg
subscriptions model =
  Sub.none

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }
