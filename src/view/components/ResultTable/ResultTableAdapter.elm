module ResultTableAdapter exposing (render)

import Html exposing (Html)
import Date exposing (Date)
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

sortByDate: Date -> Date -> Order
sortByDate a b = compare (Date.toTime a) (Date.toTime b)

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

renderHeader: Html SzlkMsg
renderHeader = ResultTableHeaderRow.configure headerData

renderRow: Translation -> Html SzlkMsg
renderRow = ResultTableRow.configure labelType

renderDefaultTable = ResultTable.configure renderHeader renderRow

render: SzlkModel -> Html SzlkMsg
render model = renderDefaultTable (adaptModel model)
