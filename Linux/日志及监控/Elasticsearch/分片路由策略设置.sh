#集群级别
PUT _cluster/settings
{
  "persistent": {
    "cluster": {
      "routing": {
        "allocation.cluster_concurrent_rebalance": 2,  #最多允许多少分片同时迁移，默认2 ( 此参在关闭负载时建议不写 )
        "allocation.enable": "all"                     #用那种方式路由，有好几种参数 ( 关闭集群负载，使用：none )
      }
    }
  },
  "transient": {
    "cluster": {
      "routing": {
        "allocation.cluster_concurrent_rebalance": 2,
        "allocation.enable": "all"
      }
    }
  }
}


#索引级别
PUT log4x_interface_2018_08_20/_settings
{
  "index.routing.allocation.total_shards_per_node" : 3    #一个es-data节点上最多分3个分片
}


#参考：
#https://blog.csdn.net/an74520/article/details/42871023

#在一个已经创立的集群里，shard的分布总是均匀的。但是当你扩容节点的时候，你会发现，它总是先移动replica shard到新节点。
#这样就导致新节点全部分布的全是副本，主shard几乎全留在了老的节点上。

#cluster.routing.allocation.balance参数，比较难找到合适的比例。

#建议一种方式是在扩容的时候，设置cluster.routing.allocation.enable=primaries。指只允许移动主shard。
#当你发现shard数已经迁移了一半的时候，改回cluster.routing.allocation.enable=all。这样后面的全迁移的是副本shard。
#扩容之后，shard和主shard的分布还是均匀的。
#curl -XPUT ‘http://192.168.1.1:9200/_cluster/settings’ -d ‘{
#“transient” : {
#“cluster.routing.allocation.enable” : “primaries”
#}
#}’

#那如果shard分布已经不均匀了，也可以手动进行shard迁移。
#curl -XPOST ‘http://192.168.1.1:9200/_cluster/reroute’ -d ‘{
#“commands” : [ {
#“move” :
#{
#“index” : “index_1”, “shard” : 23,
#“from_node” : “192.168.1.1”, “to_node” : “192.168.1.2”
#}
#}
#]
#}’
