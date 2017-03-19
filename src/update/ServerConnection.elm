module ServerConnection exposing (addTranslation, deleteTranslation, searchTranslation, updateTranslation)

import View exposing (View)
import Http
import Json.Encode as Encode
import Json.Decode as Decode  exposing (..)
import Translation exposing (Translation, TranslationId)
import TranslationType exposing (TranslationType)
import Date exposing (..)
import Date.Extra exposing (toIsoString)
import Dict
import SzlkMsg exposing (SzlkMsg(..))
import SHA exposing (sha256sum)
import Task exposing (Task)


type alias Origin =
    {
        main: String
        ,short: Maybe String
    }

encodeTranslationType: TranslationType -> Value
encodeTranslationType ttype =
    let
        asString = case ttype of
            TranslationType.VERB -> "v"
            TranslationType.NOUN_NEUT -> "s"
            TranslationType.NOUN_MASK -> "r"
            TranslationType.NOUN_FEM -> "e"
            TranslationType.PLURAL -> "pl"
            TranslationType.ADJECTIVE -> "aj"
            TranslationType.PREFIX -> "pre"
            TranslationType.DIRECTIVE -> "d"
    in
        Encode.string asString


encodeOrigin: String -> Maybe String -> Value
encodeOrigin main short =
    let
        mainTuple = ("main", Encode.string main)
        encodable =
            case short of
                Nothing -> [mainTuple]
                Just val -> [("short", Encode.string val), mainTuple]
    in
        Encode.object encodable


encodeDate: Date -> Value
encodeDate date = Encode.string (toIsoString date)

resolveMaybeValue: (a -> Value) -> String -> Maybe a -> List (String, Value)
resolveMaybeValue encoder propertyName maybeVal =
    case maybeVal of
        Nothing -> []
        Just val -> [(propertyName, (encoder val))]



encodeRequestBody: Maybe TranslationId -> Translation -> Value
encodeRequestBody assignedId translation =
    let
        id = resolveMaybeValue Encode.string "_id" assignedId
        resolveMaybeDate = resolveMaybeValue encodeDate
        creationDate = resolveMaybeDate "creationDate" translation.creationDate
        editDate = resolveMaybeDate "editDate" translation.editDate
        withoutMaybe = [
                 ("origin", encodeOrigin translation.originText translation.originShort)
                 ,("translation", Encode.string translation.translationText)
                 ,("type", encodeTranslationType translation.translationType)
             ]

        encodableTranslation = List.concat [id, creationDate, editDate, withoutMaybe]
        encodableBody =
            [
                ("translations", Encode.object encodableTranslation)
                ,("user", Encode.string "test")
                ,("pass", Encode.string "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08")
            ]

    in
        Encode.object encodableBody

encodeAddRequestBody = encodeRequestBody Nothing
encodeDeleteRequestBody translation = encodeRequestBody translation.id translation
encodeUpdateRequestBody translation = encodeRequestBody translation.id translation

composeTranslation:
    TranslationId -> Origin -> TranslationType-> String -> Date -> Date -> Translation
composeTranslation id origin translationType translationText creationDate editDate =
    {
        id = Just id
        ,originText = origin.main
        ,originShort = origin.short
        ,translationText = translationText
        ,translationType = translationType
        ,creationDate = Just creationDate
        ,editDate = Just editDate
    }

translationType : Decoder TranslationType
translationType =
            string |> andThen(\typeStr ->
                case typeStr of
                    "v" -> succeed TranslationType.VERB
                    "s" -> succeed TranslationType.NOUN_NEUT
                    "r" -> succeed TranslationType.NOUN_MASK
                    "e" -> succeed TranslationType.NOUN_FEM
                    "pl" -> succeed TranslationType.PLURAL
                    "aj" -> succeed TranslationType.ADJECTIVE
                    "d" -> succeed TranslationType.DIRECTIVE
                    "pre" -> succeed TranslationType.PREFIX
                    _ -> fail  typeStr -- the value does not matter in this case
            )

origin: Decoder Origin
origin= map2 Origin
    (field "main" string)
    (maybe (field "short" string))



date: Decoder Date
date =
    string |> andThen(\dateStr ->
                let
                    dateResult = Date.fromString dateStr
                in
                    case dateResult of
                        Ok date -> succeed date
                        Err err -> fail err
            )

translation: Decode.Decoder Translation
translation = Decode.map6 composeTranslation
        (field "_id" string)
        (field "origin" origin)
        (field "type" translationType)
        (field "translation" string)
        (field "creationDate" date)
        (field "editDate" date)

createBadPayLoadError: String -> String -> Http.Error
createBadPayLoadError url msg =
    Http.BadPayload msg {
        url = url
        ,status = {code = 200, message = msg}
        ,headers = Dict.empty
        ,body = "[]"
    }


convertAddOrUpdateResult: (Translation -> Translation -> SzlkMsg) ->
    (Translation -> Http.Error -> SzlkMsg) -> (String -> Http.Error) -> Translation -> Result Http.Error (List Translation) -> SzlkMsg
convertAddOrUpdateResult successMsg errMsg createBadPayLoadError sendTranslation result =
    case result of
            Err err -> errMsg sendTranslation err
            Ok foundList ->  (
                    case List.head foundList of
                        Nothing -> errMsg sendTranslation (createBadPayLoadError "Got back an empty Array")
                        Just added -> successMsg sendTranslation added
                )

convertAddResult = convertAddOrUpdateResult SzlkMsg.AddSuccess SzlkMsg.AddFail

convertUpdateResult = convertAddOrUpdateResult SzlkMsg.UpdateSuccess SzlkMsg.UpdateFail

convertDeleteResult: (String -> Http.Error) -> Translation -> Result Http.Error (String) -> SzlkMsg
convertDeleteResult createBadPayLoadError sendTranslation result =
    case result of
        Err err -> SzlkMsg.DeleteFail sendTranslation err
        Ok foundList ->  SzlkMsg.DeleteSuccess sendTranslation

convertSearchResult: Result Http.Error (List Translation) -> SzlkMsg
convertSearchResult result =
    case result of
        Err err -> SzlkMsg.SearchFail err
        Ok found -> SzlkMsg.SearchSuccess found

searchTranslation: String -> String -> Cmd SzlkMsg
searchTranslation host searchTerm =
    let
        url = host ++ "/translations/" ++ searchTerm
        request =  Http.get url (list translation)
    in
        Http.send convertSearchResult request


addOrUpdateTranslation:
    (Translation -> Value) ->
    ((String -> Http.Error) -> Translation -> Result Http.Error (List Translation) -> SzlkMsg) ->
    String -> Translation -> Cmd SzlkMsg
addOrUpdateTranslation encodeBody convertResult host translArg =
    let
            url = host ++ "/translations/"
            encoded = encodeBody translArg
            body = Http.jsonBody encoded
            request = Http.post url body (list translation)
        in
            Http.send (convertResult (createBadPayLoadError url) translArg) request

addTranslation = addOrUpdateTranslation encodeAddRequestBody convertAddResult

updateTranslation = addOrUpdateTranslation encodeUpdateRequestBody convertUpdateResult

deleteTranslation: String -> Translation -> Cmd SzlkMsg
deleteTranslation host translArg =
    let
        url = host ++ "/translations/"
        encoded = encodeDeleteRequestBody translArg
        body = Http.jsonBody encoded
        request = Http.request
            {
                method = "DELETE"
            ,   headers = []
            ,   url = url
            ,   body = body
            ,   expect = Http.expectString
            ,   timeout = Nothing
            ,   withCredentials = False
            }
    in
        Http.send (convertDeleteResult (createBadPayLoadError url) translArg) request