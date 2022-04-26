module Main where

import API
import Lib

handler :: Ping -> ActionM ()
handler x = liftIO $ do
  print "OnPing"
  print x

main :: IO ()
main = eventingMain handler
