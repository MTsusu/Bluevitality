```txt
Elasticsearch是实时的分布式搜索和分析引擎，可用于全文搜索，结构化搜索以及分析。
它是建立在全文搜索引擎 Apache Lucene 基础上的搜索引擎，使用 Java 编写。

ES Version >= 5.x 的 head 不能放在ES的plugins、modules下且不再用 "elasticsearch-plugin install" ( 作为独立软件 )

Elastic v5.5.0
其他依赖和插件：
    Jdk1.8
    Nodejs   作为head插件的依赖
    Head     提供Node管理及可视化RestfulAPI接口
    Kibana
    x-pack   必须运行与Elasticsearch版本相匹配的X-Pack版本!
    ik       同上，此插件需maven进行打包...
```
#### 软件
```txt
   32M  elasticsearch-5.5.0.tar.gz
  812K  elasticsearch-head-master.tar.gz
  3.2M  elasticsearch-analysis-ik-5.5.0.zip
  173M  jdk.tar.gz
   16M  node-v8.1.4-linux-x64.tar.gz
  153M  x-pack-5.5.0.zip
```
#### 部署 Elasticsearch 5.5.0
```bash
#ES5.X依赖JAVA Version >= 1.8，注! ES不能运行在CentOS7以下的版本上
#集群中的节点可分为：Master nodes、Data nodes、Client node
#在配置文件中使用Zen发现"Zen discovery"机制来管理不同节点，Zen发现是ES自带的默认发现机制，其用多播发现其它节点。
#只要启动1个新ES节点并设置和集群相同的名称，此节点即被加入到集群

#ES需要运行在非Root用户下，建议使用普通账户部署JDK
[wangyu@localhost ~]$ mkdir elasticsearch
[wangyu@localhost ~]$ tar -zxf jdk.tar.gz -C /home/wangyu/elasticsearch
[wangyu@localhost ~]$ ln -s /home/wangyu/elasticsearch/jdk1.8.0_101 /home/wangyu/elasticsearch/jdk
[wangyu@localhost ~]$ cd /home/wangyu/elasticsearch/jdk
[wangyu@localhost ~]$ export JAVA_HOME=$(pwd) && export PATH=$JAVA_HOME/bin:$PATH
[wangyu@localhost ~]$ echo "PATH=$PATH" >> ~/.bash_profile && . ~/.bash_profile

#cat  ~/.bash_profile  <--- 针对普通用户JAVA_HOME的例子
#PATH=$PATH:$HOME/.local/bin:$HOME/bin
#export PATH
#export JAVA_HOME=/home/wangyu/jdk
#export CLASSPATH=.${JAVA_HOME}/lib
#export PATH=${JAVA_HOME}/bin:$PATH
#export LANG=zh_CH.UTF-8

#ES对ulimit有要求，此操作需Root权限对安装ES的用户修改ulimit配额，最终使用非root账户启动ES
[root@localhost ~]# yum -y install bzip2 git unzip maven
[root@localhost ~]# cat >> /etc/security/limits.conf <<eof
* soft nofile 655350        #
* hard nofile 655350        #进程最大打开文件描述符
* soft nproc 655350
* hard nproc 655350
eof

#修改 /proc
[root@localhost ~]# cat >> /etc/sysctl.conf <<eof
fs.file-max = 1000000       #系统最大打开文件描述符数
vm.max_map_count=262144
vm.swappiness = 1
eof

[root@localhost ~]# vim /etc/security/limits.d/90-nproc.conf  #添加or修改如下1行参数
* soft nproc 102400
[root@localhost ~]# sysctl -p

#ES的三个配置文件说明
config/elasticsearch.yml   #主配置文件
config/jvm.options         #JVM参数配置文件   ---> 分配JVM内存: ES_HEAP_SIZE=4g
cofnig/log4j2.properties   #日志配置

#部署 Master Node
[wangyu@localhost ~]$ cd ~ && tar -zxf elasticsearch-5.5.0.tar.gz -C ./elasticsearch/
[wangyu@localhost ~]$ vim ~/elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
#path.data: /home/wangyu/elasticsearch/elasticsearch-5.5.0/data     #建议使用默认
#path.logs: /home/wangyu/elasticsearch/elasticsearch-5.5.0/logs     #
cluster.name: ES-Cluster            #加入的集群名称
node.name: "node1"                  #当前节点名称
network.host: 10.0.0.3              #本节点与其他节点交互时使用的地址，即可访问本节点的路由地址
transport.tcp.port: 19300           #参与集群事物的端口（使用9200端口接收用户请求）
http.port: 9200                     #使用9200接收用户请求（路由地址端口）
http.cors.enabled: true             #由HEAD插件使用
http.cors.allow-origin: "*"         #由HEAD插件使用
node.master: true                   #非Master节点应设为false
node.data: false                    #若Master节点不存储数据时
#discovery.zen.ping.timeout: 200s
discovery.zen.ping.unicast.hosts: "10.0.0.3:19300,.....,......"     #所有Master组成的列表
#discovery.zen.ping.multicast.enabled: false
#index.number_of_shards:5           #以下3行配置建议在HEAD插件中指定
#index.number_of_replicas:0         #
#index.refresh_interval:120s        #

#部署 DataNode/ClientNode （在其他的节点，以下的部分配置省略）
[wangyu@localhost ~]$ tar -zxf elasticsearch-5.5.0.tar.gz -C ./elasticsearch/
[wangyu@localhost ~]$ vim elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
path.data: /home/wangyu/elasticsearch/elasticsearch-5.5.0/data
path.logs: /home/wangyu/elasticsearch/elasticsearch-5.5.0/logs
cluster.name: ES-Cluster
node.name: "1node1"
network.host: 10.0.0.4
transport.tcp.port: 19300
http.port: 9200
#http.cors.enabled: true
#http.cors.allow-origin: "*"
node.master: true                   #该节点是否有资格被选举为master，默认true
discovery.zen.ping.unicast.hosts: "10.0.0.3:19300,.....,......" 

#安装HEAD
[wangyu@localhost ~]$ tar -zxf elasticsearch-head-master.tar.gz -C /home/wangyu/elasticsearch/
[wangyu@localhost ~]$ ln -s ~/elasticsearch/elasticsearch-head-master ~/elasticsearch/head

#安装Nodejs （Node是HEAD插件的依赖）
[wangyu@localhost ~]$ cd ~ && tar -zxf node-v8.1.4-linux-x64.tar.gz -C /home/wangyu/elasticsearch/
[wangyu@localhost ~]$ cd /home/wangyu/elasticsearch/node-v8.1.4-linux-x64/
[wangyu@localhost node-v8.1.4-linux-x64]$ export NODE_HOME=$(pwd)
[wangyu@localhost node-v8.1.4-linux-x64]$ export PATH=$NODE_HOME/bin:$PATH && echo "PATH=$PATH" >> ~/.bash_profile
[wangyu@localhost node-v8.1.4-linux-x64]$ . ~/.bash_profile    #验证安装成功： node -v && npm -v

#由于head的代码还是2.6版本，有很多限制，如无法跨机器访问。因此要修改两个地方:
[wangyu@localhost ~]$ vim +92 /home/wangyu/elasticsearch/head/Gruntfile.js
connect: {
    server: {
        options: {              #约92行附近，增加hostname字段
            hostname: '*',      #
            port: 9100,
            base: '.',
            keepalive: true
        }
    }
}

#注意! 最小化安装的系统在执行如下命令前须开启root安装bzip2，npm下载文件时会使用其对文件进行解压
[wangyu@localhost ~]$ sed -i '4354s/localhost/10.0.0.4/' /home/wangyu/elasticsearch/head/_site/app.js 
[wangyu@localhost ~]$ npm install -g cnpm --registry=https://registry.npm.taobao.org  #若报错多执行几次
[wangyu@localhost ~]$ cd ~/elasticsearch/head/ ; cnpm install                         #根据此目录的XXX.js下载

#安装X-pack，安装成功后需修改ES配置才能使其配合HEAD插件使用（暂不安装，有问题）
[wangyu@localhost ~]$ cd ~/elasticsearch/elasticsearch-5.5.0/bin/
[wangyu@localhost bin]$ ./elasticsearch-plugin install file:///home/wangyu/x-pack-5.5.0.zip  #根据提示输入yes
# ES内的x-pack插件配置段如下：
# http.cors.allow-headers: "Authorization"
# xpack.security.enabled: false
# xpack.monitoring.exporters.my_local:
#   type: local
#   index.name.time_format: YYYY.MM

#安装IK分词，其版本须与ES严格一致，地址：https://github.com/medcl/elasticsearch-analysis-ik/tree/5.x
[wangyu@localhost bin]$ cd ~ && unzip elasticsearch-analysis-ik-5.5.0.zip -d ~/elasticsearch/
[wangyu@localhost bin]$ cd ~/elasticsearch/elasticsearch-analysis-ik-5.5.0
[wangyu@localhost elasticsearch-analysis-ik-5.5.0]$ mvn package #使用maven对源码进行打包，内存较小的话比较耗时
[wangyu@localhost elasticsearch-analysis-ik-5.5.0]$ mkdir -p ~/elasticsearch/elasticsearch-5.5.0/plugins/ik
[wangyu@localhost elasticsearch-analysis-ik-5.5.0]$ unzip -d ~/elasticsearch/elasticsearch-5.5.0/plugins/ik \
./target/releases/elasticsearch-analysis-ik-5.5.0.zip

#启动ES：
cd ~/elasticsearch/elasticsearch-5.5.0/bin/ && nohup ./elasticsearch -d &> /dev/null &

#启动HEAD
cd ~/elasticsearch/head/node_modules/grunt/bin/ && nohup ./grunt server &> /dev/null &
```
#### 测试ES的IK插件分词功能
```bash
[root@localhost ~]# curl -XGET 'http://10.0.0.3:9200/_analyze?pretty&analyzer=ik_max_word' -d '这是一个测试'
[root@localhost ~]# curl -XGET 'http://10.0.0.3:9200/_analyze?pretty&analyzer=ik_smart' -d '这是一个测试'
{
  "tokens" : [
    {
      "token" : "这是",
      "start_offset" : 0,
      "end_offset" : 2,
      "type" : "CN_WORD",
      "position" : 0
    },
    {
      "token" : "一个",
      "start_offset" : 2,
      "end_offset" : 4,
      "type" : "CN_WORD",
      "position" : 1
    },
    {
      "token" : "测试",
      "start_offset" : 4,
      "end_offset" : 6,
      "type" : "CN_WORD",
      "position" : 2
    }
  ]
}
```
####  Shard / segment
```txt
一个Shard就是一个Lucene实例，是一个完整的搜索引擎
一个索引可以只包含一个Shard，只是一般情况下会用多个分片，可以拆分索引到不同的节点上，分担索引压力。

elasticsearch中每个分片包含多个segment，每个segment都是一个倒排索引
在查询的时，会把所有的segment查询结果汇总归并后最为最终的分片查询结果返回；
在创建索引时elasticsearch会把文档信息写到内存bugffer中（为了安全，也同时写到translog）
定时（可配置）把数据写到segment缓存小文件中，然后刷新查询，使刚写入的segment可查。
虽然写入的segment可查询，但是还没有持久化到磁盘上。因此，还是会存在丢失的可能性的。
所以elasticsearch会执行flush操作，把segment持久化到磁盘并清除translog数据（因为此时数据已经写到磁盘，不在需要了） 

当索引数据不断增长时，对应的segment也会不断的增多，查询性能可能就会下降。
因此，Elasticsearch会触发segment合并的线程，把很多小的segment合并成更大的segment，然后删除小的segment。 
segment是不可变的，当我们更新一个文档时，会把老的数据打上已删除的标记，然后写一条新的文档。
在执行flush操作的时候，才会把已删除的记录物理删除掉。
```

