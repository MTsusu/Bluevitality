#分片多的话可以提升建立索引的能力，5~20个比较合适，分片数过少或过多都会导致检索比较慢。
#分片数过多会导致检索时打开较多文件，另外也会导致多台服务器间通讯，而分片数过少会导至单个分片索引过大，所以检索速度也会慢。
#建议单个分片最多存储20G左右的索引数据，所以分片数量=数据总量/20G
-------------------------------------------------------------------------------------------------------
#设置每个节点的磁盘写入速率，默认20MB/s
PUT /_cluster/settings
{
    "persistent" : {
        "indices.store.throttle.max_bytes_per_sec" : "100mb"
    }
}

#如果你使用的是机械磁盘而非 SSD，需要添加下面配置到 elasticsearch.yml 里：
#机械磁盘在并发 I/O 支持方面比较差，所以我们需要降低每个索引并发访问磁盘的线程数
index.merge.scheduler.max_thread_count: 1

#在Kibana执行数据迁移 ( 先创建Mapping )
#必须使用该reindex.remote.whitelist属性在elasticsearch.yaml中将远程主机明确列入白名单
#它可设为逗号分隔的允许远程host和port组合列表（如 otherhost:9200, another:9200, 127.0.10.*:9200, localhost:*）
POST _reindex
{
  "source": {
    "remote": {
      "host": "http://172.19.72.219:9200",		#源INDEX所在集群地址
      "username": "elastic",
      "password": "x^sqzb%1"
    },
    "index": "isc_identrecords_2018_12",
    "query": {
        "bool": {
            "must": [
                {
                    "match_all": {}
                }
            ]
        }
      }
  },
  "dest": {
    "index": "isc_identrecords_2018_12"
  }
}

#在Logstash执行数据迁移 ( 先创建Mapping )
input {
  elasticsearch {
    hosts => ["XX.XX.XX.XX:9212","XX.XX.XX.XX:9212","XX.XX.XX.XX:9212"]
    index => "<INDEX>"
    size => 1250
    scroll => "5m"
    docinfo => true
    user => 'username...'
    password => "pass...."
  }
}

filter {
  mutate {
    remove_field => ["@version"]
  }
}

output {
  elasticsearch {
    hosts => ["XX.XX.XX.XX:9212","XX.XX.XX.XX:9212","XX.XX.XX.XX:9212"] 
    index => "<INDEX>"  
    document_type => "<type>"
    flush_size => 250
    codec => "json"
  }
}

#查看集群所有节点磁盘使用率
curl -XGET -s  '192.168.157.11:9212/_cat/allocation?v' | head -n 3
shards disk.indices disk.used disk.avail disk.total disk.percent host            ip              node
    27      988.1gb    14.8tb     11.7tb     26.6tb           55 192.168.157.11  192.168.157.11  157.11data-2
    28      866.8gb      14tb     12.5tb     26.6tb           52 192.168.157.14  192.168.157.14  157.14data-4

#修改触及"low disk watermark"阈值的磁盘使用比例（默认超过85%将不落主分片的副本）
#cluster.routing.allocation.disk.watermark.low:
#若磁盘使用超过85%则ES不允许在分配新的分片。当配置具体的大小如100MB时，表示若磁盘空间小于100MB则不允许分配分片
#cluster.routing.allocation.disk.watermark.high:
#磁盘空间使用高于90%时ES将尝试分配分片到其他节点
curl -XPUT 'localhost:9200/_cluster/settings' -d
'{
    "transient": {  
      "cluster.routing.allocation.disk.watermark.low": "90%",
      "cluster.routing.allocation.disk.watermark.high"："95%"
    }
}'

#修改集群数据节点宕机后延迟等待节点恢复，当失败时再分配分片的时间（默认1分钟）
curl -XPUT 'localhost:9200/<INDEX_NAME>/_settings' -d '
{
    "settings": {
      "index.unassigned.node_left.delayed_timeout": "30s"
    }
}'

#index/分片数 / 主分片还是副本分片 / 是否处于 unassigned 状态 / unassigned 的原因
curl -XGET -s  '192.168.157.11:9212/_cat/shards?v&h=index,shard,prirep,state,unassigned.reason' \
| grep UNASSIGNED \
| head -n 4
.monitoring-es-6-2019.01       0     r      UNASSIGNED INDEX_CREATED
frontanalysis_2018_12_29       8     r      UNASSIGNED INDEX_CREATED
frontanalysis_2018_12_29       4     r      UNASSIGNED INDEX_CREATED
frontanalysis_2018_12_29       9     r      UNASSIGNED INDEX_CREATED


#显示集群系统信息,包括CPU JVM等等
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_cluster/stats?pretty=true

#集群的详细信息,包括节点、分片等
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_cluster/state?pretty=true

#获取集群堆积任务
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_cluster/pending_tasks?pretty=true
{
  "tasks" : []
}

#查看未分配的分片信息
[wangyu@localhost Test]$ curl -s -u 'elastic:241yftest' '192.168.157.11:9213/_cat/shards?v' | grep UNASSIGNED
index shard prirep state      docs store ip           node   
users 1     r      UNASSIGNED                                
users 2     r      UNASSIGNED                                
users 0     r      UNASSIGNED

#修改集群配置 ( transient 表示临时的，persistent表示永久的 )
#举例：
[wangyu@localhost Test]$ curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'

#统计ES某个索引数据量：
[wangyu@localhost Test]$ curl -XGET '10.110.79.22:9200/_cat/count/new-sgs-rbil-core-sys'

#获取mapping
[wangyu@localhost Test]$ curl -XGET http://localhost:9200/{index}/{type}/_mapping?pretty

#查看模板：
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_template/fvp_waybillnewstatus_template

#关闭指定192.168.1.1节点
[wangyu@localhost Test]$ curl -XPOST 'http://localhost:9200/_cluster/nodes/192.168.1.1/_shutdown'

#查看所有的索引文件
[wangyu@localhost Test]$ curl localhost:9200/_cat/indices?v
health status index               pri rep docs.count docs.deleted store.size pri.store.size 
yellow open   filebeat-2015.12.24   5   1       3182            0        1mb            1mb 
yellow open   logstash-2015.12.23   5   1        100            0    235.8kb        235.8kb 
yellow open   logstash-2015.12.22   5   1         41            0    126.5kb        126.5kb 
yellow open   .kibana               1   1         94            0    102.3kb        102.3kb 

#删除索引文件以释放空间
curl -XDELETE http://10.0.0.3:9200/filebeat-2016.12.28

#查看ES集群中各节点的磁盘使用率
[wangyu@localhost ~]$ curl -XGET 10.0.0.3:9200/_cat/allocation?v
shards disk.indices disk.used disk.avail disk.total disk.percent host     ip       node
     7      173.1kb       3gb     14.4gb     17.4gb           17 10.0.0.3 10.0.0.3 node1

#返回状态非404的
curl -XGET 'localhost:9200/logstash-2015.12.23/_search?q=response=404&pretty'

#查来自Buffalo的
curl -XGET 'localhost:9200/logstash-2015.12.23/_search?q=geoip.city_name:Buffalo&pretty'

#查看节点状态
#get _nodes/hot_threads
#get _nodes/node-1/hot_threads

## Select nodes by role
GET /_nodes/_all,master:false
GET /_nodes/data:true,ingest:true
GET /_nodes/coordinating_only:true

#当分片不足时的等待时间 (等待节点重新启动，分片恢复) 默认1min
curl -XPOST http://localhost:9200/blogs/normal?consistency=all&timeout=10s -d '
{
  "name" : "POST-1"
}
'

#查看集群负载相关信息
[root@node3 elasticsearch]# curl -X GET http://localhost:9200/_cat/nodes?v      
host        ip          heap.percent ram.percent load node.role master name 
192.168.0.7 192.168.0.7            5          76 0.25 d         m      node3
192.168.0.6 192.168.0.6            6          67 0.16 d         *      node2 
192.168.0.5 192.168.0.5            5          68 0.08 d         m      node1   

#查看集群health相关信息
[root@node1 ~]# curl -X GET http://localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

#迁移节点分片
curl -XPOST '172.18.1.22:9200/_cluster/reroute' -d  '{
    "commands" : [
        {
            "move" : {
                "index" : "info-test", "shard" : 3,
                "from_node" : "172.18.1.26", "to_node" : "172.18.1.25"
            }
        }
    ]
}'
#强制迁移主分片
curl -XPOST 'localhost:9200/_cluster/reroute' -d '{
    "commands": [
        {
            "allocate": {
                "allow_primary": "true",
                "index": "constant-updates",
                "node": "<NODE_NAME>",
                "shard": 0
            }
        }
    ]
}'

#查看节点详细信息
curl -XGET  s '192.168.166.66:9212/_nodes/<NODE_NAME>?pretty' | head -n 30

#至少有几个分片可用的情况下才认为是可用的（主+副分片）默认索引操作只需要主分片可用时：wait_for_active_shards:1 即可
curl -XPUT http://localhost:9200/blogs/_settings -d '
{
	"index.write.wait_for_active_shards": 3
}
'

#查看当前节点health相关信息
[root@node3 ~]# curl -X GET http://localhost:9200/_cat/health                   
1514807391 19:49:51 elasticsearch green 1 1 0 0 0 0 0 0 - 100.0%

#监视集群中的挂起任务，类似于创建索引、更新映射、分配碎片、故障碎片等
GET http://localhost:9200/_cluster/pending_tasks


#当关闭节点时，分配进程会等待 index.unassigned.node_left.delayed_timeout（默认为1分钟）
#然后开始将该节点上的分片复制到其他节点，这可能涉及大量I/O.
#某些情况下节点很快将重新启动，因此不需要此I/O，可以通过在关闭节点之前禁用分配来避免时钟竞争：
PUT _cluster/settings
{
  "persistent": {     //persistent ---> 即永久生效，重启仍可用
    "cluster.routing.allocation.enable": "none"
  }
}
#集群重启后再改回配置：curl -XPUT http://127.0.0.1:9200/_cluster/settings -d 
'{
    "transient" : {
        "cluster.routing.allocation.enable" : "all"
    }
}'

#在升级下个节点前，请等待群集完成分片分配。可通过提交_cat/health请求来检查进度：GET _cat / health


#同时为多个索引映射到一个索引别名
curl -XPOST 'http://192.168.80.10:9200/_aliases' -d '
{
    "actions" : [
        { "add" : { "index" : "zhouls", "alias" : "zhouls_all" } },
        { "add" : { "index" : "zhouls10", "alias" : "zhouls_all" } }
    ]
}'

#删除索引zhouls映射的索引别名zhouls_all
curl -XPOST 'http://192.168.80.10:9200/_aliases' -d '
{
    "actions" : [
        { "remove" : { "index" : "zhouls", "alias" : "zhouls_all" } }
    ]
}'

#创建索引并指定其分配和副本、映射关系
PUT twitter
{
    "settings" : {
        "index" : {
            "number_of_shards" : 3, 
            "number_of_replicas" : 2 
        }
    },
   "mappings" : {
        "type1" : {
            "properties" : {
                "field1" : { "type" : "text" }
            }
        }
    }
}

#索引统计
GET my_index/_stats
GET my_index,another_index/_stats
GET _all/_stats

移动分片：（当本机存储不够用，负载高时）
$curl -XPOST 'http://localhost:9200/_cluster/reroute' -d '{
    "commands":[{
        "move":{
            "index":"filebeat-ali-hk-fd-tss1",
            "shard":1,
            "from_node":"ali-hk-ops-elk1",
            "to_node":"ali-hk-ops-elk2"
        }
    }]
}'

#分配分片：( 如down机后启动时本机分片未加入索引中的情况 )
$curl -XPOST 'http://localhost:9200/_cluster/reroute' -d '{
    "commands":[{
            "allocate":{
            "index":"filebeat-ali-hk-fd-tss1",
            "shard":1,
            "node":"ali-hk-ops-elk1"
        }
    }]
}'

#排除写入某节点（不必要的参数要省略掉）
#index.routing.allocation.require.	【必须】
#index.routing.allocation.include. 	【允许】
#index.routing.allocation.exclude.	【排除】
"settings": {
  "index":{
    "routing":{
      "allocation":{
        "exclude":{
          "_ip": "192.168.157.19"
        },
        "total_shards_per_node": "5"
      }
    },
  "refresh_interval":"60s",
  "number_of_shards":"200",
  "provided_name":"log4x_trace_2018_11_24",
  "creation_date":"1542988801497",
  "number_of_replicas":"0",
  "uuid":"kjsdfhjksdhfjksdhjfhsdfsdjkfhsdjk",
  "version":{
    "created":"5050099"
  }
  }
}

#集群设置
PUT /_cluster/settings
{
    "transient" : {
        "logger.index.search.slowlog" : "DEBUG",  #针对搜索的情况（级别以上,是">="的关系）
        "logger.index.indexing.slowlog" : "WARN"  #针索引写入的情况
    }
}

#索引级别（query：获取索引内的数据，fetch：ORZ....）
PUT /<INDEX>/_settings
{
    "index.search.slowlog.threshold.query.warn": "10s",   #大于10s即属于WARN级别以上的
    "index.search.slowlog.threshold.query.info": "6s",    #...
    "index.search.slowlog.threshold.fetch.warn": "1800ms", 
    "index.search.slowlog.threshold.fetch.info": "1s" 
}

#查看索引的数据在ES节点内执行段合并的信息（将小数据文件合并成大文件，提高查询效率）
GET _cat/segments/log4x_trace_2018_12_12?v&h=index,ip,segment,size
GET log4x_csf_2018_12_12/_segments
POST log4x_trace_2018_12_12/_forcemerge?max_num_segments=700


#Create a logstash_writer role that has the manage_index_templates and monitor cluster privileges, and the write, delete, and 
#create_index privileges for the Logstash indices. You can create roles from the Management > Roles UI in Kibana or through the role API
#ES 6.4版本： 在对应的manage_index_templates、monitor的2个集群对logstash-*开头的索引创建对应的权限，权限ROLE名为：logstash_writer
POST _xpack/security/role/logstash_writer
{
  "cluster": ["manage_index_templates", "monitor"],
  "indices": [
    {
      "names": [ "logstash-*" ], 
      "privileges": ["write","delete","create_index"]
    }
  ]
}
#Create a logstash_internal user and assign it the logstash_writer role. You can create users
#from the Management > Users UI in Kibana or through the user API:
POST _xpack/security/user/logstash_internal
{
  "password" : "x-pack-test-password",
  "roles" : [ "logstash_writer"],
  "full_name" : "Internal Logstash User"
}

#Logstash Exapmle:
input {
  elasticsearch {
    ...
    user => logstash_internal
    password => x-pack-test-password
  }
}
filter {
  elasticsearch {
    ...
    user => logstash_internal
    password => x-pack-test-password
  }
}
output {
  elasticsearch {
    ...
    user => logstash_internal
    password => x-pack-test-password
  }
}

#分组聚合查询
#https://www.elastic.co/guide/en/elasticsearch/reference/6.0/search-aggregations-metrics-sum-aggregation.html
#搜索：
POST /sales/_search?size=0
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "match" : { "type" : "hat" }
            }
        }
    },
    "aggs" : {
        "hat_prices" : { "sum" : { "field" : "price" } }
    }
}
#返回:
{
    ...
    "aggregations": {
        "hat_prices": {
           "value": 450.0
        }
    }
}

#使用文档局的部更新
curl -XPOST http://localhost:9200/blogs/normal/format-doc-001/_update -d '
{
  "doc": {  #"doc"可以理解为针对文档内容进行的修改
  	"title" : "springboot in action",
	  "author" : "Format"
  }
}
'
#获取：
curl -XGET http://localhost:9200/blogs/normal/format-doc-001

{
    "_index": "blogs",
    "_type": "normal",
    "_id": "format-doc-001",
    "_version": 3,
    "found": true,
    "_source": {
        "create_at": "2017-07-18",
        "author": "Format",
        "title": "springboot in action"
    }
}

#值递增（使用脚本局部更新新创建的文档）
curl -XPOST http://localhost:9200/blogs/normal/format-doc-002/_update -d '{
  "script" : "ctx._source.views+=1"
}
'
#报错：因为id为format-doc-002的文档不存在
# 加上upsert参数(设置字段的初始值)
curl -XPOST http://localhost:9200/blogs/normal/format-doc-002/_update -d '{
  "script" : "ctx._source.views+=1",
  "upsert": {
       "views": 1
   }
}'
#获取文档
curl -XGET http://localhost:9200/blogs/normal/format-doc-002
{
    "_index": "blogs",
    "_type": "normal",
    "_id": "format-doc-002",
    "_version": 1,
    "found": true,
    "_source": {
        "views": 1
    }
}

#3个批量操作，分别是创建文档，更新文档以及删除文档
#创建文档时需要使用换行分割开创建目录和文档数据，更新文档时也需用换行分开创建目录和文档，最后一个操作要用换行结束
curl -XPOST http://localhost:9200/_bulk --d '
{ "create": { "_index": "blogs", "_type": "normal", "_id": "format-bulk-doc-001" } }
{ "title": "Hadoop in action", "author": "Chuck Lam" }
{ "update": { "_index": "blogs", "_type": "normal", "_id": "format-bulk-doc-001" } }
{ "doc": { "create_at": "2017-07-19" } }
{ "delete": { "_index": "blogs", "_type": "normal", "_id": "format-doc-002" } }
