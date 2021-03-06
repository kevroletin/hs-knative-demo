#!/bin/bash/

set -e

USER=kevroletin
PROJECT=haskell-fn

docker build -f docker/Dockerfile.build-all-slim -t kevroletin/hs-demo-build .

STACK_LOCAL_BIN=$(stack path --local-install-root)/bin

EXE_LIST=$(stack ide targets 2>&1 | grep 'hs-demo:exe:'| sed -e "s/hs-demo:exe://")

# build
for i in $EXE_LIST; do
    echo
    echo "=== $i ==="

    docker build --build-arg "EXE_NAME=$i" -f docker/Dockerfile.from-image -t "$USER/$PROJECT-$i" .
done

# push
for i in $STACK_LOCAL_BIN/*; do
    docker push "$USER/$PROJECT-$i"
done

# report
for i in $EXE_LIST; do
    echo "$USER/$PROJECT-$i"
done
