#!/bin/bash


source scripts/config
source scripts/volume_op.sh
source scripts/brick_op.sh

SHARDTEMP="templates/mongo_sh_x.yaml"
BASE="sources/"

#Creating shard nodes


function generate_depand()
    {
        create_dir $1
        create_volume $1
    }
function generate_sh_yaml()
    {
      new_file_name=$BASE"mongo_sh_$1.yaml"
      cp $SHARDTEMP $new_file_name
      sed -i "s/mongoshx/mongosh$1/g" $new_file_name
      sed -i "s/rsx/rs$1/g" $new_file_name
      sed -i "s/mongox/mongo$1/g" $new_file_name
      kubectl create -f  $BASE"mongo_sh_"$1".yaml"
    }

function add_shard()
    {
        #Waiting for containers
        POD_STATUS= kubectl get pods | grep "mongosh" | grep "ContainerCreating"
        echo "Waiting shard containers"
        kubectl get pods | grep "mongosh" | grep "ContainerCreating"
        while [ $? -eq 0 ]
        do
        sleep 1
        echo -e "\n\nWaiting the following containers:"
        kubectl get pods | grep "mongosh" | grep "ContainerCreating"
        done
        sleep 10
        # Initializating shard nodes
        POD_NAME=$(kubectl get pods | grep "mongosh$1-1" | awk '{print $1;}')
        echo "Pod Name: $POD_NAME"
        CMD="rs.initiate({ _id : \"rs$1\", members: [{ _id : 0, host : \"mongosh$1-1:27017\" },{ _id : 1, host : \"mongosh$1-2:27017\" },{ _id : 2, host : \"mongosh$1-3:27017\" }]})"
        #Executing cmd inside pod
        echo $CMD
        kubectl exec -it $POD_NAME -- bash -c "mongo --eval '$CMD'"
        # #Adding shard to cluster
        POD_NAME=$(kubectl get pods | grep "mongos1" | awk '{print $1;}')
        CMD="sh.addShard(\"rs$1/mongosh$1-1:27017\")"
        #Executing cmd inside pod
        echo $CMD
        kubectl exec -it $POD_NAME -- bash -c "mongo -u root -p root --eval '$CMD'"
    }

function init_shard()
    {
        generate_depand $1
        generate_sh_yaml $1
        add_shard $1
    }



