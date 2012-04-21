module Main where

import qualified Network.Curl as Curl
import Control.Concurrent (forkIO)
import Control.Concurrent.Chan
import Control.Monad (forever, void)
import Control.Monad.Trans (liftIO)
import qualified Text.JSON as Json
import Data.List.Split
import qualified Network.WebSockets as WS
import Data.IORef
import qualified Data.Text as T

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
{-
webSocketAccepter :: [String] -> IO ()
webSocketAccepter hashChannel =
    withSocketsDo $ do
        socket <- listenOn (PortNumber 8088)
        putStrLn "Listening on port 8088."
        forever $ do
            (h, _, _) <- accept socket
            forkIO (talkTo h hashChannel)
-}

webSocketApp :: WS.TextProtocol p
             => Pipe -> WS.Request -> WS.WebSockets p ()
webSocketApp master request = do
    WS.acceptRequest request
    dup <- liftIO $ dupChan master
    forever $ do
        x <- liftIO $ readChan dup
        WS.sendTextData (T.pack x)

perPossibleHash :: Pipe -> String -> IO()
perPossibleHash p ('#':t) = writeChan p t
perPossibleHash _ _ = putStr ""

     
parseStatus :: Pipe -> String -> IO()
parseStatus pipe line = do
      case Json.decode line :: Json.Result Json.JSValue of
        Json.Ok (Json.JSObject status) -> mapM_ (perPossibleHash pipe) $ words $ getStatus status
        msg -> putStrLn ("Error:  " ++ show msg ++ "\n" ++ (take 200 line))

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
    master <- newChan :: IO Pipe
    _      <- forkIO $ WS.runServer "0.0.0.0" 8088
        (webSocketApp master :: WS.Request -> WS.WebSockets WS.Hybi00 ())
    _      <- forkIO $ forever $ void $ readChan master
    twitterReader master
