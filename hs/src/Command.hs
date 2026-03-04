module Command (CommandInfo(..)) where

import qualified Options.Applicative as Opts

-- 各サブコマンドの情報を保持するデータ型を定義
-- %1 は Linear Types（線形型）の記法で、「その引数は正確に1回だけ使われる」ことを示します。GHC 9.0 以降で導入された LinearTypes 拡張の構文
data CommandInfo = CommandInfo
  { cmdName :: String
  , cmdDesc :: String
  , cmdParser :: Opts.Parser (IO ())
  }
