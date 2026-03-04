module Greet (register) where

import qualified Options.Applicative as Opts;
import Command (CommandInfo(..))
import Text.Printf (printf)

greet :: String -> IO ()
greet = printf "Hello, %s!\n"

register :: [CommandInfo] -> [CommandInfo]
register cmds =
  CommandInfo
    "greet"
    "Greeting"
    (greet <$> Opts.argument Opts.str (Opts.metavar "NAME"))
  : cmds
