WORKING_DIR=$1
TEMPLATES_DIR=$2

OUTPUT_DIR=$WORKING_DIR/etc/systemd/network

mkdir -p $OUTPUT_DIR

eval "cat <<EOF
$(<$TEMPLATES_DIR/10-systemd-network.network )
EOF
" > $OUTPUT_DIR/10-systemd-network.network
