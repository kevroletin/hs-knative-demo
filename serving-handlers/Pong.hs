{-# LANGUAGE OverloadedStrings #-}

module Main where

import Network.HTTP.Client
import Lib

import            Data.Maybe         (fromMaybe)
import            Data.Monoid        ((<>))
import qualified  Data.Text.Lazy as T
import            System.Environment (lookupEnv)
import            System.IO          (hPrint, stderr)
import            Web.Scotty         (ActionM, ScottyM, scotty, body, middleware)
import            Web.Scotty.Trans   (html, get, post)
import            Control.Monad.IO.Class (liftIO)
import            Network.Wai.Middleware.RequestLogger
import qualified  Data.UUID.V4 as UUID
import qualified  Data.UUID as UUID

sendMsg :: String -> String -> IO ()
sendMsg namespace broker = do
    let settings = managerSetProxy
            (proxyEnvironment Nothing)
            defaultManagerSettings
    man <- newManager settings
    uuid <- UUID.toASCIIBytes <$> UUID.nextRandom

    -- let req' = "http://localhost:1234"
    req' <- parseRequest $ "http://broker-ingress.knative-eventing.svc.cluster.local/" <> namespace <> "/" <> broker
    let req = req'
              { requestHeaders = [
                  ("ce-id", uuid)
                , ("ce-type", "ping")
                , ("ce-source", "serving-handler-ping")
                , ("ce-specversion", "1.0")
                , ("Content-Type", "application/json")
                , ("Accept", "application/json")
                ]
              , requestBody = "{\"message\": \"Pong\"}"
              , method = "POST"
              }
    httpLbs req man >>= print

main :: IO ()
main = scotty 8080 $ do
  middleware logStdoutDev
  get "/" $ liftIO (sendMsg "default" "example-broker")
