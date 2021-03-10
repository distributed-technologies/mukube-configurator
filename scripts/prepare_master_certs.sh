#!/bin/bash
OUTPUT_DIR=$1
VARIABLES=$2

source $VARIABLES

# If the certs variable is set, copy the folder content 
if [ -z "$MASTER_CERT_DIR" ]
then
    echo "[info] MASTER_CERT_DIR not set. Certificates will be generated"
    docker run -v $PWD/$OUTPUT_DIR:/app kubeadocker init phase certs all \
        --cert-dir /app \
        --control-plane-endpoint $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT
else
    echo "[info] found certificate directory: $MASTER_CERT_DIR"
    cp -r $MASTER_CERT_DIR/* $OUTPUT_DIR
fi
