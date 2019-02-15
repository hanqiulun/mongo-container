#!/bin/bash

source scripts/config

EPTEMP="templates/mongo_ep_x.yaml"
BASE="sources/"
array=("1" "2" "3")

function delete_volume()
    {
        for element in ${array[@]}
            do
                name="mongo$1-$element"

                echo 'y' |  gluster volume stop $name force

                echo 'y' |  gluster volume delete $name

                new_file_name=$BASE"mongo_ep_$1-$element.yaml"
                
                kubectl delete -f $new_file_name
            done
    }

function create_volume()
    {
        for element in ${array[@]}
            do
                name="mongo$1-$element"

                gluster volume create $name stripe 2 transport tcp node02:/opt/$name node03:/opt/$name node04:/opt/$name node05:/opt/$name force

                gluster volume start $name

                gluster volume quota $name enable

                new_file_name=$BASE"mongo_ep_$1-$element.yaml"
                cp $EPTEMP $new_file_name
                sed -i "s/x/$1/g" $new_file_name
                sed -i "s/y/$element/g" $new_file_name
                pt=$[1990+$1+$element]
                sed -i "s/pt/$pt/g" $new_file_name
                kubectl apply -f $new_file_name
            done
    }