#!/usr/bin/env bash
#
# wait for REVISION to become available at URL or until TIMEOUT

set -e


function USAGE {
    echo "usage: $0 REVISION URL TIMEOUT"
    exit 1
}

REVISION=$1
URL=$2
TIMEOUT=$3

if [[ -z $REVISION ]]; then
    USAGE
fi
if [[ -z $URL ]]; then
    USAGE
fi
if [[ -z $TIMEOUT ]]; then
    USAGE
fi

t=$TIMEOUT
while (( t > 0 ))
do
    CURRENT=`curl -s $URL`
    if [[ $CURRENT == "$REVISION" ]]; then
        exit 0
    fi
    sleep 1
    (( t -= 1))
done

exit 1
