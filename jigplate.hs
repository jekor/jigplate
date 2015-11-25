import Control.Applicative ((*>), (<*), (<$>))
import Data.Aeson (decode, Value(..))
import Data.ByteString.Lazy (getContents)
import Data.HashMap.Lazy (HashMap, lookup, keys)
import Data.List (sort, nub, (\\))
import Data.Text (Text, pack, unpack)
import qualified Data.Vector as V (map, toList)
import System.Environment (getArgs)
import System.IO (stdout, hSetEncoding, utf8, hPutStr, openFile, IOMode(..), hGetContents)
import Text.Parsec (parse)
import Text.Parsec.Char (char, noneOf, alphaNum)
import Text.Parsec.Combinator (many1, choice)
import Text.Parsec.Prim (many)
import Text.Parsec.String (Parser)

import Prelude hiding (getContents, lookup)

data JigItem = JigFragment String | JigSlot String (Maybe String)

type JigPlate = [JigItem]

showJig :: JigPlate -> String
showJig [] = ""
showJig ((JigFragment s):x) = s ++ showJig x
showJig ((JigSlot n Nothing):x)  = "{" ++ n ++ "}" ++ showJig x
showJig ((JigSlot _ (Just s)):x) = s ++ showJig x

jigplate :: Parser JigPlate
jigplate = many (choice [fragment, slot])

fragment :: Parser JigItem
fragment = JigFragment <$> many1 (noneOf "{")

-- I'm not going to support all valid JSON strings, at least not yet.
slot :: Parser JigItem
slot = (\s -> JigSlot s Nothing) <$> (char '{' *> many alphaNum <* char '}')

slots :: JigPlate -> [String]
slots = nub . map slotName . filter isSlot
 where isSlot (JigSlot _ _) = True
       isSlot _             = False
       slotName (JigSlot n _) = n
       slotName _             = fail "not a slot"

jig :: Value -> [JigPlate] -> JigPlate
-- Find all slots. Check if the object fulfills them. Fill them if so.
-- TODO: Check that all slots are matched.
jig (Object obj) jps = case matchJig obj jps of
                         []     -> error "no matching templates found"
                         (jp:_) -> fillSlots jp obj
 where matchJig :: HashMap Text Value -> [JigPlate] -> [JigPlate]
       matchJig hash = filter (\jp -> (sort $ slots jp) \\ (sort $ map unpack $ keys hash) == [])
       fillSlots :: JigPlate -> HashMap Text Value -> JigPlate
       fillSlots [] _ = []
       fillSlots (f@(JigFragment _):x)      hash = f : fillSlots x hash
       fillSlots (s@(JigSlot _ (Just _)):x) hash = s : fillSlots x hash
       fillSlots (s@(JigSlot n Nothing):x)  hash = case lookup (pack n) hash of
                                                     Just (String s') -> JigSlot n (Just $ unpack s') : fillSlots x hash
                                                     Just v           -> jig v jps ++ fillSlots x hash
                                                     _                -> s : fillSlots x hash
-- TODO: Enforce all items being the same type.
jig (Array arr) jps = concat $ V.toList $ V.map (\v -> jig v jps) arr
jig _ _ = error "no matching templates found"

main :: IO ()
main = do
  data' <- decode <$> getContents
  case data' of
    -- TODO: Need better JSON parse error messages.
    Nothing -> fail $ "JSON parse error"
    Just d  -> do
      jigplates <- mapM parseJigplateFile =<< getArgs
      hSetEncoding stdout utf8
      hPutStr stdout $ showJig $ jig d jigplates
 where parseJigplateFile filename = do
         s <- readFile' filename
         case parse jigplate filename s of
           Left err -> fail (show err)
           Right jp -> return jp
       readFile' filename = do
         h <- openFile filename ReadMode
         hSetEncoding h utf8
         hGetContents h
