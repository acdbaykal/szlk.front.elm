module ResultTableAdapter exposing (render)

import Html exposing (Html)
import Date exposing (Date)
import Date.Format
import List
import Maybe exposing (Maybe)
import SzlkMsg exposing (SzlkMsg(..))
import SzlkModel exposing (SzlkModel)
import Translation exposing (Translation)
import TranslationSet
import TranslationProperty exposing (TranslationProperty(..))
import TranslationType exposing (TranslationType(..))
import UpdateTranslationParameter exposing (UpdateTranslationParameter, UpdateTranslationAttemptParameter)
import SortDirection exposing (SortDirection)
import ResultTable
import ResultTableHeaderCellModel exposing (ResultTableHeaderCellModel)
import ResultTableHeaderRow
import ResultTableRow
import ResultAdminTableRow
import TranslationTypeSelectionBox

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


containsTerm : String -> Translation -> Bool
containsTerm term translation =
    let
        contains_ = String.contains term
    in
        contains_ translation.originText || contains_ translation.translationText

filerTranslations : String -> List Translation -> List Translation
filerTranslations term list =
    let
        filterFunc = \t ->
                let
                    contains = containsTerm term t
                in
                    case contains of
                        True -> Just t
                        False -> Nothing
    in
        List.filterMap filterFunc list

adaptModel: SzlkModel -> List Translation
adaptModel model =
    let
        asList = TranslationSet.toList model.translations
        filtered = filerTranslations model.searchInputValue asList
        concatenated = List.concat [model.addRequestedTranslations, filtered]
    in
        sortTranslations concatenated model


typeBoxContent = [ --TODO: eventually move this to the model, when ready to implement i18n features
                (NOUN_MASK, "Noun (mask.)")
               ,(NOUN_FEM, "Noun (fem.)")
               ,(NOUN_NEUT, "Noun (neut.)")
               ,(PREFIX, "Saying")
               ,(DIRECTIVE, "Directive")
               ,(VERB, "Verb")
               ,(PLURAL, "Plural")
               ,(ADJECTIVE, "Adjective")
    ]

translationTypeToString: TranslationType -> String
translationTypeToString ttype =
    case ttype of
        NOUN_MASK -> "Noun (mask.)"
        NOUN_FEM -> "Noun (fem.)"
        NOUN_NEUT -> "Noun (neut.)"
        PREFIX -> "Prefix"
        DIRECTIVE -> "Directive"
        VERB -> "Verb"
        PLURAL -> "Plural"
        ADJECTIVE -> "Adjective"

labelType: Translation -> String
labelType translation = translationTypeToString translation.translationType

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


defaultHeaderRow: Html SzlkMsg
defaultHeaderRow = ResultTableHeaderRow.render headerData

adminHeaderRow: Html SzlkMsg
adminHeaderRow = ResultTableHeaderRow.render adminHeaderData

renderRow: Translation -> Html SzlkMsg
renderRow = ResultTableRow.configure labelType

updateTranslationPropertyAttempt: TranslationProperty -> Translation -> SzlkMsg
updateTranslationPropertyAttempt property =
    \translation -> (UpdateTranslationAttempt
        {
            translation = translation,
            property = property
        })
updateOriginTextAttempt = updateTranslationPropertyAttempt OriginText
updateTranslationTextAttempt = updateTranslationPropertyAttempt TranslationText

adaptOnTranslationTypeChangeMsg : Translation -> TranslationTypeSelectionBox.OnChangeMsg SzlkMsg
adaptOnTranslationTypeChangeMsg translation =
        \maybeTranslationType ->
            UpdateTranslationType {
                translation = translation,
                property = Type,
                value = maybeTranslationType
        }

renderTypeSelectBox : TranslationTypeSelectionBox.OptionsData ->ResultAdminTableRow.RenderTypeSelectBoxFunction SzlkMsg
renderTypeSelectBox typeBoxContent translation =
    let
        onChangeMsg = (adaptOnTranslationTypeChangeMsg translation)
    in
        TranslationTypeSelectionBox.render onChangeMsg typeBoxContent (Just translation.translationType)


extractEditedProperty: SzlkModel -> Translation -> Maybe TranslationProperty
extractEditedProperty model translation =
    let
        updateAttemptData = model.updateAttempt
    in
        case updateAttemptData of
            Nothing -> Nothing
            Just data ->
                let
                    editedTranslation = data.translation
                    editedProperty = data.property
                in
                    if editedTranslation == translation then Just editedProperty else Nothing

createUpdateOriginTextMsg: Translation -> String -> SzlkMsg
createUpdateOriginTextMsg translation newOriginText =
    UpdateTranslationOriginText {
                                    translation = translation,
                                    property = OriginText,
                                    value = newOriginText
                                }

createUpdateTranslationTextMsg: Translation -> String -> SzlkMsg
createUpdateTranslationTextMsg translation translationText =
    UpdateTranslationTranslationText
        {
            translation = translation
        ,   property = TranslationText
        ,   value = translationText
        }

renderAdminRow: String -> ResultAdminTableRow.RenderTypeSelectBoxFunction SzlkMsg -> (TranslationType -> String) ->
                (Translation -> Maybe TranslationProperty) -> Translation -> Html SzlkMsg
renderAdminRow focusId renderFunc translationTypeToString getEditedProp translation =
        ResultAdminTableRow.render
                    formatDate
                    focusId
                    SzlkMsg.DeleteRequest
                    updateOriginTextAttempt
                    updateTranslationTextAttempt
                    SzlkMsg.UpdateRequest
                    createUpdateOriginTextMsg
                    createUpdateTranslationTextMsg
                    renderFunc
                    translationTypeToString
                    translation
                    (getEditedProp translation)

renderDefaultTable = ResultTable.render defaultHeaderRow renderRow
renderAdminTable: SzlkModel ->
                  ResultAdminTableRow.RenderTypeSelectBoxFunction SzlkMsg->
                  Html SzlkMsg
renderAdminTable model renderTypeSelectBox =
        ResultTable.render
            adminHeaderRow
            (renderAdminRow model.focusId renderTypeSelectBox translationTypeToString (extractEditedProperty model))
            (adaptModel model)


render: SzlkModel -> Html SzlkMsg
render model =
    case model.loggedIn of
        Nothing  -> renderDefaultTable (adaptModel model)
        Just account -> renderAdminTable model (renderTypeSelectBox typeBoxContent)
