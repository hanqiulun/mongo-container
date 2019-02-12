# mongo-container


1 . [:mortar_board:mongo-shard-docker-compose](##1-mongo-shard-docker-compose)
## mongo-shard-docker-compose

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
