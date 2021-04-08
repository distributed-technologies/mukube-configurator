#!/bin/bash
DIR=$1
# Remake the directory to update timestamp
rm -rf $DIR
mkdir $DIR -p

while read image; do
  docker pull "$image"
  docker save --output="$DIR/${image//\//_}.tar" "$image"
done < image_requirements.txt

numberOfFiles=$(ls $DIR | wc -l)
# Counting non empty lines in requirements file
linesInFile=$(grep -w ".*[a-z].*" -c image_requirements.txt)

if [ $numberOfFiles != $linesInFile ]; then
    echo "[error] Container image download failed. 
          Numer of files in $DIR:$numberOfFiles does not equal the lines in image requirements:$linesInFile"
    exit 1
fi
