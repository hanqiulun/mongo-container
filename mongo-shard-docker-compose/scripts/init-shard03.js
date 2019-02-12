rs.initiate(
   {
      _id: "shard03",
      version: 1,
      members: [
         { _id: 0, host : "shard03a:27020", priority:2 },
         { _id: 1, host : "shard03b:27020", priority:1 },
         { _id: 2, host : "shard03c:27020", arbiterOnly:true },
      ]
   }
)
