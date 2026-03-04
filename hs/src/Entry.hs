module Entry (main) where

-- pcapriotti/optparse-applicative: Applicative option parser https://github.com/pcapriotti/optparse-applicative/?tab=readme-ov-file#quick-start

-- optparse-applicative: Utilities and combinators for parsing command line options https://hackage.haskell.org/package/optparse-applicative
import qualified Options.Applicative as Opts;

import Control.Monad;
import Data.List (sortOn)
import Text.Printf (printf)

import Command
import Commands

-- 各コマンドのパーサーを生成
mainOptParser :: Opts.Parser (IO ())
mainOptParser = Opts.subparser $ mconcat $ map mkCmdParser commandInfoList
  where
    mkCmdParser (Command.Info {..}) =
      Opts.command name (Opts.info (parser Opts.<**> Opts.helper) (Opts.progDesc desc))

commandInfoList :: [Command.Info]
commandInfoList = Commands.registerAll
  [ Command.Info "subcmds" "List subcommands" (pure subcmds) ]

-- サブコマンドの一覧を表示する関数
subcmds :: IO ()
subcmds = do
  mapM_
    (\cmdInfo -> printf "%s\t%s\n" (name cmdInfo) (desc cmdInfo))
    (sortOn name commandInfoList)

main :: IO ()
-- execParser :: ParserInfo (IO ()) -> IO (IO ()) なので、`IO (IO())` は、コマンドラインをパースして IO() な関数（すでに引数適用済みのアクション）を返す。それを連鎖で実行するのが join
main =
    Control.Monad.join
  $ Opts.execParser
  $ Opts.info mainOptParser (
       Opts.fullDesc
    <> Opts.progDesc "A sample Haskell CLI application"
    <> Opts.header "main-exe - a demo program"
    <> Opts.footer "For more info, run: main-exe subcmds"
  )
