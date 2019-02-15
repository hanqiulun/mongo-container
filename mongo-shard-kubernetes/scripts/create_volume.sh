#!/bin/bash

source scripts/config

SHARDTEMP="templates/mongo_ep_x.yaml"
BASE="sources/"
array=("1" "2" "3")

function generate_ep_yaml()
    {
        name="mongo$1-$2"

        gluster volume create $name stripe 2 transport tcp node02:/opt/$name node03:/opt/$name node04:/opt/$name node05:/opt/$name force

        gluster volume start $name

        gluster volume quota $name enable

        new_file_name=$BASE"mongo_ep_$1-$2.yaml"
        cp $SHARDTEMP $new_file_name
        sed -i "s/x/$1/g" $new_file_name
        sed -i "s/y/$2/g" $new_file_name
        pt=$[1990+$1+$2]
        sed -i "s/pt/$pt/g" $new_file_name
        kubectl apply -f $new_file_name
    }

for ((rs=1; rs<=$SHARD_REPLICA_SET; rs++)) do
    for element in ${array[@]}
    do
    generate_ep_yaml $rs $element
    if [ $? -ne 0 ]; then
        echo -e "\033[31m create $new_file_name fail \033[0m"
    else
        echo -e "\033[32m create $new_file_name success \033[0m"
    fi
    done
done