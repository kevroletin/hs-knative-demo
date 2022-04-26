#!/bin/bash/

set -e

USER=kevroletin
PROJECT=haskell-fn

stack build

STACK_LOCAL_BIN=$(stack path --local-install-root)/bin
EXE_LIST=$(stack ide targets 2>&1 | grep 'hs-demo:exe:'| sed -e "s/hs-demo:exe://")

# build
for i in $EXE_LIST; do
    REL_PATH=$(realpath --relative-to=. "$STACK_LOCAL_BIN/$i")

    echo
    echo "=== $REL_PATH ==="

    docker build --build-arg "EXE_PATH=$REL_PATH" -f docker/Dockerfile.from-exe -t "$USER/$PROJECT-$i" .

done

# push
for i in $EXE_LIST; do
    docker push "$USER/$PROJECT-$i"
done

# report
for i in $EXE_LIST; do
    echo "$USER/$PROJECT-$i"
done
