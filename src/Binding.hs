{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Binding where

import Control.Lens
import Data.Map (Map)
import qualified Data.Map as Map
import ScopeSet
import Data.Text (Text)
import Data.Unique

import Binding.Info
import Phase
import Syntax.SrcLoc

newtype Binding = Binding Unique
  deriving (Eq, Ord)

instance Show Binding where
  show (Binding b) = "(Binding " ++ show (hashUnique b) ++ ")"

newtype BindingTable = BindingTable { _bindings :: Map Text [(ScopeSet, Binding, BindingInfo SrcLoc)] }
  deriving Show
makeLenses ''BindingTable

instance Semigroup BindingTable where
  b1 <> b2 = BindingTable $ Map.unionWith (<>) (view bindings b1) (view bindings b2)

instance Monoid BindingTable where
  mempty = BindingTable Map.empty

instance Phased BindingTable where
  shift i = over bindings (Map.map (map (over _1 (shift i))))

type instance Index BindingTable = Text
type instance IxValue BindingTable = [(ScopeSet, Binding, BindingInfo SrcLoc)]

instance Ixed BindingTable where
  ix x f (BindingTable bs) = BindingTable <$> ix x f bs

instance At BindingTable where
  at x f (BindingTable bs) = BindingTable <$> at x f bs
