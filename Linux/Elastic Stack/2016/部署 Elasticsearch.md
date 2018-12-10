#### 环境
```txt
        [Node1] -- 192.168.0.5
        [Node2] -- 192.168.0.6
        [Node3] -- 192.168.0.7
```
```bash
#在实验环境中前几次部署不成功，down掉了docker相关的网桥之后才好，有可能是docker0或swarm的overlay的网桥导致的...

#分别在各Node节点执行如下：
#elasticsearch的RPM包下载地址：https://pan.baidu.com/s/1pK9B51L 密码：481m

any_node ~]# yum -y install java-1.8.0-openjdk
any_node ~]# yum -y install java-1.8.0-openjdk-devel.x86_64
any_node ~]# echo "export JAVA_HOME=/usr" > /etc/profile.d/java.sh   #要保证环境变量JAVA_HOME正确设置
any_node ~]# . /etc/profile                                          #Elastic需要Java与Java-devel环境...
any_node ~]# yum -y install elasticsearch-2.4.0.rpm  #本地安装

any_node ~]# vim /etc/elasticsearch/elasticsearch.yml 
cluster.name: elasticsearch             #加入的集群名称（组播协议中依此设置加入集群）
node.name: nodeX                        #当前节点名称

network.bind_host: 192.168.0.1          #绑定的ip地址，可以是ipv4或ipv6的，默认 0.0.0.0
network.publish_host: 192.168.0.1       #其它节点和该节点交互的地址，如果不设置它会自动判断
network.host: 0.0.0.0                   #这个参数是用来同时设置bind_host和publish_host上面两个参数

discovery.zen.ping.unicast.hosts: ["192.168.0.5:9300","192.168.0.6:9300","192.168.0.7:9300"]  #所有节点地址

node.master: true                       #该节点是否有资格被选举为master，默认true
index.number_of_shards: 1               #切片数量，单节点时为1
index.number_of_replicas: 0             #副本数量，单节点时为0
transport.tcp.port: 9300                #参与集群事物（使用9200端口接收用户请求）

#discovery.zen.minimum_master_nodes:    #最少主节点数量

any_node ~]# systemctl daemon-reload
any_node ~]# systemctl start elasticsearch.service
any_node ~]# systemctl enable elasticsearch.service

#检查
any_node ~]# ss -atn src :9300 &&  ss -atn src :9300
State      Recv-Q Send-Q          Local Address:Port        Peer Address:Port              
LISTEN     0      128          ::ffff:127.0.0.1:9300                  :::*                  
LISTEN     0      128                       ::1:9300                  :::*                  
State      Recv-Q Send-Q          Local Address:Port        Peer Address:Port              
LISTEN     0      128          ::ffff:127.0.0.1:9300                  :::*                  
LISTEN     0      128                       ::1:9300                  :::*
```
#### 验证安装   -   注：对Elasticsearch的所有访问都是通过ES的Restful API进行的，因此，在Linux下要使用curl命令...
```bash
any_node ~]# curl -X GET http://localhost:9200/_cluster/stats?pretty    #查看集群状态信息
#使用'_cluster'这个API说明是通过集群接口执行的（ES中的API均使用下划线开头来表示）

#使用ES的："_cat" API进入交互式提示界面...
[root@node3 ~]# curl -X GET http://localhost:9200/_cat/
=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/tasks                                        #
/_cat/indices                                      #
/_cat/indices/{index}                              # 各子参数下使用参数?v可显示详细信息（附带说明）
/_cat/segments                                     # ?help 显示各字段帮助信息
/_cat/segments/{index}                             # ?h=arg1,arg2,arg3 定制显示各参数
/_cat/count                                        #
/_cat/count/{index}                                #
/_cat/recovery                                     #
/_cat/recovery/{index}                             #
/_cat/health                                       #
/_cat/pending_tasks                                #
/_cat/aliases                                      #
/_cat/aliases/{alias}                              #
/_cat/thread_pool                                  #
/_cat/thread_pool/{thread_pools}                   #
/_cat/plugins                                      #
/_cat/fielddata                                    #
/_cat/fielddata/{fields}                           #
/_cat/nodeattrs                                    #
/_cat/repositories                                 #
/_cat/snapshots/{repository}                       #
/_cat/templates                                    #

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

#查看当前节点health相关信息
[root@node3 ~]# curl -X GET http://localhost:9200/_cat/health                   
1514807391 19:49:51 elasticsearch green 1 1 0 0 0 0 0 0 - 100.0%

#查看当前节点信息（直接访问即可，不需要写任何API或参数）...
[root@node3 ~]#  curl -s http://127.0.0.1:9200/?pretty
{
  "name" : "node3",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "STS3thTgT8CVo_-fatsSpg",
  "version" : {
    "number" : "6.1.1",
    "build_hash" : "bd92e7f",
    "build_date" : "2017-12-17T20:23:25.338Z",
    "build_snapshot" : false,
    "lucene_version" : "7.1.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```
