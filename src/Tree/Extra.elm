module Tree.Extra exposing (..)

import Tree exposing (Tree)


find : (a -> Bool) -> Tree a -> Maybe (Tree a)
find predicate tree =
    let
        findHelper treeList =
            case treeList of
                [] ->
                    Nothing

                child :: rest ->
                    if predicate (Tree.label child) then
                        Just child

                    else
                        case findHelper rest of
                            Just elem ->
                                Just elem

                            Nothing ->
                                findHelper (Tree.children child)
    in
    findHelper (Tree.children tree)
