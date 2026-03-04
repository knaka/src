module Entry (main) where

-- pcapriotti/optparse-applicative: Applicative option parser https://github.com/pcapriotti/optparse-applicative/?tab=readme-ov-file#quick-start

-- optparse-applicative: Utilities and combinators for parsing command line options https://hackage.haskell.org/package/optparse-applicative
import qualified Options.Applicative as Opts;

import Control.Monad;
import Data.List (sortOn)
import Text.Printf (printf)

import Command (CommandInfo(..))
import Commands (registerAll)

-- 各コマンドのパーサーを生成
mainOptParser :: Opts.Parser (IO ())
mainOptParser = Opts.subparser $ mconcat $ map mkCommand commands
  where
    mkCommand :: CommandInfo -> Opts.Mod Opts.CommandFields (IO ())
    mkCommand (CommandInfo {..}) =
      Opts.command cmdName (Opts.info cmdParser (Opts.progDesc cmdDesc))

commands :: [CommandInfo]
commands = registerAll [ CommandInfo "subcmds" "List subcommands" (pure subcmds) ]

-- サブコマンドの一覧を表示する関数
subcmds :: IO ()
subcmds = do
  mapM_ (\cmd -> printf "%s\t%s\n" (cmdName cmd) (cmdDesc cmd)) (sortOn cmdName commands)

main :: IO ()
-- execParser :: ParserInfo (IO ()) -> IO (IO ()) なので、`IO (IO())` は、コマンドラインをパースして IO() な関数（すでに引数適用済みのアクション）を返す。それを連鎖で実行するのが join
main = Control.Monad.join $ Opts.execParser $ Opts.info mainOptParser
  (  Opts.fullDesc
  <> Opts.progDesc "A sample Haskell CLI application"
  <> Opts.header "main-exe - a demo program"
  <> Opts.footer "For more info, run: main-exe subcmds"
  )
