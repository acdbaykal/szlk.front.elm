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

type alias TranslationPlus = {
            translation: Translation
        ,   editable: Bool
    }

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

sortByCreationDate: TranslationPlus -> TranslationPlus -> Order
sortByCreationDate a b = sortByDate a.translation.creationDate b.translation.creationDate

sortByEditDate: TranslationPlus -> TranslationPlus -> Order
sortByEditDate a b = sortByDate a.translation.editDate b.translation.editDate

sortByType: TranslationPlus -> TranslationPlus -> Order
sortByType a b = compare (labelType a.translation) (labelType b.translation)

getSortingFunction: TranslationProperty -> (List TranslationPlus -> List TranslationPlus)
getSortingFunction sortBy =
     case sortBy of
        OriginText -> List.sortBy (\tplus -> tplus.translation.originText)
        TranslationText -> List.sortBy (\tplus -> tplus.translation.translationText)
        Type -> List.sortWith sortByType
        CreationDate -> List.sortWith sortByCreationDate
        EditDate -> List.sortWith sortByEditDate

sortTranslations: List TranslationPlus -> SzlkModel -> List TranslationPlus
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

filterMapTranslations : String -> (Translation -> t) -> List Translation -> List t
filterMapTranslations term transform list =
    let
        filterMapFunc = \t ->
                let
                    contains = containsTerm term t
                in
                    case contains of
                        True -> Just (transform t)
                        False -> Nothing
    in
        List.filterMap filterMapFunc list

adaptModel: SzlkModel -> List TranslationPlus
adaptModel model =
    let
        enhanceTranslation e t = {translation = t, editable = e}
        addRequested = List.map (enhanceTranslation False) model.addRequestedTranslations
        asList = TranslationSet.toList model.translations
        filtered = filterMapTranslations model.searchInputValue (enhanceTranslation True) asList
        sorted = sortTranslations filtered model
    in
        List.concat [addRequested, sorted]


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

renderRow: TranslationPlus -> Html SzlkMsg
renderRow tplus=
    let
        render = ResultTableRow.configure labelType
    in
        render tplus.translation

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
                (Translation -> Maybe TranslationProperty) -> TranslationPlus -> Html SzlkMsg
renderAdminRow focusId renderFunc translationTypeToString getEditedProp translationPlus =
        ResultAdminTableRow.render
                    formatDate
                    focusId
                    SzlkMsg.DeleteRequest
                    updateOriginTextAttempt
                    updateTranslationTextAttempt
                    SzlkMsg.UpdateCancel
                    createUpdateOriginTextMsg
                    createUpdateTranslationTextMsg
                    renderFunc
                    translationTypeToString
                    translationPlus.translation
                    (getEditedProp translationPlus.translation)
                    translationPlus.editable

renderDefaultTable =
   ResultTable.render defaultHeaderRow renderRow

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
