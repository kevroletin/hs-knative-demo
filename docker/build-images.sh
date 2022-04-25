#!/bin/bash/

set -e

USER=kevroletin
PROJECT=haskell-fn

stack build

STACK_LOCAL_BIN=$(stack path --local-install-root)/bin

# build
for i in $STACK_LOCAL_BIN/*; do
    REL_PATH=$(realpath --relative-to=. "$i")
    FN=$(basename "$i")

    if [[ -x "$i" ]]
    then
        echo
        echo "=== $REL_PATH ==="

        docker build --build-arg "EXE_PATH=$REL_PATH" -f docker/Dockerfile.from-exe -t "$USER/$PROJECT-$FN" .
    else
        echo "Skipping $i"
    fi

done

# push
for i in $STACK_LOCAL_BIN/*; do
    REL_PATH=$(realpath --relative-to=. "$i")
    FN=$(basename "$i")

    if [[ -x "$i" ]]
    then
        docker push "$USER/$PROJECT-$FN"
    fi

done

# report
for i in $STACK_LOCAL_BIN/*; do
    REL_PATH=$(realpath --relative-to=. "$i")
    FN=$(basename "$i")

    if [[ -x "$i" ]]
    then
        echo "$USER/$PROJECT-$FN"
    fi
done
