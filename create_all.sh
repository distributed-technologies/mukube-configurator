#!/bin/bash
source config-all
OUTPUT_DIR=$1

#TODO validate with regexp
if [ -z $MASTER_CERTIFICATE_KEY ]
then
    echo "[info] MASTER_CERTIFICATE_KEY not set. Generating new. "
    MASTER_CERTIFICATE_KEY=$(sudo kubeadm certs certificate-key)
fi

#TODO validate with regexp
if [ -z $NODE_JOIN_TOKEN ]
then
    echo "[info] NODE_JOIN_TOKEN not set. Generating new. "
    NODE_JOIN_TOKEN=$(sudo kubeadm token create)
fi

re='^[0-9]+$'
if [ -z "$ALL_MASTERS" ]
then
    # Default value is 3
    echo "[info] ALL_MASTERS not set. Defaulting to 3"
    ALL_MASTERS=3
else
    if ! [[ $ALL_MASTERS =~ $re ]]
    then
        echo "[error] $ALL_MASTER not a number"
        exit 1
    fi
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

for ((i=1; i<=$ALL_MASTERS; i++)); do
    export MASTER_HOST_IP=${HOSTS[i-1]}
    export MASTER_PROXY_PRIORITY=$(expr 101 - $i)
    
    if [ $i = 1 ]; 
    then 
        export MASTER_PROXY_STATE=MASTER
        export MASTER_CREATE_CLUSTER=true
    else 
        export MASTER_PROXY_STATE=BACKUP
        export MASTER_CREATE_CLUSTER=false
    fi
    OUTPUT_DIR_MASTER=$OUTPUT_DIR/master/master$i
    OUTPUT_PATH_CONF=$OUTPUT_DIR_MASTER/mukube_init_config
    mkdir $OUTPUT_DIR_MASTER -p
    ./write_config_node.sh $OUTPUT_PATH_CONF

    ./write_config_master.sh $OUTPUT_PATH_CONF config-all

    # Configure Haproxy and keepalived
    ./prepare_master_HA.sh $OUTPUT_DIR_MASTER

    # Configure the static pod manifests for the control plane
    ./prepare_master_control_plane.sh $OUTPUT_DIR_MASTER
done

mkdir $OUTPUT_DIR/worker
./write_config_node.sh $OUTPUT_DIR/worker/mukube_init_config
