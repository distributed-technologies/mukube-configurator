# Fetch the bootscript
sudo rm -rf /tmp/boot_script/
sudo rm -rf mukube-bootscript/

sudo mkdir /tmp/boot_script/
git clone https://github.com/distributed-technologies/mukube-bootscript.git
cd mukube-bootscript/
git checkout bootv1
sudo cp boot.sh /tmp/boot_script/ 
sudo cp -r k8s-cluster-infrastructure /tmp/boot_script/ 

