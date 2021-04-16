#!/bin/bash

# Load all the variables from the config.yaml file to variables
source mukube_init_config
hostnamectl set-hostname $NODE_NAME
case $NODE_TYPE in
    "master")
        echo "MASTER NODE SETUP"
        # Import all the container image tarballs into containerd local registry
        for FILE in /root/container-images/*; do
          ctr image import $FILE
        done
        case $MASTER_CREATE_CLUSTER in
            "true")
                echo "CREATING CLUSTER"
                printf "Bootstrapping virtual ip setup"
                mkdir -p /etc/kubernetes/manifests
                mv /root/ha/* /etc/kubernetes/manifests
                init="kubeadm init --config /etc/kubernetes/InitConfiguration.yaml --upload-certs" 
                printf "Creating cluster with command: \n\n\t $init \n\n"
                $init
                ;;
            "false")
                echo "JOINING CLUSTER"
                init="kubeadm join --config /etc/kubernetes/JoinConfiguration.yaml"
                printf "Joining cluster with command: \n\n\t $init \n\n"
                $init
                ;;
            *)
                echo "'create_cluster' variable not set. Exiting"
                exit 1
                ;;
        esac
        # Set the kubectl config for the user.
        echo "Copying config to user space"
        export KUBECONFIG=/etc/kubernetes/admin.conf

        if [ $MASTER_CREATE_CLUSTER = "true" ]
        then
            printf "Setting up infrastructure\n"
            for FILE in /root/helm-charts/*; do
                release=$(echo $FILE | cut -f4 -d/ | cut -f1 -d#)
                namespace=$(echo $FILE | cut -f4 -d/ | cut -f2 -d#)
                helm install --create-namespace -n $namespace $release $FILE
            done
        else
            printf "Joining virtual ip setup"
            mv /root/ha/* /etc/kubernetes/manifests
        fi
        ;;
    "worker")
        echo "WORKER NODE SETUP"
        # TODO remove unsafe verification by configuring certificates
        init="kubeadm join --config /etc/kubernetes/JoinConfiguration.yaml"
        printf "Creating cluster with command: \n\n\t $init \n\n"
        $init
        ;;
    *)
        echo "'node_type' variable not set. Exiting"
        exit 1
        ;;
esac
