module Greet (commandInfo) where

import qualified Options.Applicative as Opts;
import Control.Monad (when)
import Command
import Text.Printf (printf)

greet :: String -> Bool -> IO ()
greet name verbose = do
  when verbose $ putStrLn "Verbose message"
  printf "Hello, %s!\n" name

commandInfo :: Command.Info
commandInfo = Command.Info { name = "hs-greet"
  , desc = "Greeting"
  , parser = greet <$> Opts.argument Opts.str (Opts.metavar "NAME")
      <*> Opts.switch (Opts.long "verbose"
        <> Opts.short 'v'
        <> Opts.help "Verbose output"
      )
}
