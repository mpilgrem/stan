{- |
Copyright: (c) 2020 Kowainik
SPDX-License-Identifier: MPL-2.0
Maintainer: Kowainik <xrom.xkov@gmail.com>

Data types and functions for working with meta information.
-}

module Stan.NameMeta
    ( NameMeta (..)
    , moduleNameL

      -- * Comparison with 'Name'
    , compareNames
      -- * Smart constructors
    , mkBaseMeta
    , mkBaseListMeta
    , mkBaseOldListMeta
    ) where

import Module (moduleUnitId)
import Name (Name, nameModule, nameOccName)
import OccName (occNameString)
import Relude.Extra.Lens (Lens', lens, set)

import Stan.Core.ModuleName (ModuleName, fromGhcModule)


-- | Meta information about function/type.
data NameMeta = NameMeta
    { nameMetaPackage    :: !Text
    , nameMetaModuleName :: !ModuleName
    , nameMetaName       :: !Text
    } deriving stock (Show, Eq)


{- | Create 'NameMeta' for a function from the @base@ package and
unknown module.
-}
mkBaseMeta :: Text -> NameMeta
mkBaseMeta funName = NameMeta
    { nameMetaName       = funName
    , nameMetaModuleName = ""
    , nameMetaPackage    = "base"
    }

moduleNameL :: Lens' NameMeta ModuleName
moduleNameL = lens
    nameMetaModuleName
    (\nameMeta new -> nameMeta { nameMetaModuleName = new })

-- | Check if 'NameMeta' is identical to 'Name'.
compareNames :: NameMeta -> Name -> Bool
compareNames NameMeta{..} name =
    let occName = toText $ occNameString $ nameOccName name
        moduleName = fromGhcModule $ nameModule name
        package = show @Text $ moduleUnitId $ nameModule name
    in
           occName    == nameMetaName
        && moduleName == nameMetaModuleName
        && package    == nameMetaPackage

{- | Create 'NameMeta' for a function from the @base@ package and
the "GHC.List" module.
-}
mkBaseListMeta :: Text -> NameMeta
mkBaseListMeta = set moduleNameL "GHC.List" . mkBaseMeta

{- | Create 'NameMeta' for a function from the @base@ package and
the "Data.OldList" module.
-}
mkBaseOldListMeta :: Text -> NameMeta
mkBaseOldListMeta = set moduleNameL "Data.OldList" . mkBaseMeta
