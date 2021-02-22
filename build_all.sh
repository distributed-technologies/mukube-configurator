DIR=$1

echo "$DIR"
i=1
# Pack the master nodes
for d in $DIR/master/*; do
    archive_path=../out/master/mukube_master$i.tar
    mkdir -p out/master/ 
    #Pack the images and the whole i'th master folder
    tar -cv archive_path $d tmp/container-images --directory build
    i=$((i + 1))
done

tar -cvf out/master/mukube_worker.tar $d build/worker

