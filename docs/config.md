Configuration for what is needed to set up a HA that is part of a highly available control plane. Placed in the `config` file in the root of the project.
```
NODE_CONTROL_PLANE_VIP=
NODE_CONTROL_PLANE_PORT=
MASTER_TAINT=
NODE_NETWORK_INTERFACE=
MASTER_VIP_CLUSTER_IPS=
CLUSTER_ID=
MASTER_CERT_DIR=
NODE_JOIN_TOKEN=
MASTER_CERTIFICATE_KEY=
```

#### NODE_CONTROL_PLANE_VIP
The ip address of the control plane. If the first master node is being configured, this virtual ip will be created. 

#### NODE_CONTROL_PLANE_PORT
The port where the control plane should listens on.

#### MASTER_TAINT
Either true or false. If this master node should be tainted, meaning that no pods other than the static pods, will be scheduled to run here. Defaluts to true.

#### NODE_NETWORK_INTERFACE
The name of the network interface where the devices are discoverable.

#### MASTER_VIP_CLUSTER_IPS
A comma separated list of ips of all the master nodes.

#### CLUSTER_ID
The id of the kubernetes cluster. Must be a unique number from 0 to 255 for the cluster, if more clusters are in the same subnet.
Used to setup and maintain a virtual ip for the control plane using Keepalived.

### WORKER_IPS 
A comma separated list of ips of all the worker nodes.

#### NODE_JOIN_TOKEN
A join token to use by other nodes joining the cluster. This is used to establish trust between the control plane and the joining nodes. Make sure the token is still valid.

#### MASTER_CERTIFICATE_KEY
A key used to encrypt the certificates.

### Example file
```
NODE_CONTROL_PLANE_VIP=192.168.1.150
NODE_CONTROL_PLANE_PORT=4200
MASTER_TAINT=false
NODE_NETWORK_INTERFACE=eth0
MASTER_VIP_CLUSTER_IPS=192.168.1.100,192.168.1.101,192.168.1.102,
WORKER_IPS=192.168.1.110,192.168.1.111
NODE_GATEWAY_IP=192.168.1.1
```
