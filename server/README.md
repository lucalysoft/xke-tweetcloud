Hello world in Haskell
======================

This is my hello world app in Haskell: a twitter hash tag websocketter.

The idea is to have a haskell program put twitter hashes form the twitter streaming API on all the open websockets it has.

In the browser, the hashes can be shown on a canvas.

Twitter cloud with websockets, no server storage

Twitter stream -> websockets -> client

Build
=====

 1. Edit src/main/main.hs to set the correct username, password and url.
    For the local test server, the url should be something like: http://localhost:8080/
 2. cabal configure
 3. cabal build
 4. run dist/build/tweetcloud/tweetcloud

