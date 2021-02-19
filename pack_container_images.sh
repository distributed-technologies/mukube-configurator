#!/bin/bash
DIR=$1
mkdir $DIR -p
echo $DIR
i=1
while read p; do
  sudo ctr image pull "$p"
  sudo ctr image export "$DIR/$i.tar" "$p"
  i=$((i+1))
done <requirements.txt
