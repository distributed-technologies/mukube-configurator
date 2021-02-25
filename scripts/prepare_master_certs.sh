#!/bin/bash
OUTPUT_DIR=$1
VARIABLES=$2

source $VARIABLES
echo $NODE_CONTROL_PLANE_VIP
echo $2

# If the certs variable is set, copy the folder content 
if [ -z "$MASTER_CERT_DIR" ]
then
    echo "[info] MASTER_CERT_DIR not set. Certificates will be generated"
    kubeadm init phase certs cluster \
        --cert-dir $PWD/$OUTPUT_DIR \
        --control-plane-endpoint $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT
else
    echo "[info] found certificate directory: $MASTER_CERT_DIR"
    cp -r $MASTER_CERT_DIR/* $OUTPUT_DIR
fi
