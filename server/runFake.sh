#!/bin/bash
cabal clean || exit
cabal configure || exit
cabal build || exit
xterm -e samplestream/serve.py &
sleep 2
dist/build/tweetcloud/tweetcloud
echo "Waiting for sample server to stop"
wait
