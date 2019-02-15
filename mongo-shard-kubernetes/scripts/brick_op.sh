#!/bin/bash

# create brick 

NODES=$(awk -F " " 'NR>3{print $2}' /etc/hosts)
array=("1" "2" "3")

function create_dir()
    {
        for node in ${NODES[@]}
            do
                for element in ${array[@]}
                    do
                        dirname="mongo$1-$element"
                        ssh root@$node "mkdir /opt/$dirname"
                        if [ $? -ne 0 ]; then
                            echo -e "\033[31m create $node /opt/$dirname fail \033[0m"
                        else
                            echo -e "\033[32m create $node /opt/$dirname success \033[0m"
                        fi
                    done
            done
    }

function delete_dir()
    {
        for node in ${NODES[@]}
            do
                for element in ${array[@]}
                    do
                        dirname="mongo$1-$element"
                        ssh root@$node "rm -rf /opt/$dirname/*"
                        if [ $? -ne 0 ]; then
                            echo -e "\033[31m delete $node /opt/$dirname fail \033[0m"
                        else
                            echo -e "\033[32m delete $node /opt/$dirname success \033[0m"
                        fi
                    done
            done
    }
