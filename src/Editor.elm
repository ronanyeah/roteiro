module Editor exposing (..)

import Types exposing (..)
import Utils


validate : (Id -> Form -> Result (List String) r) -> Editor { r | id : Id } -> Result (List String) r
validate fn e =
    case e of
        ReadOnly a ->
            Err []

        Editing f { id } ->
            fn id f


update : (Form -> Form) -> Editor a -> Editor a
update fn e =
    case e of
        Editing f a ->
            Editing (fn f) a

        a ->
            a


cancel : Editor a -> Editor a
cancel e =
    case e of
        Editing f a ->
            ReadOnly a

        a ->
            a


edit : Editor a -> Editor a
edit e =
    case e of
        ReadOnly a ->
            Editing Utils.emptyForm a

        a ->
            a
