module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assert)

main :: Effect Unit
main = do
  log "Hello, PureScript!"
  assert (100 == 50 * 2)
