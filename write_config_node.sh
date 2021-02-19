#!/bin/bash
CONFIG_OUTPUT_FILE=$1
source config-node

if [ -z "$NODE_CONTROL_PLANE_VIP" ]
then
    echo "[error] NODE_CONTROL_PLANE_VIP required"
    exit 1
fi

if [ -z "$NODE_CONTROL_PLANE_PORT" ]
then
    echo "[error] NODE_CONTROL_PLANE_PORT required"
    exit 1
fi

if [ -z $NODE_JOIN_TOKEN ]
then
    echo "[error] NODE_JOIN_TOKEN required."
fi

if [ -z $NODE_TYPE ]
then
    NODE_TYPE=worker
fi

echo "NODE_TYPE: $NODE_TYPE" > $CONFIG_OUTPUT_FILE
echo "NODE_CONTROL_PLANE_VIP: $NODE_CONTROL_PLANE_VIP" >> $CONFIG_OUTPUT_FILE
echo "NODE_CONTROL_PLANE_PORT: $NODE_CONTROL_PLANE_PORT" >> $CONFIG_OUTPUT_FILE
echo "NODE_JOIN_TOKEN: $NODE_JOIN_TOKEN" >> $CONFIG_OUTPUT_FILE