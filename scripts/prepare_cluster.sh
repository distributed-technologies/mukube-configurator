#!/bin/bash
OUTPUT_DIR=$1
VARIABLES=$2
source $VARIABLES

#TODO validate with regexp
if [ -z $MASTER_CERTIFICATE_KEY ]
then
    echo "[info] MASTER_CERTIFICATE_KEY not set. Generating new."
    MASTER_CERTIFICATE_KEY=$(docker run kubeadocker alpha certs certificate-key)
fi

#TODO validate with regexp
if [ -z $NODE_JOIN_TOKEN ]
then
    echo "[info] NODE_JOIN_TOKEN not set. Generating new. "
    NODE_JOIN_TOKEN=$(docker run kubeadocker token generate)
fi

if [ -z "$MASTER_NETWORK_INTERFACE" ]
then
    echo "[error] MASTER_NETWORK_INTERFACE required"
    exit 1
fi

if [ -z "$MASTER_VIP_CLUSTER_IPS" ]
then
    echo "[error] MASTER_VIP_CLUSTER_IPS required"
    exit 1
fi
# MAKE HOST_IP list
IFS=, read -ra HOSTS <<< "$MASTER_VIP_CLUSTER_IPS"

# Export all variables for script scope
export NODE_JOIN_TOKEN=$NODE_JOIN_TOKEN
export MASTER_CERTIFICATE_KEY=$MASTER_CERTIFICATE_KEY
export MASTER_NETWORK_INTERFACE=$MASTER_NETWORK_INTERFACE
export MASTER_TAINT=$MASTER_TAINT
export NODE_TYPE=master

# Get the bootscript
./scripts/prepare_boot.sh

for ((i=1; i<=${#HOSTS[@]}; i++)); do
    export MASTER_HOST_IP=${HOSTS[i-1]}
    export MASTER_PROXY_PRIORITY=$(expr 101 - $i)
    OUTPUT_DIR_MASTER=$OUTPUT_DIR/master/master$i

    if [ $i = 1 ]; 
    then 
        export MASTER_PROXY_STATE=MASTER
        export MASTER_CREATE_CLUSTER=true
        # Copy the certs to folder
        mkdir $OUTPUT_DIR_MASTER/etc/kubernetes/pki -p
        cp -r build/cluster/certs/* $OUTPUT_DIR_MASTER/etc/kubernetes/pki
    else 
        export MASTER_PROXY_STATE=BACKUP
        export MASTER_CREATE_CLUSTER=false
    fi
    

    OUTPUT_PATH_CONF=$OUTPUT_DIR_MASTER/mukube_init_config
    mkdir $OUTPUT_DIR_MASTER -p

    ./scripts/prepare_node_config.sh $OUTPUT_PATH_CONF $VARIABLES
    ./scripts/prepare_master_config.sh $OUTPUT_PATH_CONF $VARIABLES

    # Configure Haproxy and keepalived
    ./scripts/prepare_master_HA.sh $OUTPUT_DIR_MASTER templates

    # Copy bootscript to folder
    cp -r build/tmp/boot/* $OUTPUT_DIR_MASTER
done

export NODE_TYPE=worker
mkdir $OUTPUT_DIR/worker
cp -r build/tmp/boot/boot.sh $OUTPUT_DIR/worker
./scripts/prepare_node_config.sh $OUTPUT_DIR/worker/mukube_init_config $VARIABLES

