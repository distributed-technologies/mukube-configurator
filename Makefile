
default:
	echo "make master,worker or all"
	
build/tmp/container-images: requirements.txt
	rm -rf build/tmp/container-images
	./pack_container_images.sh build/tmp/container-images

mukube_master.tar: build/tmp/container-images config-master
	./write_config_node.sh build/master/mukube_init_config.yaml
	./write_config_master.sh build/master/mukube_init_config.yaml
	tar -cvf out/mukube_master.tar build/master build/tmp/container-images

build-master: out/mukube_master.tar 

mukube_worker.tar: config-node
	./write_config_node.sh build/worker/mukube_init_config.yaml
	tar -cvf out/mukube_worker.tar build/worker 

build-worker: mukube_worker.tar

build-all: build/tmp/container-images config-all 
	./create_all.sh build/all
	./build_all.sh build/all 
 	
.PHONY: clear-build clear-out

clear-build:  
	rm -rf build/worker/*
	rm -rf build/master/*
	rm -rf build/all/*
	
clear-out:
	rm -rf out/*
