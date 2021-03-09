
default:
	@echo "make build-master,build-worker or build-cluster"

## File contains 3 recipes for building kubernetes nodes.
## If unpacked in the root of a linux filesystem and the boot.sh script is run,
## a kubernetes node will be created based on the input given in one of the 3 config files. 


help: 
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

##
## build-worker: Build a single worker node from the config in the 'config-node' file.
build-worker: artifacts/mukube_worker.tar

##
## build-master: Build a single master node from the config in the 'config-master' file.
build-master: artifacts/mukube_master.tar 

##
## build-cluster: Build a full cluster of nodes from the config in the 'config-cluster' file.
build-cluster:  artifacts/cluster

build/tmp/container-images: requirements.txt
	rm -rf build/tmp/container-images
	./scripts/pack_container_images.sh build/tmp/container-images

docker:
	docker build -t kubeadocker .

artifacts/mukube_master.tar: docker build/tmp/container-images build/tmp/boot config-master build/master/etc/kubernetes/pki 
	mkdir build/master/ -p
	mkdir artifacts -p
	./scripts/prepare_node_config.sh build/master/mukube_init_config config-master
	./scripts/prepare_master_config.sh build/master/mukube_init_config config-master
	./scripts/prepare_master_HA.sh build/master templates
	cp -r build/tmp/boot/* build/master  
	tar -cvf artifacts/mukube_master.tar -C build tmp/container-images
	tar -rf artifacts/mukube_master.tar -C build/master/ .
	
build/master/etc/kubernetes/pki: config-master 
	./scripts/prepare_master_certs.sh build/master/etc/kubernetes/pki config-master 

build/tmp/boot:
	./scripts/prepare_boot.sh

artifacts/mukube_worker.tar: build/tmp/boot config-node
	mkdir build/worker/ -p
	mkdir artifacts -p
	./scripts/prepare_node_config.sh build/worker/mukube_init_config config-node
	cp -r build/tmp/boot/boot.sh build/worker
	tar -cvf artifacts/mukube_worker.tar -C build/worker/ . 

build/cluster/certs: config-master 
	./scripts/prepare_master_certs.sh build/cluster/certs config-cluster

artifacts/cluster: build/tmp/container-images config-cluster build/cluster/certs
	./scripts/prepare_cluster.sh build/cluster config-cluster
	./scripts/build_cluster.sh build/cluster

clean: 
	rm -rf artifacts
	rm -rf build
