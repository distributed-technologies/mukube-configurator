#!/bin/bash
WORKING_DIR=$1
TEMPLATES_DIR=$2

CONF=$WORKING_DIR/mukube_init_config

source $CONF

export APISERVER_DEST_PORT=$NODE_CONTROL_PLANE_PORT
export APISERVER_VIP=$NODE_CONTROL_PLANE_VIP

mkdir -p $WORKING_DIR/etc/keepalived
mkdir -p $WORKING_DIR/root/ha

# Fill in check_apiserver.sh
INPUT="\$1"
eval "cat <<EOF
$(<$TEMPLATES_DIR/check_apiserver.sh)
EOF
" > $WORKING_DIR/etc/keepalived/check_apiserver.sh

VIP_IPS=$MASTER_VIP_CLUSTER_IPS

# Fill in keepalived.yaml
eval "cat <<EOF
$(<$TEMPLATES_DIR/keepalived.yaml)
EOF
" > $WORKING_DIR/root/ha/keepalived.yaml

export STATE=$MASTER_PROXY_STATE
export INTERFACE=$NODE_NETWORK_INTERFACE
export ROUTER_ID=$(echo $NODE_CONTROL_PLANE_VIP | cut -d . -f 4)
export PRIORITY=$MASTER_PROXY_PRIORITY
export AUTH_PASS=42 # Default value

# Fill in keepalived.conf
eval "cat <<EOF
$(<$TEMPLATES_DIR/keepalived.conf)
EOF
" > $WORKING_DIR/etc/keepalived/keepalived.conf
