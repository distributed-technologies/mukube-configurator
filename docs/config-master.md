Configuration for what is needed to set up a master node that is part of a highly available control plane. Placed in the `config-master` file in the root of the project.
```
MASTER_NETWORK_INTERFACE=
MASTER_HOST_IP=
NODE_CONTROL_PLANE_VIP=
NODE_CONTROL_PLANE_PORT=
MASTER_PROXY_PRIORITY=
MASTER_PROXY_STATE=
MASTER_TAINT=
MASTER_VIP_CLUSTER_IPS=
MASTER_CREATE_CLUSTER=
NODE_JOIN_TOKEN=
MASTER_CERTIFICATE_KEY=
MASTER_CERT_DIR=
```


#### MASTER_NETWORK_INTERFACE
The name of the network interface where the devices are discoverable.
#### MASTER_HOST_IP
The ip address of the machine on the local network.
#### NODE_CONTROL_PLANE_VIP
The ip address of the control plane. If the first master node is being configured, this virtual ip will be created. 
#### NODE_CONTROL_PLANE_PORT
The port where the control plane should listens on. 
#### MASTER_PROXY_PRIORITY
To configure the HAProxy a priority is needed. The first master should have the highest value and the rest should have decresingly unique values. This value determins which node should get the VIP of the control plane if the current node fails.
#### MASTER_PROXY_STATE
Either MASTER or BACKUP. Determins if a given node should be the first node to hold the VIP of the control plane. If the value is set to master, make sure the MASTER_PROXY_PRIORITY is higher than the other nodes.
#### MASTER_TAINT
Either true or false. If this master node should be tainted, meaning that no pods other than the static pods, will be scheduled to run here. Defaluts to true.
#### MASTER_VIP_CLUSTER_IPS
A list of comma sepperated ips of all the other master nodes.
#### MASTER_CREATE_CLUSTER
Either true or false. If this node should create the cluster.
#### NODE_JOIN_TOKEN
A join token to use by other nodes joining the cluster. This is used to establish trust between the control plane and the joining nodes. Make sure the token is still valid.
#### MASTER_CERTIFICATE_KEY
A key used to encrypt the certificates.

### Example file
```
MASTER_NETWORK_INTERFACE=eth0
MASTER_HOST_IP=192.168.1.100
NODE_CONTROL_PLANE_VIP=192.168.1.150
NODE_CONTROL_PLANE_PORT=4200
MASTER_PROXY_PRIORITY=100
MASTER_PROXY_STATE=MASTER
MASTER_TAINT=true
MASTER_VIP_CLUSTER_IPS=192.168.1.100,192.168.1.101,192.168.1.102
MASTER_CREATE_CLUSTER=true
NODE_JOIN_TOKEN=o3rzie.deux2xjelpu5b7r4
MASTER_CERTIFICATE_KEY=a4f1cedaa91bdc1004dabba7264059f5a4079e6e6b8a12c29968476df8d4ed87
```
