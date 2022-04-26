{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Lib
  ( sendMsg,
    servingMain,
    eventingMain,
    Msg (..),
    ActionM,
    liftIO,
  )
where

import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON (..), ToJSON (..), eitherDecode, encode)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.UUID as UUID
import qualified Data.UUID.V4 as UUID
import Network.HTTP.Client
import Network.Wai.Middleware.RequestLogger
import System.Environment (lookupEnv)
import System.IO (hPrint, stderr)
import Web.Scotty (ActionM, body, middleware, scotty)
import Web.Scotty.Trans (get, post)

data Msg a = Msg
  { msg_id :: Maybe ByteString,
    msg_source :: ByteString,
    msg_type :: ByteString,
    msg_body :: a
  }
  deriving (Eq, Ord, Show, Functor)

sendMsg' :: String -> String -> Msg ByteString -> IO ()
sendMsg' namespace broker Msg {..} = do
  let settings =
        managerSetProxy
          (proxyEnvironment Nothing)
          defaultManagerSettings
  man <- newManager settings
  uid <- maybe (UUID.toASCIIBytes <$> UUID.nextRandom) pure msg_id

  req' <-
    lookupEnv "BROKER_INGRESS_URL" >>= \case
      Nothing ->
        parseRequest $ "http://broker-ingress.knative-eventing.svc.cluster.local/" <> namespace <> "/" <> broker
      Just x ->
        parseRequest x

  let req =
        req'
          { requestHeaders =
              [ ("ce-id", uid),
                ("ce-type", msg_type),
                ("ce-source", msg_source),
                ("ce-specversion", "1.0"),
                ("Content-Type", "application/json"),
                ("Accept", "application/json")
              ],
            requestBody = RequestBodyBS msg_body,
            method = "POST"
          }
  httpLbs req man >>= print

sendMsg :: ToJSON a => Msg a -> ActionM ()
sendMsg x = liftIO $ sendMsg' "default" "example-broker" (fmap (LBS.toStrict . encode) x)

servingMain :: ActionM () -> IO ()
servingMain handler = scotty 8080 $ do
  middleware logStdoutDev
  get "/" handler

runHandler :: FromJSON a => (a -> ActionM ()) -> ActionM ()
runHandler act = do
  b <- body
  case eitherDecode b of
    Left e -> do
      liftIO $ hPrint stderr e
    Right x -> act x

eventingMain :: FromJSON a => (a -> ActionM ()) -> IO ()
eventingMain handler = scotty 8080 $ do
  middleware logStdoutDev
  post "/" (runHandler handler)
