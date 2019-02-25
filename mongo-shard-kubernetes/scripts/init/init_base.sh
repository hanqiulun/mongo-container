#!/bin/bash


source scripts/config

BASE="sources/"

# create secret keyfile
openssl rand -base64 64 > keyfile
chmod 600 keyfile

kubectl create secret generic keyfile --from-file=keyfile

kubectl create configmap mongo-config --from-file=$BASE"mongod_config.conf"

#Creating config nodes
kubectl create -f  $BASE"mongo_config.yaml"

#Waiting for containers
echo "Waiting config containers"
kubectl get pods | grep "mongocfg" | grep "ContainerCreating"
while [ $? -eq 0 ]
do
  sleep 1
  echo -e "\n\nWaiting the following containers:"
  kubectl get pods | grep "mongocfg" | grep "ContainerCreating"
done

sleep 5

#Initializating configuration nodes
POD_NAME=$(kubectl get pods | grep "mongocfg1" | awk '{print $1;}')
echo "Initializating config replica set... connecting to: $POD_NAME"
CMD='rs.initiate({ _id : "cfgrs", configsvr: true, members: [{ _id : 0, host : "mongocfg1:27019" },{ _id : 1, host : "mongocfg2:27019" },{ _id : 2, host : "mongocfg3:27019" }]})'
kubectl exec -it $POD_NAME -- bash -c "mongo --port 27019 --eval '$CMD'"


#Initializing routers
kubectl create -f $BASE"mongos.yaml"
echo "Waiting router containers"
kubectl get pods | grep "mongos[0-9]" | grep "ContainerCreating"
while [ $? -eq 0 ]
do
  sleep 1
  echo -e "\n\nWaiting the following containers:"
  kubectl get pods | grep "mongos[0-9]" | grep "ContainerCreating"
done


#create root user
sleep 10
POD_NAME=$(kubectl get pods | grep "mongos1" | awk '{print $1;}')
mongo_command=$(cat scripts/init/create_user_root.js)
kubectl exec -it $POD_NAME -- bash -c "mongo --eval '$mongo_command'"
sleep 2
mongo_command=$(cat scripts/init/create_user_user.js)
kubectl exec -it $POD_NAME -- bash -c "mongo -u root -p root --eval '$mongo_command'"

echo -e "\033[32m All done!!! \033[0m"




