{-# LANGUAGE OverloadedStrings #-}

module Main where

import API
import Lib

main :: IO ()
main = servingMain $ do
  sendMsg $
    Msg
      { msg_id = Nothing,
        msg_source = "haskell-fn-ping",
        msg_type = "ping",
        msg_body = Ping "test"
      }
