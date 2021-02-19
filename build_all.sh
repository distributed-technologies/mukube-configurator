DIR=$1

echo "$DIR"
i=0
for d in $DIR/master/*; do
    echo $d
    mkdir -p out/master/ 
    tar -cvf out/master/mukube_master$i.tar $d build/tmp/container-images
    i=$((i + 1))
done

tar -cvf out/master/mukube_worker.tar $d build/worker

