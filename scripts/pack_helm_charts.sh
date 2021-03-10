#!/bin/bash
DIR=$1
mkdir $DIR -p
cat helm_requirements.txt |grep -w ".*http.*"   | while read p; do
  echo $p
  url=$(echo $p | cut -f1 -d' ')
  release=$(echo $p | cut -f2 -d' ')
  namespace=$(echo $p | cut -f3 -d' ')
  filename=$(echo $url | rev | cut -f1 -d/ | rev)
  # Download and rename file to include release and namespace
  $(wget -O "$DIR/$release#$namespace#$filename" $url)
done

numberOfFiles=$(ls $DIR | wc -l)
linesInFile=$(grep -w ".*http.*" -c helm_requirements.txt)

if [ $numberOfFiles != $linesInFile ]; then
    echo "Error in helm charts download"
    exit 1
fi