
default:
	@echo "make build-master,build-worker or build-cluster"
	
build/tmp/container-images: requirements.txt
	rm -rf build/tmp/container-images
	./scripts/pack_container_images.sh build/tmp/container-images

out/mukube_master.tar: build/tmp/container-images build/tmp/boot config-master build/master/etc/kubernetes/pki
	mkdir out -p
	./scripts/prepare_node_config.sh build/master/mukube_init_config config-master
	./scripts/prepare_master_config.sh build/master/mukube_init_config config-master
	./scripts/prepare_master_HA.sh build/master templates
	cp -r build/tmp/boot/* build/master  
	tar -cvf out/mukube_master.tar -C build tmp/container-images
	tar -rf out/mukube_master.tar -C build/master/ .
	
build/master/etc/kubernetes/pki: config-master 
	./scripts/prepare_master_certs.sh build/master/etc/kubernetes/pki config-master 

build-master: out/mukube_master.tar 

build/tmp/boot:
	./scripts/prepare_boot.sh

out/mukube_worker.tar: build/tmp/boot config-node
	mkdir build/worker/ -p
	mkdir out -p
	./scripts/prepare_node_config.sh build/worker/mukube_init_config config-node
	cp -r build/tmp/boot/boot.sh build/worker
	tar -cvf out/mukube_worker.tar -C build/worker/ . 

build-worker: out/mukube_worker.tar

build/cluster/certs: config-master 
	./scripts/prepare_master_certs.sh build/cluster/certs config-cluster

out/cluster: build/tmp/container-images config-cluster build/cluster/certs
	./scripts/prepare_cluster.sh build/cluster config-cluster
	./scripts/build_cluster.sh build/cluster

build-cluster:  out/cluster
 	
.PHONY: clear-build clear-out

clear-build:  
	rm -rf build/worker/*
	rm -rf build/master/*
	rm -rf build/cluster/*
	
clear-out:
	rm -rf out/*

clear: clear-build clear-out
