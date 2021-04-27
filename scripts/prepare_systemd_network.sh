WORKING_DIR=$1
TEMPLATES_DIR=$2

OUTPUT_DIR=$WORKING_DIR/etc/systemd/network

mkdir -p $OUTPUT_DIR

eval "cat <<EOF
$(<$TEMPLATES_DIR/10-systemd-network.network )
EOF
" > $OUTPUT_DIR/10-systemd-network.network

echo "[DEBUG] finished networking at DNS"
echo "CONFIGURE_DNS is $CONFIGURE_DNS"
# Configure the DNS by moving the static template file 
if [[ $CONFIGURE_DNS = "true" ]]
then
    echo "[DEBUG] configuring DNS"
    if [ -z "$CLUSTER_DNS" ]
    then
        echo "[error] CLUSTER_DNS is required when CONFIGURE_DNS is true"
        exit 1
    fi
    eval "cat <<EOF
$(<$TEMPLATES_DIR/resolved.conf)
EOF
" > $WORKING_DIR/etc/systemd/resolved.conf
fi
