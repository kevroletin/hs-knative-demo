{-# LANGUAGE OverloadedStrings #-}

module Main where

import            Lib
import            Data.Maybe         (fromMaybe)
import            Data.Monoid        ((<>))
import qualified  Data.Text.Lazy as T
import            System.Environment (lookupEnv)
import            System.IO          (hPrint, stderr)
import            Web.Scotty         (ActionM, ScottyM, scotty, body, middleware)
import            Web.Scotty.Trans   (html, get, post)
import            Control.Monad.IO.Class (liftIO)
import            Network.Wai.Middleware.RequestLogger

main :: IO ()
main = scotty 8080 $ do
  middleware logStdoutDev
  post "/" printReqBody

printReqBody :: ActionM()
printReqBody = do
  b <- body
  liftIO $ do
    print "OnPong"
    hPrint stderr b
