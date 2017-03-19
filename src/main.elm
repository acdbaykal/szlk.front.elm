module Szlk exposing(..)
import Html exposing (Html)
import Navigation
import Date exposing (Date)
import View exposing (View)
import TimeTravel.Html as TimeTravel
--model related
import SzlkModel exposing (SzlkModel)
import SortDirection exposing (SortDirection(Ascending))
import TranslationProperty exposing (TranslationProperty(OriginText))
import Translation exposing (Translation)
import TranslationType exposing (TranslationType)
import TranslationSet exposing (TranslationSet)
--update related
import SzlkMsg exposing (SzlkMsg)
import Update
--view related
import AppViewRoot
--subscription related
import Keyboard

translations: TranslationSet
translations = TranslationSet.fromList
        [
            {

                id = Just "8271989",
                translationType = TranslationType.NOUN_MASK,
                originText = "höflich",
                originShort = Nothing,
                translationText = "nazik",
                creationDate = Just (Date.fromTime 60000),
                editDate = Just (Date.fromTime 0)
            },
            {
                id = Just "7686860",
                translationType = TranslationType.NOUN_MASK,
                originText = "löwe",
                originShort = Nothing,
                translationText = "aslan",
                creationDate = Just (Date.fromTime 0),
                editDate = Just (Date.fromTime 60000)
            }

        ]

model: SzlkModel
model = {
            activeView = View.Search
            ,addId = 0
            ,addRequestedTranslations = []
            ,addTranslationTranslationText = ""
            ,addTranslationOriginText = ""
            ,addTranslationType = Nothing
            ,focusId = "dknjasdflnjaswlkaswlasdfklasnkdeslfgnslgnkaslernlgnl983472913423l2klkl"
            ,history = []
            ,host = "http://localhost:3000"
            ,routes = [
                    (View.Search, "/search")
                    ,(View.Admin, "/admin")
                    ,(View.Login, "/login")
                ]
            ,loggedIn = (Just {passWord = "pass"})
            ,passInput = ""
            ,searchInputValue = ""
            ,sortBy = OriginText
            ,sortDirection = Ascending
            ,translations = translations
            ,updateAttempt = Nothing
            ,userNameInput = ""
        }

update: SzlkMsg -> SzlkModel -> ( SzlkModel, Cmd SzlkMsg )
update = Update.update

view: SzlkModel -> Html SzlkMsg
view = AppViewRoot.render

init : (SzlkModel, Cmd SzlkMsg)
init = (model, Cmd.none)

urlMsgConvert : Navigation.Location -> SzlkMsg
urlMsgConvert location = SzlkMsg.UrlUpdate location

createModel : Navigation.Location -> (SzlkModel, Cmd SzlkMsg)
createModel location = ({model | history = [location]}, Cmd.none)

subscriptions : SzlkModel -> Sub SzlkMsg
--subscriptions model = Keyboard.downs SzlkMsg.KeyDown
subscriptions model = Sub.none

--main = Navigation.program urlMsgConvert
--   { init = createModel, view = view, update = update, subscriptions = subscriptions }

main =
  TimeTravel.program { init = init, view = view, update = update, subscriptions = subscriptions }
