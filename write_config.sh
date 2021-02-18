#!/bin/bash
if [ -z "$TAINT_MASTER" ];
then
    # Default value is true
    TAINT_MASTER="true"
else
    if ! [[ $TAINT_MASTER = "false" || $TAINT_MASTER = "true" ]] 
    then
        echo "'$TAINT_MASTER' not true or false"
        exit 1
    fi
fi

re='^[0-9]+$'
if [ -z "$MASTERS" ];
then
    # Default value is 3
    MASTERS=3
else
    if ! [[ $MASTERS =~ $re ]] ; then
        echo "$MASTER not a number"
        exit 1
    fi
fi

echo $TAINT_MASTER
echo $MASTERS
