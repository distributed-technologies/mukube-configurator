#!/bin/bash 

# Load all the variables from the config.yaml file to variables
source mukube_init_config
case $NODE_TYPE in
    "master")
        echo "MASTER NODE SETUP"
        # Import all the container image tarballs into containerd local registry
        for FILE in /root/container-images/*; do
          ctr image import $FILE
        done
	    DIR="/etc/kubernetes/manifests/"
        if [ -d "$DIR" ]; then
            echo "$DIR exists"
        else 
            mkdir $DIR
        fi                        	
        case $MASTER_CREATE_CLUSTER in
            "true")
                echo "CREATING CLUSTER"
                printf "Bootstrapping virtual ip setup"
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
                helm install $release $FILE -n $namespace --create-namespace
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
