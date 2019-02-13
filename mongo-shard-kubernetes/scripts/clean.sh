#!/bin/bash
#Creating and exposing config deployments

#Including config file
source scripts/config

BASE="sources/"

echo -e "Deleting config nodes"
kubectl delete -f  $BASE"mongo_config.yaml"

echo -e "\nDeleting shard nodes"
for ((rs=1; rs<=$SHARD_REPLICA_SET; rs++)) do
    kubectl delete -f  $BASE"mongo_sh_"$rs".yaml"
done

echo -e "\nDeleting router nodes"
kubectl delete -f $BASE"mongos.yaml"

echo -e "\nDeleting shard yaml"

for ((rs=1; rs<=$SHARD_REPLICA_SET; rs++)) do
    rm -rf $BASE"mongo_sh_"$rs".yaml"
done