#!/bin/bash
# Fetch the bootscript
mkdir build/tmp/boot -p

cd build/tmp/
git clone https://github.com/distributed-technologies/mukube-bootscript.git
cd mukube-bootscript/

# TODO REMOVE THE DEV BRANCH
git checkout bootv1

cp boot.sh ../boot/boot.sh

# TODO Remove this and pull helm dependenceis instead
cp -r k8s-cluster-infrastructure boot/

cd ..
rm -rf mukube-bootscript/

