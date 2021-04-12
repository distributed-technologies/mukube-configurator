#!/bin/bash
CONFIG_OUTPUT_FILE=$1
VARIABLES=$2

source $VARIABLES

# A master node has the same configuration as a normal node and more.
./scripts/prepare_node_config.sh $CONFIG_OUTPUT_FILE $VARIABLES

if [ -z "$MASTER_TAINT" ];
then
    # Default value is true
    echo "[info] MASTER_TAINT not set. Defaulting to true"
    MASTER_TAINT="true"
else
    if ! [[ $MASTER_TAINT = "false" || $MASTER_TAINT = "true" ]] 
    then
        echo "[error] MASTER_TAINT='$MASTER_TAINT' not true or false"
        exit 1
    fi
fi

if [ -z "$MASTER_CREATE_CLUSTER" ]
then
    echo "[error] MASTER_CREATE_CLUSTER required"
    exit 1
fi

if [ -z "$NODE_NETWORK_INTERFACE" ]
then
    echo "[error] NODE_NETWORK_INTERFACE required"
    exit 1
fi

if [ -z $NODE_HOST_IP ]
then
    echo "[error] NODE_HOST_IP required"
    exit 1
fi

if [ -z $MASTER_PROXY_PRIORITY ]
then
    echo "[error] MASTER_PROXY_PRIORITY required."
    exit 1
fi

if [ -z $MASTER_VIP_CLUSTER_IPS ]
then
    echo "[error] MASTER_VIP_CLUSTER_IPS required."
    exit 1
fi

if [ -z $MASTER_PROXY_STATE ]
then
    echo "[error] MASTER_PROXY_STATE required."
    exit 1
fi

if [ -z $MASTER_CERTIFICATE_KEY ]
then
    echo "[error] MASTER_CERTIFICATE_KEY required."
    exit 1
fi

if [ -z $NODE_TYPE ]
then
    NODE_TYPE=master
fi

echo "MASTER_TAINT=$MASTER_TAINT" >> $CONFIG_OUTPUT_FILE
echo "NODE_NETWORK_INTERFACE=$NODE_NETWORK_INTERFACE" >> $CONFIG_OUTPUT_FILE
echo "NODE_HOST_IP=$NODE_HOST_IP" >> $CONFIG_OUTPUT_FILE
echo "MASTER_CERTIFICATE_KEY=$MASTER_CERTIFICATE_KEY" >> $CONFIG_OUTPUT_FILE
echo "MASTER_PROXY_PRIORITY=$MASTER_PROXY_PRIORITY" >> $CONFIG_OUTPUT_FILE
echo "MASTER_PROXY_STATE=$MASTER_PROXY_STATE" >> $CONFIG_OUTPUT_FILE
echo "MASTER_VIP_CLUSTER_IPS"=$MASTER_VIP_CLUSTER_IPS >> $CONFIG_OUTPUT_FILE
echo "MASTER_CREATE_CLUSTER"=$MASTER_CREATE_CLUSTER >> $CONFIG_OUTPUT_FILE
