# mongo-container


1 . [:mortar_board:mongo-shard-docker-compose](##1-mongo-shard-docker-compose)

2 . [:mortar_board:mongo-shard-kubernetes](##2-mongo-shard-kubernetes)

## 1 mongo-shard-docker-compose

### Init Process

1. Startup docker service

```shell
docker-compose up -d
```

2. Init mongo sharding

```shell
sh init.sh
```
3. Watch result

```shell
docker-compose exec router mongo

mongos>sh.status()
```
4. Test

4.1 adjust chunksize to test
```shell
mongos> use config
switched to db config
mongos> db.settings.save({"_id":"chunksize","value":1})   //设置块大小为1M是方便实验，不然就需要插入海量数据
WriteResult({ "nMatched" : 0, "nUpserted" : 1, "nModified" : 0, "_id" : "chunksize" })
```

4.2 add some test data
```shell
mongos> use python
switched to db python
mongos> show collections
mongos> for(i=1;i<=50000;i++){db.user.insert({"id":i,"name":"jack"+i})}
//在python库的user表中循环写入五万条数据
WriteResult({ "nInserted" : 1 })
```

4.3 make database sharding
```shell
mongos>sh.enableSharding("python")
//数据库分片就有针对性，可以自定义需要分片的库或者表，毕竟也不是所有数据都是需要分片操作的
```

4.4 create index
```shell
mongos> db.user.createIndex({"id":1})   //以”id“为索引

```

4.5 make collection sharding and ppointed id as shard key
```shell
mongos> sh.shardCollection("python.user",{"id":1})

```

4.6 view result
```shell
mongos> sh.status()
//collection的primary shard是shard02,所以一开始的chunk会在shard02分裂，后来发生chunk迁移。
```


## 2 mongo-shard-kubernetes

### Init Process

1. set config

```
vim scripts/config
```

2. start init

```
./scripts/initiate.sh
```

waiting...... it's so so so long

3. test

```
sh scripts/test.sh
```
then you will see result

```
mongos> sh.status()
--- Sharding Status --- 
  sharding version: {
  	"_id" : 1,
  	"minCompatibleVersion" : 5,
  	"currentVersion" : 6,
  	"clusterId" : ObjectId("5c64001ae422b54bb4fefbd0")
  }
  shards:
        {  "_id" : "rs1",  "host" : "rs1/mongosh1-1:27017,mongosh1-2:27017,mongosh1-3:27017",  "state" : 1 }
        {  "_id" : "rs2",  "host" : "rs2/mongosh2-1:27017,mongosh2-2:27017,mongosh2-3:27017",  "state" : 1 }
        {  "_id" : "rs3",  "host" : "rs3/mongosh3-1:27017,mongosh3-2:27017,mongosh3-3:27017",  "state" : 1 }
        {  "_id" : "rs4",  "host" : "rs4/mongosh4-1:27017,mongosh4-2:27017,mongosh4-3:27017",  "state" : 1 }
  active mongoses:
        "4.0.6" : 1
  autosplit:
        Currently enabled: yes
  balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours: 
                4 : Success
  databases:
        {  "_id" : "config",  "primary" : "config",  "partitioned" : true }
                config.system.sessions
                        shard key: { "_id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                rs1	1
                        { "_id" : { "$minKey" : 1 } } -->> { "_id" : { "$maxKey" : 1 } } on : rs1 Timestamp(1, 0) 
        {  "_id" : "python",  "primary" : "rs3",  "partitioned" : true,  "version" : {  "uuid" : UUID("3fca6b2b-efcb-45be-a67d-5819529562bc"),  "lastMod" : 1 } }
                python.user
                        shard key: { "id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                rs1	1
                                rs2	1
                                rs3	2
                                rs4	2
                        { "id" : { "$minKey" : 1 } } -->> { "id" : 9893 } on : rs1 Timestamp(2, 0) 
                        { "id" : 9893 } -->> { "id" : 19786 } on : rs2 Timestamp(3, 0) 
                        { "id" : 19786 } -->> { "id" : 29679 } on : rs4 Timestamp(4, 0) 
                        { "id" : 29679 } -->> { "id" : 39572 } on : rs4 Timestamp(5, 0) 
                        { "id" : 39572 } -->> { "id" : 49465 } on : rs3 Timestamp(5, 1) 
                        { "id" : 49465 } -->> { "id" : { "$maxKey" : 1 } } on : rs3 Timestamp(1, 5) 
        {  "_id" : "python1",  "primary" : "rs2",  "partitioned" : false,  "version" : {  "uuid" : UUID("d307583f-c4f8-44b0-b5af-b2d2efd04c7e"),  "lastMod" : 1 } }

```

5w data has been split to some shard