module ResultTableAdapter exposing (render)

import Html exposing (Html)
import Date exposing (Date)
import Date.Format
import List
import Maybe exposing (Maybe)
import SzlkMsg exposing (SzlkMsg(SortBy))
import SzlkModel exposing (SzlkModel)
import Translation exposing (Translation)
import TranslationProperty exposing (TranslationProperty(..))
import TranslationType exposing (TranslationType(..))
import SortDirection exposing (SortDirection)
import ResultTable
import ResultTableHeaderCellModel exposing (ResultTableHeaderCellModel)
import ResultTableHeaderRow
import ResultTableRow
import ResultAdminTableRow

formatDate: Maybe Date -> String
formatDate date =
    case date of
        Just d -> Date.Format.format "%d.%m.%Y / %H:%M" d
        Nothing -> ""

sortByDate: Maybe Date -> Maybe Date -> Order
sortByDate a b =
    case a of
        Just dateA ->
            case b of
                Just dateB -> compare (Date.toTime dateA) (Date.toTime dateB)
                Nothing -> LT
        Nothing ->
            case b of
                    Just dateB -> GT
                    Nothing -> EQ

sortByCreationDate: Translation -> Translation -> Order
sortByCreationDate a b = sortByDate a.creationDate b.creationDate

sortByEditDate: Translation -> Translation -> Order
sortByEditDate a b = sortByDate a.editDate b.editDate

sortByType: Translation -> Translation -> Order
sortByType a b = compare (labelType a) (labelType b)

getSortingFunction: TranslationProperty -> (List Translation -> List Translation)
getSortingFunction sortBy =
     case sortBy of
        OriginText -> List.sortBy .originText
        TranslationText -> List.sortBy .translationText
        Type -> List.sortWith sortByType
        CreationDate -> List.sortWith sortByCreationDate
        EditDate -> List.sortWith sortByEditDate
        --_ -> \a -> a

sortTranslations: List Translation -> SzlkModel -> List Translation
sortTranslations translations model =
    let
        sortFunction = getSortingFunction model.sortBy
        sortedList = sortFunction translations
        sortDirection = model.sortDirection
    in
        case sortDirection of
            SortDirection.Ascending -> sortedList
            SortDirection.Descending -> List.reverse sortedList

adaptModel: SzlkModel -> List Translation
adaptModel model = sortTranslations model.translations model

labelType: Translation -> String
labelType translation =
    let
        ttype = translation.translationType
    in
        case ttype of
            NOUN_MASK -> "Noun (mask.)"
            NOUN_FEM -> "Noun (fem.)"
            NOUN_NEUT -> "Noun (neut.)"
            SAYING -> "Saying"
            DIRECTIVE -> "Directive"
            VERB -> "Verb"

headerData =
    [
         {message = SortBy OriginText, value = "German"}
        ,{message = SortBy TranslationText, value = "Turkish"}
        ,{message = SortBy Type, value = "Type"}

    ]

adminHeaderData =
    List.concat
        [
            headerData
            ,[
                 {message = SortBy CreationDate, value = "Creation date"}
                ,{message = SortBy EditDate, value = "Editing date"}
            ]
        ]


renderHeader: Html SzlkMsg
renderHeader = ResultTableHeaderRow.render headerData

renderAdminHeader: Html SzlkMsg
renderAdminHeader = ResultTableHeaderRow.render adminHeaderData

renderRow: Translation -> Html SzlkMsg
renderRow = ResultTableRow.configure labelType

renderAdminRow: Translation -> Html SzlkMsg
renderAdminRow = ResultAdminTableRow.configure labelType formatDate SzlkMsg.DeleteRequest

renderDefaultTable = ResultTable.configure renderHeader renderRow
renderAdminTable = ResultTable.configure renderAdminHeader renderAdminRow

render: SzlkModel -> Html SzlkMsg
render model =
    case model.loggedIn of
        Nothing  -> renderDefaultTable (adaptModel model)
        Just account -> renderAdminTable (adaptModel model)
