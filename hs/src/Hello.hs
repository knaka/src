module Hello (register) where

import qualified Options.Applicative as Opts;
import Command (CommandInfo(..))

hello :: String -> IO ()
hello arg = putStrLn $ "Hi, " ++ arg ++ "!"

register :: [CommandInfo] -> [CommandInfo]
register cmds =
  CommandInfo
    "hello"
    "Say hello"
    (hello <$> Opts.argument Opts.str (Opts.metavar "NAME"))
  : cmds
