# Fetch the bootscript
mkdir build/tmp/boot -p

git clone https://github.com/distributed-technologies/mukube-bootscript.git
cd mukube-bootscript/

# TODO REMOVE THE DEV BRANCH
git checkout bootv1

cp boot.sh ../build/tmp/boot/
cp -r k8s-cluster-infrastructure ../build/tmp/boot/

cd ..
rm -rf mukube-bootscript/

