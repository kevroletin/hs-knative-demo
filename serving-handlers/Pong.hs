{-# LANGUAGE OverloadedStrings #-}

module Main where

import API
import Lib

main :: IO ()
main = servingMain $ do
  sendMsg $
    Msg
      { msg_id = Nothing,
        msg_source = "haskell-fn-pong",
        msg_type = "pong",
        msg_body = Pong "test"
      }
