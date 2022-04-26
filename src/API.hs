{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}

module API
  ( Ping (..),
    Pong (..),
  )
where

import Data.Aeson
import GHC.Generics

newtype Ping = Ping String deriving (Generic, Show)

newtype Pong = Pong String deriving (Generic, Show)

deriving instance FromJSON Ping

deriving instance FromJSON Pong

deriving instance ToJSON Ping

deriving instance ToJSON Pong
