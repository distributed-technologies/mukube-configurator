WORKING_DIR=$1
TEMPLATES_DIR=$2

CONF=$WORKING_DIR/mukube_init_config
OUTPUT_DIR=$WORKING_DIR/etc/kubernetes

source $CONF

mkdir -p $OUTPUT_DIR

if [ $NODE_TYPE == "master" ]
then
TAINT_MASTER_YAML=""

if [ $MASTER_TAINT == "true" ]
then
export TAINT_MASTER_YAML="taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master"
else 
export TAINT_MASTER_YAML="taints: null"
fi

if [ $MASTER_CREATE_CLUSTER == "true" ]
then
eval "cat <<EOF
$(<$TEMPLATES_DIR/InitConfiguration.yaml )
---
$(<$TEMPLATES_DIR/ClusterConfiguration.yaml )
EOF
" > $OUTPUT_DIR/InitConfiguration.yaml
else
export NODE_REGISTRATION="controlPlane: 
    certificateKey: $MASTER_CERTIFICATE_KEY"
eval "cat <<EOF
$(<$TEMPLATES_DIR/JoinConfiguration.yaml )
---
$(<$TEMPLATES_DIR/ClusterConfiguration.yaml )
EOF
" > $OUTPUT_DIR/JoinConfiguration.yaml
fi
else
export NODE_REGISTRATION="taints: null"

eval "cat <<EOF
$(<$TEMPLATES_DIR/JoinConfiguration.yaml )
---
$(<$TEMPLATES_DIR/ClusterConfiguration.yaml )
EOF
" > $OUTPUT_DIR/JoinConfiguration.yaml
fi



