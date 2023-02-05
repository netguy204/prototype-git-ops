#!/bin/bash
# release APP to STAGE for deployment

function USAGE {
    echo "usage: $0 app stage"
    exit 1
}

APP=$1
STAGE=$2

if [[ -z $APP ]]; then
    USAGE
fi
if [[ -z $STAGE ]]; then
    USAGE
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
git config --global user.email "gitops@brianttaylor.com"
git config --global user.name "$APP gha"
$SCRIPT_DIR/expand.sh `git rev-parse HEAD` $SCRIPT_DIR/../$APP/templates/$STAGE $SCRIPT_DIR/../$APP/overlays/$STAGE __REVISION__
cd $SCRIPT_DIR/..
git add $APP/overlays/$STAGE/
git commit -m 'automated version bump'
BRANCH="${APP}_${STAGE}_released_to_deploy"
git branch -f $BRANCH main
git push origin main
git checkout $BRANCH
git push -f origin $BRANCH