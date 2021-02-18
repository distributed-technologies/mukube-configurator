#!/bin/bash
DIR=src/tmp/container-images/ 
if [ -d "$DIR" ] 
then
	echo "$DIR exists" 
else  
	mkdir $DIR -p
i=1
while read p; do
  sudo ctr image pull "$p"
  sudo ctr image export "$DIR/$i.tar" "$p"
  i=$((i+1))
done <requirements.txt
fi