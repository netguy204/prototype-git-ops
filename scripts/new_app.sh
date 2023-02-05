#!/bin/bash

function USAGE {
    echo "usage: $0 name"
    exit 1
}

NAME=$1

if [[ -z $NAME ]]; then
    USAGE
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# create the app resources
mkdir $NAME
$SCRIPT_DIR/expand.sh $NAME app-template $NAME __NAME__
rm $NAME/app.yaml # bonus copy we don't want

# create the Application resource
sed "s/__NAME__/$NAME/g" app-template/app.yaml > apps/production/$NAME.yaml
echo "- $NAME.yaml" >> apps/production/kustomization.yaml
