#!/bin/bash
DIR=$1
mkdir $DIR -p
i=1
while read p; do
  docker pull "$p"
  docker save --output="$DIR/$i.tar" "$p"
  i=$((i+1))
done <requirements.txt
