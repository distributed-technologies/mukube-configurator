test:
	./write_config.sh

pack_container_images: 
	./pack_container_images.sh

build:
	tar -cvf mukube.tar src

clear:
	rm -rf src/tmp/ \
	rm mukube.tar
