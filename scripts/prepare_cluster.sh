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

if [ -z "$NODE_NETWORK_INTERFACE" ]
then
    echo "[error] NODE_NETWORK_INTERFACE required"
    exit 1
fi

if [ -z "$MASTER_VIP_CLUSTER_IPS" ]
then
    echo "[error] MASTER_VIP_CLUSTER_IPS required"
    exit 1
fi

if [ -z "$NODE_GATEWAY_IP" ]
then
    echo "[error] NODE_GATEWAY_IP required"
    exit 1
fi

if [ -z $CLUSTER_NAME ]
then
    echo "[INFO] CLUSTER_NAME not set. Using default: test"
    CLUSTER_NAME="test"
fi

# MAKE HOST_IP list
IFS=, read -ra HOSTS <<< "$MASTER_VIP_CLUSTER_IPS"

# Export all variables for script scope
export NODE_JOIN_TOKEN=$NODE_JOIN_TOKEN
export MASTER_CERTIFICATE_KEY=$MASTER_CERTIFICATE_KEY
export NODE_NETWORK_INTERFACE=$NODE_NETWORK_INTERFACE
export MASTER_TAINT=$MASTER_TAINT
export NODE_GATEWAY_IP=$NODE_GATEWAY_IP
export NODE_TYPE=master
export CONFIGURE_DNS=$CONFIGURE_DNS
export CLUSTER_DNS=$CLUSTER_DNS
export CLUSTER_NAME=$CLUSTER_NAME

for ((i=0; i<${#HOSTS[@]}; i++)); do
    export NODE_HOST_IP=${HOSTS[i]}
    export NODE_NAME=master$i
    export MASTER_PROXY_PRIORITY=$(expr 100 - $i)
    OUTPUT_DIR_MASTER=$OUTPUT_DIR/$CLUSTER_NAME-master$i

    if [ $i = 0 ];
    then
        export MASTER_PROXY_STATE=MASTER
        export MASTER_CREATE_CLUSTER=true
    else
        export MASTER_PROXY_STATE=BACKUP
        export MASTER_CREATE_CLUSTER=false
    fi

    OUTPUT_PATH_CONF=$OUTPUT_DIR_MASTER/mukube_init_config
    mkdir -p $OUTPUT_DIR_MASTER

    ./scripts/prepare_master_config.sh $OUTPUT_PATH_CONF $VARIABLES
    ./scripts/prepare_systemd_network.sh $OUTPUT_DIR_MASTER templates
    ./scripts/prepare_master_HA.sh $OUTPUT_DIR_MASTER templates
    ./scripts/prepare_k8s_configs.sh $OUTPUT_DIR_MASTER templates
    cp templates/boot.sh $OUTPUT_DIR_MASTER
done

# MAKE HOST_IP list
IFS=, read -ra WORKERS <<< "$WORKER_IPS"

# Prepare the worker nodes
export NODE_TYPE=worker
for ((i=0; i<${#WORKERS[@]}; i++)); do
    export NODE_HOST_IP=${WORKERS[i]}
    export NODE_NAME=worker$i

    OUTPUT_DIR_WORKER=$OUTPUT_DIR/$CLUSTER_NAME-worker$i
    mkdir -p $OUTPUT_DIR_WORKER

    cp templates/boot.sh $OUTPUT_DIR_WORKER
    ./scripts/prepare_node_config.sh $OUTPUT_DIR_WORKER/mukube_init_config $VARIABLES
    ./scripts/prepare_systemd_network.sh $OUTPUT_DIR_WORKER templates
    ./scripts/prepare_k8s_configs.sh $OUTPUT_DIR_WORKER templates
done
