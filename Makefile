
default:
	@echo "make build-master,build-worker or build-all"
	
build/tmp/container-images: requirements.txt
	rm -rf build/tmp/container-images
	./pack_container_images.sh build/tmp/container-images

out/mukube_master.tar: build/tmp/container-images config-master
	./write_config_node.sh build/master/mukube_init_config
	./write_config_master.sh build/master/mukube_init_config config-master
	./prepare_master_HA.sh build/master 
	tar -cvf out/mukube_master.tar -C build tmp/container-images
	tar -rf out/mukube_master.tar -C build/master/ .
	

build-master: out/mukube_master.tar 

out/mukube_worker.tar: config-node
	./write_config_node.sh build/worker/mukube_init_config
	tar -cvf out/mukube_worker.tar -C build/worker/ . 

build-worker: out/mukube_worker.tar

out/all: build/tmp/container-images config-all
	./create_all.sh build/all
	./build_all.sh build/all 

build-all:  out/all
	
 	
.PHONY: clear-build clear-out

clear-build:  
	rm -rf build/worker/*
	rm -rf build/master/*
	rm -rf build/all/*
	
clear-out:
	rm -rf out/*

clear: clear-build clear-out
