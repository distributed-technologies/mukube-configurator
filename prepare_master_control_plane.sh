#!/bin/bash
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init-phase/
WORK_DIR=$1
source $WORK_DIR/mukube_init_config

mkdir $WORK_DIR/var/lib/etcd -p 

echo "\n\n CONFIGURING $MASTER_HOST_IP \n\n"

# Start the kubelet to execute all the phases
sudo kubeadm init phase kubelet-start

# Make all the certs
echo "certs"
sudo kubeadm init phase certs all \
    --control-plane-endpoint $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT \
    --apiserver-advertise-address $MASTER_HOST_IP \
    --kubernetes-version v1.20.2

# Download the configurations
echo "configs"
sudo kubeadm init phase kubeconfig all  \
    --control-plane-endpoint $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT \
    --apiserver-advertise-address $MASTER_HOST_IP \
    --kubernetes-version v1.20.2

# Download the static pod manifests for the control plane
echo "static control pods"
sudo kubeadm init phase control-plane all  \
     --control-plane-endpoint $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT \
     --apiserver-advertise-address $MASTER_HOST_IP \
     --kubernetes-version v1.20.2 

# Download local etcd static pod manifests 
# TODO FIX THE VARIABLES IN THE .yaml FILE
echo "static etcd pods"
sudo kubeadm init phase etcd local 

# mv all kubernetes folders to workdir
sudo mv /etc/kubernetes $WORK_DIR/etc/


# TODO remove when groups are working
sudo chmod 777 -R $WORK_DIR
