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
                originText = "unhöflich",
                translationText = "kaba",
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

update: SzlkMsg -> SzlkModel -> SzlkModel
update = Update.update

view: SzlkModel -> Html SzlkMsg
view = AppViewRoot.render

main =
  App.beginnerProgram { model = model, view = view, update = update }
