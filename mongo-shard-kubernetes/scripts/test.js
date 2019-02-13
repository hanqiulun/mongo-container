
sh.status();
var db = db.getSiblingDB( "config" );
db.settings.save({"_id":"chunksize","value":1});
var db = db.getSiblingDB( "python" );
for(i=1;i<=50000;i++){db.user.insert({"id":i,"name":"jack"+i})};
sh.enableSharding("python");
db.user.createIndex({"id":1});
sh.shardCollection("python.user",{"id":1});
sh.status();

