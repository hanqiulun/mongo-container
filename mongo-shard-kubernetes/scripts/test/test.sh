#!/bin/bash

POD_NAME=$(kubectl get pods | grep "mongos1" | awk '{print $1;}')

mongo_command=$(cat scripts/test/test.js)
kubectl exec -it $POD_NAME -- bash -c "mongo -u root -p root --eval '$mongo_command'"