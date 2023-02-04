#!/bin/bash

set -e
function USAGE {
    echo "usage: $0 revision templatedir target"
    exit 1
}

REVISION=$1
TEMPLATE_DIR=$2
TARGET=$3

if [[ -z $REVISION ]]; then
    USAGE
fi
if [[ -z $TEMPLATE_DIR ]]; then
    USAGE
fi
if [[ -z $TARGET ]]; then
    USAGE
fi

cp $TEMPLATE_DIR/* $TARGET/
if [[ "$OSTYPE" == "darwin"* ]]; then
    find $TARGET -type f -exec sed -i '.bak' "s/__REVISION__/$REVISION/g" {} +
    rm $TARGET/*.bak
else
    find $TARGET -type f -exec sed -i "s/__REVISION__/$REVISION/g" {} +
fi