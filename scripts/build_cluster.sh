DIR=$1

i=1
# Pack the master nodes
for d in $DIR/master/*; do
    archive_path=out/cluster/mukube_master$i.tar
    mkdir -p out/cluster/ 
    #Pack the images and the whole i'th master folder
    tar -cvf $archive_path -C $d .
    tar -rf $archive_path -C build tmp/
    i=$((i + 1))
done

# Pack the one tar for all workre nodes
tar -cvf out/cluster/mukube_worker.tar -C build/worker .
