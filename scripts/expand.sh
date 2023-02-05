#!/bin/bash

set -e
function USAGE {
    echo "usage: $0 revision templatedir target"
    exit 1
}

REVISION=$1
TEMPLATE_DIR=$2
TARGET=$3
VARNAME=$4

if [[ -z $REVISION ]]; then
    USAGE
fi
if [[ -z $TEMPLATE_DIR ]]; then
    USAGE
fi
if [[ -z $TARGET ]]; then
    USAGE
fi
if [[ -z $VARNAME ]]; then
    USAGE
fi

cp -r $TEMPLATE_DIR/* $TARGET/
if [[ "$OSTYPE" == "darwin"* ]]; then
    find $TARGET -type f -exec sed -i '.bak' "s/$VARNAME/$REVISION/g" {} +
    rm $TARGET/*.bak
else
    find $TARGET -type f -exec sed -i "s/$VARNAME/$REVISION/g" {} +
fi