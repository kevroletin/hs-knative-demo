module Main where

import API
import Lib

handler :: Pong -> ActionM ()
handler x = liftIO $ do
  print "OnPong"
  print x

main :: IO ()
main = eventingMain handler
