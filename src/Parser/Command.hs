{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ViewPatterns #-}
module Parser.Command (Command(..), readCommand) where

import Control.Lens
import Data.Functor
import Data.Text (Text)
import qualified Data.Text as T

import Text.Megaparsec
import Text.Megaparsec.Char

import Parser.Common

data Command = CommandQuit | CommandWorld
  deriving (Eq, Ord, Show, Read)
makePrisms ''Command

readCommand :: FilePath -> Text -> Either Text Command
readCommand filename fileContents =
  case parse (char ':' *> command <* eof) filename fileContents of
    Left err -> Left $ T.pack $ errorBundlePretty err
    Right ok -> Right ok

command :: Parser Command
command = (literal "q" $> CommandQuit) <|> (literal "w" $> CommandWorld)
