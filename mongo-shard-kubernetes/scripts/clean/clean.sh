#!/bin/bash
#Creating and exposing config deployments

#Including config file
source scripts/config
source scripts/volume_op.sh
source scripts/brick_op.sh
BASE="sources/"

echo -e "Deleting config nodes"
kubectl delete -f  $BASE"mongo_config.yaml"
kubectl delete -f  $BASE"mongod_config.conf"


echo -e "\nDeleting shard nodes"
for ((rs=1; rs<=$SHARD_REPLICA_SET; rs++)) do
    kubectl delete -f  $BASE"mongo_sh_"$rs".yaml"
done

echo -e "\nDeleting router nodes"
kubectl delete -f $BASE"mongos.yaml"

echo -e "\nDeleting shard yaml"

for ((rs=1; rs<=$SHARD_REPLICA_SET; rs++)) do
    rm -rf $BASE"mongo_sh_"$rs".yaml"
    delete_volume $rs
    delete_dir $rs
done

echo -e "\nDeleting keyfile"


rm -rf keyfile

kubectl delete secrets keyfile


