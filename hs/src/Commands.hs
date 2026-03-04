module Commands (registerAll) where

import Command (CommandInfo(..))
import Data.Function ((&))

import qualified Greet
import qualified Hello

registerAll :: [CommandInfo] -> [CommandInfo]
registerAll cmds =
  cmds
  & Greet.register
  & Hello.register
