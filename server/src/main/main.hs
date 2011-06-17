module Main where

import qualified Network.Curl as Curl
import Control.Concurrent (forkIO)
import Control.Concurrent.Chan
import qualified Text.JSON as Json
import System.IO
import Data.List.Split
import Control.Monad (forever)
import Network.WebSockets (shakeHands, putFrame)
import Network (listenOn, PortID(PortNumber), accept, withSocketsDo)
import Data.ByteString.UTF8 (fromString) -- this is from utf8-string
import Data.IORef

-- This url will work if you run doc/serve.py
twitterStreamingAPIStatusUrl :: String
--twitterStreamingAPIStatusUrl = "http://stream.twitter.com/1/statuses/sample.json"
twitterStreamingAPIStatusUrl = "http://localhost:8080/"
username :: String
username = ""
password :: String
password = ""
{-
username = ""
password = ""
-}

-- This is the websockets main function. When enabled will send a lot of messages
webSocketAccepter :: [String] -> IO ()
webSocketAccepter hashChannel =
    withSocketsDo $ do
        socket <- listenOn (PortNumber 8088)
        putStrLn "Listening on port 8088."
        forever $ do
            (h, _, _) <- accept socket
            forkIO (talkTo h hashChannel)

-- Shakes hands with client. If no error, starts talking.
talkTo :: Handle -> [String] -> IO ()
talkTo h list = do
  request <- shakeHands h
  case request of
    Left err -> print err
    Right  _ -> do
      putFrame h $ fromString "GO"
      talkLoop h list


-- Talks to the client (by echoing messages back) until EOF.
talkLoop :: Handle -> [String] -> IO ()
talkLoop h ls = do
   putFrame h $ fromString (head ls)
   talkLoop h $ tail ls


perPossibleHash :: Pipe -> String -> IO()
perPossibleHash p ('#':t) = writeChan p t
perPossibleHash _ _ = putStr ""

     
parseStatus :: Pipe -> String -> IO()
parseStatus pipe line = do
      case Json.decode line :: Json.Result Json.JSValue of
        Json.Ok (Json.JSObject status) -> mapM_ (perPossibleHash pipe) $ words $ getStatus status
        Json.Error msg -> putStrLn ("Error:  " ++ msg ++ "\n" ++ (take 200 line))

getStatus :: Json.JSObject Json.JSValue -> String 
getStatus a = case Json.valFromObj "text" a of
    Json.Ok b -> b
    Json.Error _ -> ""

collectLine :: Pipe -> (IORef String) -> String -> IO()
collectLine pipe buffer newInput = do
    bufferValue <- readIORef buffer
    let newBufferValue = bufferValue ++ newInput
    if any ('\n' ==) newBufferValue
        then do
            let bufferedLines = splitOn "\n" newBufferValue
            mapM_ (parseStatus pipe) $ init bufferedLines
            writeIORef buffer $ last bufferedLines
        else
            writeIORef buffer $ newBufferValue


twitterReader :: Pipe -> IO()
twitterReader pipe = do
    buffer <- newIORef ""
    h <- Curl.initialize
    Curl.setopts h
        [ Curl.CurlFailOnError   $ True
        , Curl.CurlURL           $ twitterStreamingAPIStatusUrl
        , Curl.CurlUserPwd       $ username ++ ":" ++ password
        , Curl.CurlHttpAuth      $ [Curl.HttpAuthAny]
        , Curl.CurlWriteFunction $ Curl.callbackWriter (collectLine pipe buffer)]    
    returnCode <- Curl.perform h
    putStrLn $ show returnCode


type Pipe = Chan (String)
 
main :: IO ()
main = do
    hashChannel <- newChan :: IO Pipe
    s           <- getChanContents hashChannel
    _           <- forkIO $ webSocketAccepter s
    twitterReader hashChannel




