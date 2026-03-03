module Main (main) where

-- pcapriotti/optparse-applicative: Applicative option parser https://github.com/pcapriotti/optparse-applicative/?tab=readme-ov-file#quick-start

-- optparse-applicative: Utilities and combinators for parsing command line options https://hackage.haskell.org/package/optparse-applicative
import qualified Options.Applicative as Opts;

import Control.Monad;

-- import Data.Semigroup ((<>))

-- 各サブコマンドの情報を保持するデータ型を定義
data CommandInfo = CommandInfo
  { cmdName :: String
  , cmdDesc :: String
  , cmdParser :: Opts.Parser (IO ())
  }

-- サブコマンドの定義をリストで管理
commands :: [CommandInfo]
commands =
  [ CommandInfo "greet" "Say hello" (greet <$> Opts.argument Opts.str (Opts.metavar "NAME"))
  , CommandInfo "subcmds" "List subcommands" (pure subcmds)
  ]

-- 各コマンドのパーサーを生成
opts :: Opts.Parser (IO ())
opts = Opts.subparser $ mconcat $ map mkCommand commands
  where
    mkCommand :: CommandInfo -> Opts.Mod Opts.CommandFields (IO ())
    mkCommand (CommandInfo { cmdName = name, cmdDesc = desc, cmdParser = parser }) =
      Opts.command name (Opts.info parser (Opts.progDesc desc))

greet :: String -> IO ()
greet arg = putStrLn $ "Hello, " ++ arg ++ "!"

-- サブコマンドの一覧を表示する関数
subcmds :: IO ()
subcmds = do
  mapM_ (\cmd -> putStrLn $ cmdName cmd ++ "\t" ++ cmdDesc cmd) commands

main :: IO ()
main = Control.Monad.join $ Opts.execParser (Opts.info opts Opts.idm)
