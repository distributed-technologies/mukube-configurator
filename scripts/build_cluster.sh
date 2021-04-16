#!/bin/bash
NODEDIR=$1

OUTDIR=artifacts/cluster
mkdir -p $OUTDIR

# Pack every node
for node in $NODEDIR/master/* $NODEDIR/worker/*; do
	archive_path=$OUTDIR/$(basename $node).tar
	echo "[INFO] Archiving $node --> $archive_path"
	tar -cf $archive_path -C $node .

	#Pack the images and helm charts for master nodes
	if [[ $node == *"master"* ]]; then
		echo "	* adding helm-charts and container-images"
		tar -rf $archive_path -C build root/helm-charts root/container-images
	fi
done
