module Update exposing (update)

import SzlkModel exposing (SzlkModel)
import SzlkMsg exposing (SzlkMsg(..))
import List
import String
import Task
import Date exposing (Date)
import Translation exposing (Translation)
import TranslationType exposing (TranslationType)


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
        newModel =
            case originTextMaybe of
                Nothing -> model
                Just originText ->
                    case translationTextMaybe of
                        Nothing -> model
                        Just translationText ->
                            case translationTypeMaybe of
                                Nothing -> model
                                Just translationType ->
                                    {
                                        model | translations =
                                            addStubTranslation
                                                model.translations
                                                originText
                                                translationText
                                                translationType
                                    }
        result = if newModel /= model then
                     (
                         newModel,
                         Task.perform ThrowAwayError UpdateDates
                             (Task.toMaybe Date.now)
                     )
                 else
                     (newModel, Cmd.none)
    in
        result


nothingIfEmpty: String -> Maybe String
nothingIfEmpty str =
    if String.isEmpty (String.trim str) then Nothing else Just str

update: SzlkMsg -> SzlkModel -> (SzlkModel, Cmd SzlkMsg)
update msg model =
    case msg of
        SearchInputChanged value ->
            ({model | searchInputValue = value}, Cmd.none)
        SortBy value ->
            ({model | sortBy = value}, Cmd.none)
        AddRequestTranslationText value->
            ({model | addTranslationTranslationText = value}, Cmd.none)
        AddRequestOriginText value ->
            ({model | addTranslationOriginText = value}, Cmd.none)
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

        UpdateDates maybeCurrentDate ->
            (
                case maybeCurrentDate of
                    Nothing -> model
                    Just currentDate ->
                        {model | translations =
                            List.map
                                (
                                    \translation ->
                                        let
                                            maybeCreationDate = translation.creationDate
                                            maybeEditDate = translation.editDate
                                            update = \maybeDate ->
                                                case maybeDate of
                                                    Nothing -> maybeCurrentDate
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
        _ -> (model, Cmd.none)