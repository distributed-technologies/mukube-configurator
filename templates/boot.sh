#!/bin/bash

# Load all the variables from the config.yaml file to variables
source mukube_init_config
hostnamectl set-hostname $NODE_NAME
echo  "127.0.1.1	$NODE_NAME" >> /etc/hosts
case $NODE_TYPE in
    master*)
        # All masters setup
        echo "MASTER NODE SETUP"
        # Activate the ip_vs kernel module to allow for load balancing. Required by Keepalived.
        modprobe ip_vs
        # Import all the container image tarballs into containerd local registry
        for FILE in /root/container-images/*; do
          ctr --namespace k8s.io image import $FILE
        done
        ;;& 
    master-init)
        echo "CREATING CLUSTER"
        echo "Bootstrapping virtual ip setup"
        mkdir -p /etc/kubernetes/manifests
        mv /root/ha/* /etc/kubernetes/manifests
        init="kubeadm init --v=5 --config /etc/kubernetes/InitConfiguration.yaml --upload-certs" 
        echo "Creating cluster with command: \n\n\t $init \n\n"
        $init 
        ;;&
    master-join | worker)
        echo "JOINING CLUSTER"
        # TODO remove unsafe verification by configuring certificates
        init="kubeadm join --v=5 --config /etc/kubernetes/JoinConfiguration.yaml"
        echo "Joining cluster with command: \n\n\t $init \n\n"
        $init
        ;;&
    master* | worker) 
        # Error handling for kubeadm
        if (( $? != 0)); then echo "kubeadm failed"; exit 1; fi
        ;;&
    master-init)
        echo "Installing included helm charts"
        for FILE in /root/helm-charts/*; do
            release=$(echo $FILE | cut -f4 -d/ | cut -f1 -d#)
            namespace=$(echo $FILE | cut -f4 -d/ | cut -f2 -d#)
            helm install --create-namespace -n $namespace $release $FILE
        done
        ;;&
    master-join)
        echo "Joining virtual ip setup"
        mv /root/ha/* /etc/kubernetes/manifests
        ;;&
esac
