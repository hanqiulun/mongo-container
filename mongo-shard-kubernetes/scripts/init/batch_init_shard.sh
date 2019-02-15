#!/bin/bash


source scripts/config
source scripts/init/init_shard.sh

for ((rs=1; rs<=$SHARD_REPLICA_SET; rs++)) do
    init_shard $rs
done