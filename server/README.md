Hello world in Haskell
======================

This is my hello world app in Haskell: a twitter hash tag websocketter.

The idea is to have a haskell program put twitter hashes form the twitter streaming API on all the open websockets it has.

In the browser, the hashes can be shown on a canvas.

Twitter cloud with websockets, no server storage

Twitter stream -> websockets -> client

Build
=====

 1. Edit src/main/main.hs to set the correct username and password or
    optionally use the samplestream/serve.py script for local test
    streaming
 2. cabal configure
 3. cabal build
 4. run dist/build/tweetcloud/tweetcloud

