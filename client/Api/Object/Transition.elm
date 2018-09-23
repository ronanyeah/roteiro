-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql
module Api.Object.Transition exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Object as Object
import Graphql.SelectionSet exposing (SelectionSet)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Api.Object
import Api.Interface
import Api.Union
import Api.Scalar
import Api.InputObject
import Json.Decode as Decode
import Graphql.Internal.Encode as Encode exposing (Value)



{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) Api.Object.Transition
selection constructor =
    Object.selection constructor
{-| 
-}
id : Field Api.Scalar.Id Api.Object.Transition
id =
      Object.fieldDecoder "id" [] (Object.scalarDecoder |> Decode.map Api.Scalar.Id)


{-| 
-}
name : Field String Api.Object.Transition
name =
      Object.fieldDecoder "name" [] (Decode.string)


{-| 
-}
steps : Field (List String) Api.Object.Transition
steps =
      Object.fieldDecoder "steps" [] (Decode.string |> Decode.list)


{-| 
-}
notes : Field (List String) Api.Object.Transition
notes =
      Object.fieldDecoder "notes" [] (Decode.string |> Decode.list)


{-| 
-}
startPosition : SelectionSet decodesTo Api.Object.Position -> Field decodesTo Api.Object.Transition
startPosition object_ =
      Object.selectionField "startPosition" [] (object_) (identity)


{-| 
-}
endPosition : SelectionSet decodesTo Api.Object.Position -> Field decodesTo Api.Object.Transition
endPosition object_ =
      Object.selectionField "endPosition" [] (object_) (identity)


{-| 
-}
tags : SelectionSet decodesTo Api.Object.Tag -> Field (List decodesTo) Api.Object.Transition
tags object_ =
      Object.selectionField "tags" [] (object_) (identity >> Decode.list)
