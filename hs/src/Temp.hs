module Temp (initials) where

initials :: String -> String -> Maybe String
initials (f:_) (l:_) = Just ([f] ++ ". " ++ [l])
initials _ _ = Nothing
