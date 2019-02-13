
#!/bin/bash

POD_NAME=$(kubectl get pods | grep "mongos1" | awk '{print $1;}')

CMDS=("use config",'db.settings.save({"_id":"chunksize","value":1})',"use python",'for(i=1;i<=50000;i++){db.user.insert({"id":i,"name":"jack"+i})}','sh.enableSharding("python")','db.user.createIndex({"id":1})','sh.shardCollection("python.user",{"id":1})',"sh.status()")
for CMD in ${CMDS[@]}
do
echo $CMD
kubectl exec -it $POD_NAME -- bash -c "mongo --eval '$CMD'"
done
