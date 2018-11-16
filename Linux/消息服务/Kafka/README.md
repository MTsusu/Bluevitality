```txt
kafka是分布式、支持分区、多副本的，是基于Zookeeper进行协调的分布式消息系统
其消息能被持久化到磁盘并支持数据的备份防止丢失，能支持上千客户端同时读写
Kafka只是分为一个或多个分区的主题的集合，Kafka分区是消息的线性有序序列，其中每个消息由它们的索引 (称为偏移) 来标识
集群中的所有数据都是不相连的分区联合。传入消息写在分区末尾（消息由消费者顺序读取）通过将消息复制到不同的代理提供持久性

Zookeeper在kafka中的作用：
    无论kafka集群还是producer和consumer，都依赖于zk来保证系统可用性集群保存一些meta信息
    Kafka使用zookeeper作为其分布式协调框架，很好的将消息的生产、存储、消费的过程结合在一起
    借助zk能将生产、消费者和broker在内的组件在无状态情况下建立起生产/消费者的订阅关系，并实现生产与消费的负载均衡
    Kafka采用zookeeper作为管理，记录了producer到broker的信息以及consumer与broker中partition的对应关系
    Broker通过ZK进行leader-->followers的选举，消费者通过ZK保存读取的位置Offset以及读取的topic的partition信息

    1. 启动zookeeper的server
    2. 启动kafka的server
    3. Producer若生产了数据，会先通过ZK找到broker，然后将数据存放到broker
    4. Consumer若要消费数据，会先通过ZK找对应的broker，然后消费。
    
replication（副本）、partition（分区）: 
    1个Topic能有若干副本，若服务器配置足够好，可配多个
    副本数决定了有多少个Broker来存放写入的数据! 简单说副本是以Partition为单位进行复制的
    存放副本也可以这样简单的理解，其用于备份若干Partition、但仅有1个Partition被选为Leader用于读写
    kafka中的producer能直接发送消息到对应partition的Leader处，而Producer能来实现将消息推送到哪些Partition
    kafka中相同group的consumer不可同时消费同一partition，在同一topic中同一partition同时只能由一个Consumer消费
    对相同group的consumer来说kafka可被其认为是一个队列消息服务，各consumer均衡的消费相应partition中的数据

由于Broker采用了主题topic --> 分区的思想，使得某个分区内部的顺序可保证有序性，但分区间的数据不保证有序性!!!...
消费者能够以分区为单位自定义读取的位置 --> offset

分区被分布到集群中的多个服务器上，每个服务器处理它分到的分区，根据配置每个分区还可复制到其它服务器作为备份容错。 
每个分区有一个leader零或多个follower。Leader处理此分区的所有的读写请求而follower被动的复制数据
注：想要顺序的处理Topic的所有消息那就只提供一个分区...
```
#### 部署 Kafka
```bash
# Kafka 依赖 Java version >= 1.7

#部署JAVA
[root@localhost ~]# tar -zxf jdk.tar.gz -C /home/ && mv /home/jdk1.8.0_101 /home/java
[root@localhost ~]# cd /home/java && export JAVA_HOME=$(pwd) && export PATH=$JAVA_HOME/bin:$PATH
[root@localhost ~]# echo "$PATH" >> ~/.bash_profile 

#部署Kafka
[root@localhost ~]# tar -zxf kafka_2.11-1.0.1.tgz -C /home/
[root@localhost ~]# ln -sv /home/kafka_2.11-1.0.1 /home/kafka

#部署Kafka自带的Zookeeper
[root@localhost ~]# cd /home/kafka/config/
[root@localhost config]# ll
-rw-r--r--. 1 root root  906 2月  22 06:26 connect-console-sink.properties
-rw-r--r--. 1 root root  909 2月  22 06:26 connect-console-source.properties
-rw-r--r--. 1 root root 5807 2月  22 06:26 connect-distributed.properties
-rw-r--r--. 1 root root  883 2月  22 06:26 connect-file-sink.properties
-rw-r--r--. 1 root root  881 2月  22 06:26 connect-file-source.properties
-rw-r--r--. 1 root root 1111 2月  22 06:26 connect-log4j.properties
-rw-r--r--. 1 root root 2730 2月  22 06:26 connect-standalone.properties
-rw-r--r--. 1 root root 1221 2月  22 06:26 consumer.properties           #消费者配置
-rw-r--r--. 1 root root 4727 2月  22 06:26 log4j.properties
-rw-r--r--. 1 root root 1919 2月  22 06:26 producer.properties           #生产者配置
-rw-r--r--. 1 root root 6852 2月  22 06:26 server.properties             #Kafka配置文件
-rw-r--r--. 1 root root 1032 2月  22 06:26 tools-log4j.properties
-rw-r--r--. 1 root root 1023 2月  22 06:26 zookeeper.properties          #Zookeeper配置文件

#这里使用的是Kafka自带的ZK，简单的Demo，实际生产中应使用ZK集群的方式
[root@localhost config]# vim /home/kafka/config/zookeeper.properties     
dataDir=/tmp/zookeeper                      #ZK的快照存储路径
clientPort=2181                             #客户端访问端口
maxClientCnxns=0                            #最大客户端连接数

[root@localhost config]# vim /home/kafka/config/server.properties        #Kafka配置，需要在每个节点设置
broker.id=0                                 #注意，在集群中不同节点不能重复
port=9092                                   #客户端使用端口，producer或consumer在此端口连接
host.name=192.168.133.128                   #节点主机名称，直接使用本机ip
num.network.threads=3                       #处理网络请求的线程数，线程先将收到的消息放到内存，再从内存写入磁盘
num.io.threads=8                            #消息从内存写入磁盘时使用的线程数，处理磁盘IO的线程数
socket.send.buffer.bytes=102400             #发送套接字的缓冲区大小
socket.receive.buffer.bytes=102400          #接受套接字的缓冲区大小
socket.request.max.bytes=104857600          #请求套接字的缓冲区大小
log.dirs=/tmp/kafka-logs                    #kafka运行日志路径（注意需要先创建：mkdir -p  /tmp/kafka-logs）
#num.partitions=1                           #每个主题的日志分区的默认数量（重要）
log.segment.bytes=1073741824                #日志文件中每个segment的大小，默认1G
log.retention.hours=168                     #segment文件保留的最长时间，默认7天，超时将被删除，单位hour
num.recovery.threads.per.data.dir=1         #segment文件默认被保留7天，这里设置恢复和清理data下数据时使用的的线程数
log.retention.check.interval.ms=300000      #定期检查segment文件有没有到达上面指定的限制容量的周期，单位毫秒
log.cleaner.enable=true                     #日志清理是否打开
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
zookeeper.connect=192.168.133.130:2181      #ZK的IP:PORT，格式：IP:PORT,IP:PORT,IP:PORT,...
zookeeper.connection.timeout.ms=6000        #ZK的连接超时
delete.topic.enable=true                    #物理删除topic需设为true，否则只是标记删除
group.initial.rebalance.delay.ms=0 

#启停Kafka集群
[root@localhost config]# cd /home/kafka/
#启动ZK：
bin/zookeeper-server-start.sh config/zookeeper.properties & 
#启动Kafka：
bin/kafka-server-start.sh -daemon config/server.properties
#停止Kafka：
bin/kafka-server-stop.sh
```
#### 运维相关命令
```bash
#启动服务
./kafka-server-start.sh -daemon ../config/server.properties 

#创建主题（保存时长：delete.retentin.ms）
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --create --replication-factor 1 --partitions 1 --topic ES \
--config delete.retention.ms=86400000    #1天

#删除主题
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --delete --topic ES

#查看所有主题
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --list

#查看主题的详细信息
./kafka-topics.sh --zookeeper 192.168.133.130:2181 -describe -topic ES

#生产者客户端命令（生产者产生信息时已经从ZK获取到了Broker的路由，因此这里要填入Broker的地址列表）
bin/kafka-console-producer.sh --broker-list 192.168.133.130:9092 --topic ES

#消费者客户端命令（从头消费：--from-beginning）
./kafka-console-consumer.sh -zookeeper  192.168.133.130:2181 --from-beginning --topic ES

#为Topic增加Partition
./kafka-topics.sh –-zookeeper 127.0.0.1:2181 -–alter -–partitions 20 -–topic ES 

#修改消息过期时间 (保存期限)
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --create \
--replication-factor 1 --partitions 1 --config delete.retention.ms=86400000 \
./kafka-topics.sh –-zookeeper 127.0.0.1:2181 –alter –-topic ES --config delete.retention.ms=1

#为topic增加replication
./kafka-reassign-partitions.sh --zookeeper 127.0.0.1:2181 \
-reassignment-json-file json/partitions-to-move.json -execute

#查看有那些 group ID 正在进行消费：
kafka-consumer-groups.sh --zookeeper localhost:2181 --list

#通过group_id查看当前详细的消费情况
./kafka-consumer-groups.sh --group logstash --describe --zookeeper 127.0.0.1:2181
输出：
GROUP-消费者组 TOPIC-话题id PARTITION-分区id CURRENT-OFFSET-当前已消费条数 LOG-END-OFFSET-总条数 LAG-未消费条数

查看指定group.id 的消费者消费情况 
# kafka-consumer-groups.sh --zookeeper localhost:2181 --group console-consumer-28542 --describe
GROUP                          TOPIC          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG      OWNER
console-consumer-28542         test_find1     0          303094          303094          0               
console-consumer-28542         test_find1     2          303713          303713          0  

#重平衡
./kafka-preferred-replica-election.sh --zookeeper 192.168.52.130:2181

#查看所有kafka节点
在zookeeper的bin目录执行 ./zkCli.sh 然后执行 ls /brokers/ids 就可以看到zk中存的所有的 broker id list
```
