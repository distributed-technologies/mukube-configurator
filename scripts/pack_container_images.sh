#!/bin/bash
DIR=$1
# Remake the directory to update timestamp
rm -rf $DIR
mkdir $DIR -p
i=1
while read p; do
  docker pull "$p"
  docker save --output="$DIR/$i.tar" "$p"
  i=$((i+1))
done <image_requirements.txt

numberOfFiles=$(ls $DIR | wc -l)
# Counting non empty lines in requirements file
linesInFile=$(grep -w ".*[a-z].*" -c image_requirements.txt)

if [ $numberOfFiles != $linesInFile ]; then
    echo "[error] Container image download failed. 
          Numer of files in $DIR:$numberOfFiles does not equal the lines in image requirements:$linesInFile"
    exit 1
fi
