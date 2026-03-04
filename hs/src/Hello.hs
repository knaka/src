module Hello (commandInfo) where

import Command

hello :: IO ()
hello = putStrLn "Hello"

commandInfo :: Command.Info
commandInfo = Command.Info
  { name = "hs-hello"
  , desc = "Say hello"
  , parser = pure hello
  }
