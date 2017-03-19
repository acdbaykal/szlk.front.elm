module Update exposing (update)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))
import SortDirection
import Set exposing (Set)
import Platform.Cmd as Commands
import List
import String
import Dom
import Task
import Date exposing (Date)
import Maybe.Extra exposing(isJust)
import Translation exposing (Translation)
import TranslationType exposing (TranslationType(..))
import TranslationSet exposing (TranslationSet)
import View exposing (View)
import ServerConnection
import Translation exposing(Translation, TranslationId)

createStubTranslation: Int -> String -> String -> TranslationType -> Translation
createStubTranslation addId originText translationText translationType =
    {
        id = Just (toString addId)
        ,originText = originText
        ,originShort = Nothing
        ,translationText = translationText
        ,translationType = translationType
        ,creationDate = Nothing
        ,editDate = Nothing
    }

onAddRequest: Maybe String -> Maybe String -> Maybe TranslationType -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
onAddRequest originTextMaybe translationTextMaybe translationTypeMaybe model =
    let
        mandatoryPresent = isJust originTextMaybe && isJust translationTextMaybe
        addId = model.addId + 1
        stubTranslation = createStubTranslation
            addId
            (Maybe.withDefault "" originTextMaybe)
            (Maybe.withDefault "" translationTextMaybe)
            (Maybe.withDefault NOUN_MASK translationTypeMaybe)
        newModel =
            if mandatoryPresent
            then
                {
                    model | addId = addId,
                            addRequestedTranslations = List.append
                            model.addRequestedTranslations
                            [stubTranslation]
                }
            else model
        newCommand =
            case mandatoryPresent of
                False -> Cmd.none
                True -> Commands.batch
                    [Task.perform UpdateDates Date.now, ServerConnection.addTranslation model.host stubTranslation]

    in
        (newModel, newCommand)


nothingIfEmpty: String -> Maybe String
nothingIfEmpty str =
    if String.isEmpty (String.trim str) then Nothing else Just str


updateAfterSearch: TranslationSet -> List Translation -> TranslationSet
updateAfterSearch oldTranslations searchResults =
    let
        asSet = TranslationSet.fromList searchResults
    in
        TranslationSet.union oldTranslations asSet

update: SzlkMsg -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
update msg model =
    case msg of
        SearchRequested ->
            let
                searchTerm = model.searchInputValue
            in
                (model, ServerConnection.searchTranslation model.host searchTerm)
        SearchSuccess found->
            ({model | translations = (updateAfterSearch model.translations found)}, Cmd.none)
        SearchInputChanged value ->
            ({model | searchInputValue = value}, Cmd.none)
        SortBy value ->
            if value == model.sortBy then
                let
                    direction = case model.sortDirection of
                                    SortDirection.Ascending -> SortDirection.Descending
                                    SortDirection.Descending -> SortDirection.Ascending
                in
                    ({model | sortDirection = direction}, Cmd.none)
            else
                ({model | sortBy = value}, Cmd.none)
        AddRequestTranslationText value->
            (
                {model | addTranslationTranslationText = value},
                Cmd.none
            )
        AddRequestOriginText value ->
            (
                {model | addTranslationOriginText = value},
                Cmd.none
            )
        AddRequestTranslationType ttype ->
            ({model | addTranslationType = ttype}, Cmd.none)
        AddRequest ->
            onAddRequest
             (nothingIfEmpty model.addTranslationOriginText)
             (nothingIfEmpty model.addTranslationTranslationText)
             model.addTranslationType
             model

        AddSuccess beforeAdd afterAdd ->
            ({
                model |
                    translations = (TranslationSet.insert afterAdd model.translations)
                     , addRequestedTranslations = (List.filter (\t -> t.id /= beforeAdd.id) model.addRequestedTranslations)
            }, Cmd.none)

        DeleteRequest transl ->
            (
                {model | translations = TranslationSet.remove transl model.translations}
                ,ServerConnection.deleteTranslation model.host transl
            )
        PassWordChange pass->
            (
                {model | passInput = pass}, Cmd.none
            )
        KeyDown keyCode ->
            if keyCode == 96 then
                (
                    {model | activeView = View.Login}, Cmd.none
                )
            else
                (model, Cmd.none)
        UpdateDates currentDate ->
            (
                {model | addRequestedTranslations =
                    List.map
                        (
                            \translation ->
                                let
                                    maybeCreationDate = translation.creationDate
                                    maybeEditDate = translation.editDate
                                    update = \maybeDate ->
                                        case maybeDate of
                                            Nothing -> Just currentDate
                                            Just smDate -> Just smDate
                                    updatedCreationDate = update maybeCreationDate
                                    updatedEditDate = update maybeEditDate
                                in
                                {translation | creationDate = updatedCreationDate, editDate = updatedEditDate}
                        )
                        model.addRequestedTranslations
                }
                ,Cmd.none
            )
        UpdateTranslationAttempt parameter ->
            ({model | updateAttempt = Just parameter}, Task.attempt FocusResult (Dom.focus model.focusId))
        UpdateTranslationOriginText parameter ->
           let
               oldTranslation = parameter.translation
               updatedTranslation = {oldTranslation | originText = parameter.value}
               command = ServerConnection.updateTranslation model.host updatedTranslation
           in
            (
                {model | translations = TranslationSet.insert updatedTranslation model.translations
--                ,   updateAttempt = --keep reference to translation, which is being edited in sync
--                        (
--                            case model.updateAttempt of
--                                Nothing -> Nothing
--                                Just attemptData ->
--                                    if parameter.translation == attemptData.translation
--                                    then Just {attemptData | translation = updatedTranslation}
--                                    else model.updateAttempt
--                        )
                ,   updateAttempt = Nothing
                }
                ,command
            )
        UpdateTranslationTranslationText parameter ->
            let
                oldTranslation = parameter.translation
                updatedTranslation = {oldTranslation | translationText = parameter.value}
                command = ServerConnection.updateTranslation model.host updatedTranslation
            in
            (
                {model | translations = TranslationSet.insert updatedTranslation model.translations
--                ,   updateAttempt = --keep reference to translation, which is beeing edited in sync
--                        (
--                            case model.updateAttempt of
--                                Nothing -> Nothing
--                                Just attemptData ->
--                                    if parameter.translation == attemptData.translation
--                                    then Just {attemptData | translation = updatedTranslation}
--                                    else model.updateAttempt
--                        )
                ,   updateAttempt = Nothing
                }
                ,command
            )
        UpdateTranslationType parameter ->
            let
                oldTranslation = parameter.translation
                valueMaybe = parameter.value
            in
            case valueMaybe of
                Nothing -> (model, Cmd.none)
                Just value ->
                    let
                        updatedTranslation = {oldTranslation | translationType = value}
                        command = ServerConnection.updateTranslation model.host updatedTranslation
                    in
                    (
                        {model | translations = (
                            TranslationSet.map (\t ->
                                if t.id == updatedTranslation.id
                                then updatedTranslation
                                else t
                            ) model.translations
                        )}
                        , command
                    )
        UpdateRequest translation ->
            (
                model,  ServerConnection.updateTranslation model.host translation
            )
--        UpdateTranslationType param ->
--             (
--                {model | translations =
--                    List.map
--                        (
--                            \translation ->
--                                let
--                                    defaultType = translation.translationType
--                                    ttype = if translation == param.translation
--                                            then Maybe.withDefault defaultType param.value
--                                            else defaultType
--                                in
--                                    {translation | translationType = ttype}
--                        )
--                        model.translations
--                }
--                ,Cmd.none
--            )
        UserNameChange userName ->
            ({model | userNameInput = userName}, Cmd.none)
        _ -> (model, Cmd.none)