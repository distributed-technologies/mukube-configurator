#!/bin/bash
WORKING_DIR=$1
CONF=$WORKING_DIR/mukube_init_config

source $CONF

export APISERVER_DEST_PORT=$NODE_CONTROL_PLANE_PORT
export APISERVER_VIP=$NODE_CONTROL_PLANE_VIP

mkdir -p $1/etc/keepalived
mkdir -p $1/etc/haproxy
mkdir -p $1/tmp/ha

# Fill in check_apiserver.sh
eval "cat <<EOF
$(<templates/check_apiserver.sh)
EOF
" > $1/etc/keepalived/check_apiserver.sh

VIP_IPS=$MASTER_VIP_CLUSTER_IPS


# Fill in haproxy.cfg 
eval "cat <<EOF
$(<templates/haproxy.cfg )
EOF
" > $1/etc/haproxy/haproxy.cfg 

# MAKE HOST_IP list
IFS=, read -ra IPS <<< "$VIP_IPS"
for ((i=0; i<${#IPS[@]}; i++)); do
    echo -e "\t\tserver MASTER_VIP$i ${IPS[i]}:6443 check" >> $1/etc/haproxy/haproxy.cfg
done


# Fill in haproxy.yaml
eval "cat <<EOF
$(<templates/haproxy.yaml)
EOF
" > $1/tmp/ha/haproxy.yaml

# Fill in keepalived.yaml
eval "cat <<EOF
$(<templates/keepalived.yaml)
EOF
" > $1/tmp/ha/keepalived.yaml

export STATE=$MASTER_PROXY_STATE
export INTERFACE=$MASTER_NETWORK_INTERFACE
export ROUTER_ID=51 # Default value
export PRIORITY=$MASTER_PROXY_PRIORITY
export AUTH_PASS=42

# Fill in keepalived.conf
eval "cat <<EOF
$(<templates/keepalived.conf)
EOF
" > $1/etc/keepalived/keepalived.conf