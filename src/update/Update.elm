module Update exposing (update)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))
import SortDirection
import List
import String
import Dom
import Task
import Date exposing (Date)
import Maybe.Extra exposing(isJust)
import Translation exposing (Translation)
import TranslationType exposing (TranslationType(..))

removeTranslation : List Translation -> Translation -> List Translation
removeTranslation list translation =
    List.filter (\a -> a /= translation) list

addStubTranslation: List Translation -> String -> String -> TranslationType -> List Translation
addStubTranslation translations originText translationText translationType =
    List.concat [translations, [{
         id = Nothing
        ,originText = originText
        ,translationText = translationText
        ,translationType = translationType
        ,creationDate = Nothing
        ,editDate = Nothing
    }]]

onAddRequest: Maybe String -> Maybe String -> Maybe TranslationType -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
onAddRequest originTextMaybe translationTextMaybe translationTypeMaybe model =
    let
        mandatoryPresent = isJust originTextMaybe && isJust translationTextMaybe
        newModel =
            if mandatoryPresent
            then
                {
                    model | translations =
                        addStubTranslation
                            model.translations
                            (Maybe.withDefault "" originTextMaybe)
                            (Maybe.withDefault "" translationTextMaybe)
                            (Maybe.withDefault NOUN_MASK translationTypeMaybe)
                }
            else model
        newCommand =
            case mandatoryPresent of
                False -> Cmd.none
                True -> Task.perform UpdateDates Date.now

    in
        (newModel, newCommand)


nothingIfEmpty: String -> Maybe String
nothingIfEmpty str =
    if String.isEmpty (String.trim str) then Nothing else Just str

update: SzlkMsg -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
update msg model =
    case msg of
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
        DeleteRequest transl ->
            (
                {model | translations = removeTranslation model.translations transl},
                Cmd.none
            )

        UpdateDates currentDate ->
            (
                {model | translations =
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
                        model.translations
                }
                ,Cmd.none
            )
        UpdateTranslationAttempt parameter ->
            ({model | updateAttempt = Just parameter}, Task.attempt FocusResult (Dom.focus model.focusId))
        UpdateTranslationOriginText parameter ->
            (
               let
                   oldTranslation = parameter.translation
                   updatedTranslation = {oldTranslation | originText = parameter.value}
               in
                {model | translations =
                    List.map
                        (
                            \translation ->
                                if translation == parameter.translation
                                then {translation | originText = parameter.value}
                                else translation
                        )
                        model.translations
                 ,   updateAttempt = --keep reference to translation, which is beeing edited in sync
                        (
                            case model.updateAttempt of
                                Nothing -> Nothing
                                Just attemptData ->
                                    if parameter.translation == attemptData.translation
                                    then Just {attemptData | translation = updatedTranslation}
                                    else model.updateAttempt
                        )
                }
                ,Cmd.none
            )
        UpdateTranslationTranslationText parameter ->
            (
                let
                    oldTranslation = parameter.translation
                    updatedTranslation = {oldTranslation | translationText = parameter.value}
                in
                {model | translations =
                    List.map
                        (
                            \translation ->
                                if translation == parameter.translation
                                then updatedTranslation
                                else translation
                        )
                        model.translations
                ,   updateAttempt = --keep reference to translation, which is beeing edited in sync
                        (
                            case model.updateAttempt of
                                Nothing -> Nothing
                                Just attemptData ->
                                    if parameter.translation == attemptData.translation
                                    then Just {attemptData | translation = updatedTranslation}
                                    else model.updateAttempt
                        )
                }
                ,Cmd.none
            )
        UpdateTranslationType param ->
             (
                {model | translations =
                    List.map
                        (
                            \translation ->
                                let
                                    defaultType = translation.translationType
                                    ttype = if translation == param.translation
                                            then Maybe.withDefault defaultType param.value
                                            else defaultType
                                in
                                    {translation | translationType = ttype}
                        )
                        model.translations
                }
                ,Cmd.none
            )
        _ -> (model, Cmd.none)