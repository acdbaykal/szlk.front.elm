module TranslationSet exposing (TranslationSet, fromList, toList, empty, insert, map, remove, size, union)

import Translation exposing (Translation, TranslationId)
import Dict exposing (..)
import Tuple

type alias TranslationSet = Dict TranslationId Translation

empty: TranslationSet
empty = Dict.empty

isEmpty: TranslationSet -> Bool
isEmpty = Dict.isEmpty

size: TranslationSet -> Int
size = Dict.size

asTuple: Translation -> Maybe (TranslationId, Translation)
asTuple t =
    case t.id of
        Just id -> Just (id, t)
        Nothing -> Nothing

unTuple: (TranslationId , Translation) -> Translation
unTuple tuple = Tuple.second tuple

toList:TranslationSet -> List Translation
toList set = List.map unTuple (Dict.toList set)

fromList: List Translation -> TranslationSet
fromList list =
   Dict.fromList (List.filterMap asTuple list)


member: Translation -> TranslationSet -> Bool
member translation set =
    case translation.id of
                Just id -> Dict.member id set
                Nothing -> False

insert: Translation -> TranslationSet -> TranslationSet
insert translation set =
     case translation.id of
            Just id -> (Dict.insert id translation set)
            Nothing -> set

remove: Translation -> TranslationSet -> TranslationSet
remove translation set =
    case translation.id of
        Just id -> Dict.remove id set
        Nothing -> set

union: TranslationSet -> TranslationSet -> TranslationSet
union = Dict.union

intersect: TranslationSet -> TranslationSet -> TranslationSet
intersect = Dict.intersect

diff: TranslationSet -> TranslationSet -> TranslationSet
diff = Dict.diff

map: (Translation -> Translation) -> TranslationSet -> TranslationSet
map func set =
    let
        adaptor = \id translation -> func translation
    in
        Dict.map adaptor set

