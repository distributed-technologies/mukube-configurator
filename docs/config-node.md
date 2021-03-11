Configuration for what is needed to set up a single node. Placed in the `config-node` file in the root of the project:
```
NODE_CONTROL_PLANE_VIP= 
NODE_CONTROL_PLANE_PORT=
NODE_JOIN_TOKEN=
```
#### NODE_CONTROL_PLANE_VIP
The IP address of the control plane.
#### NODE_CONTROL_PLANE_PORT
The port to contact the control plane on.
#### NODE_JOIN_TOKEN
A join token to join the cluster. This is used to establish trust between the control plane and the joining worker node. Make sure the token is still valid.

### Example file

```
NODE_CONTROL_PLANE_VIP=192.168.1.140
NODE_CONTROL_PLANE_PORT=4200
NODE_JOIN_TOKEN=o3rzie.deux2xjelpu5b7r4
```
