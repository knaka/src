{-# LANGUAGE OverloadedStrings #-}
module Httpd (commandInfo) where

import qualified Options.Applicative as Opts
import Command
import Network.Wai (responseLBS, Application)
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Types (status200)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Lazy.Char8 as LBS8
import Text.Printf (printf)

httpd :: Maybe FilePath -> IO ()
httpd maybeFile = do
  let port = 8080
  printf "Starting HTTP server on port %d...\n" port
  run port (app maybeFile)

app :: Maybe FilePath -> Application
app maybeFile _request respond = do
  body <- case maybeFile of
    Nothing   -> pure $ LBS8.pack "Hello"
    Just path -> LBS.readFile path
  respond $ responseLBS status200 [("Content-Type", "text/plain")] body

commandInfo :: Command.Info
commandInfo = Command.Info {
    name = "hs-httpd"
  , desc = "Start a simple HTTP server"
  , parser = httpd
      <$> Opts.optional (Opts.strOption
            (  Opts.long "file"
            <> Opts.short 'f'
            <> Opts.metavar "FILE"
            <> Opts.help "File to serve as response body"
            ))
}
