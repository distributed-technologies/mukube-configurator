#!/bin/bash 
sudo swapoff -a

# Load all the variables from the config.yaml file to variables
source mukube_init_config

case $NODE_TYPE in
    "master")
        echo "MASTER NODE SETUP"
        # Import all the container image tarballs into containerd local registry
        for FILE in /tmp/container-images/*; do
          sudo ctr image import $FILE
        done
	    DIR="/etc/kubernetes/manifests/"
        if [ -d "$DIR" ]; then
            echo "$DIR exists"
        else 
            sudo mkdir $DIR
        fi                        	
        case $MASTER_CREATE_CLUSTER in
            "true")
                echo "CREATING CLUSTER"
                printf "Bootstrapping virtual ip setup"
                sudo mv /tmp/ha/* /etc/kubernetes/manifests
                init="kubeadm init --config /etc/kubernetes/InitConfiguration.yaml --upload-certs" 
                printf "Creating cluster with command: \n\n\t $init \n\n"
                sudo $init
                ;;
            "false")
                echo "JOINING CLUSTER"
                # TODO remove unsafe verification by configuring certificates
                init="kubeadm join $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT --token $NODE_JOIN_TOKEN --discovery-token-unsafe-skip-ca-verification --control-plane --certificate-key $MASTER_CERTIFICATE_KEY --v=5"
                printf "Joining cluster with command: \n\n\t $init \n\n"
                sudo $init
                ;;
            *)
                echo "'create_cluster' variable not set. Exiting"
                exit 1
                ;;
        esac
        # Set the kubectl config for the user.
        echo "Copying config to user space"
        mkdir -p $HOME/.kube
        sudo rm $HOME/.kube/config
        sudo cp -if /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

        case $MASTER_TAINT in
            "true")
                echo "Master is tainted by default. Doing nothing"
                ;;
            "false")
                echo "Untainting master node"
                kubectl taint nodes --all node-role.kubernetes.io/master-
                ;;
            *)
                echo "'taint_master' variable not set. Exiting"
                exit 1
                ;;
        esac
        if [ $MASTER_CREATE_CLUSTER = "true" ]
        then
            printf "Setting up infrastructure\n"
            for FILE in /tmp/helm-charts/*; do
                release=$(echo $FILE | cut -f4 -d/ | cut -f1 -d#)
                namespace=$(echo $FILE | cut -f4 -d/ | cut -f2 -d#)
                helm install $release $FILE -n $namespace --create-namespace
            done
        else
            printf "Joining virtual ip setup"
            sudo mv /tmp/ha/* /etc/kubernetes/manifests
        fi
        ;;
    "worker")
        echo "WORKER NODE SETUP"
        # TODO remove unsafe verification by configuring certificates
        init="kubeadm join $NODE_CONTROL_PLANE_VIP:$NODE_CONTROL_PLANE_PORT --discovery-token-unsafe-skip-ca-verification --token $NODE_JOIN_TOKEN --v=5"
        printf "Creating cluster with command: \n\n\t $init \n\n"
        sudo $init
        ;;
    *)
        echo "'node_type' variable not set. Exiting"
        exit 1
        ;;
esac
