```txt
是分布式、支持分区/副本的，基于Zookeeper进行协调的分布式消息系统，其消息能被持久化到磁盘并支持数据备份防丢失，支持上千C端
Kafka只是分为1或N个分区的主题的集合，分区是消息的线性有序序列，其中每个消息由它们的索引 (称为偏移) 来标识
集群中的所有数据都是不相连的分区联合。传入消息写在分区末尾（消息由消费者顺序读取）通过将消息复制到不同的代理提供持久性

Zookeeper在kafka中的作用：
    无论kafka集群还是producer和consumer，都依赖于zk来保证系统可用性，其保存 meta data
    Kafka使用ZK作为其分布式协调框架，很好的将消息的生产、存储、消费的过程结合在一起
    借助zk能将生产、消费者和broker在内的组件在无状态情况下建立起生产/消费者的订阅关系/并实现生产与消费的负载均衡
    Kafka采用zookeeper作为管理，记录了producer到broker的信息以及consumer与broker中partition的对应关系
    Broker通过ZK进行 leader -> followers 选举，消费者通过ZK保存读取的位置"Offset"及读取的topic的partition信息!...

    1. 启动zookeeper的server --->  启动kafka的server
    2. Producer若生产了数据，会先通过ZK找到broker，然后将数据存放到broker
    3. Consumer若要消费数据，会先通过ZK找对应的broker，然后消费 (消费的同时保存本次消费分区的segement中的位置)
    
replication（副本）、partition（分区）: 
    1个Topic能有若干副本，若服务器配置足够好，可配多个
    副本数决定了有多少个Broker来存放写入的数据! 简单说副本是以Partition为单位进行复制的
    存放副本也可以这样简单的理解，其用于备份若干Partition、但仅有1个Partition被选为Leader用于读写!...
    kafka中的producer能直接发送消息到对应partition的Leader处，而Producer能来实现将消息推送到哪些Partition
    kafka中相同group的consumer不可同时消费同一partition，在同一topic中同一partition同时只能由一个Consumer消费
    对相同group的consumer来说kafka可被其认为是一个队列消息服务，各consumer均衡的消费相应partition中的数据

Broker：   消息处理结点，一个Kafka节点就是一个Broker，多个Broker组成一个KAFKA集群
Topic：    消息的分类，比如page view、click日志等都能够以Topic的形式存在。Kafka集群能同一时刻负责多个Topic的分发
Partition：Topic物理上的分组。一个Topic可分为多个Partition，每个Partition就是一个有序的队列
Segment：  Partition物理上由多个Segment组成
offset：   每个Partition都由一系列有序的、不可变的消息组成，这些消息被连续的追加到Partition中
           partition中的每个消息都有一个连续的序列号：offset
           它用于partition中唯一标识这条消息（消费者能够以分区为单位自定义读取的位置）

由于Broker采用了 Topic -> Partition 的思想，使得某个分区内部的顺序可保证有序性，但分区间的数据不保证有序性!...
想要顺序的处理Topic的所有消息那就只提供一个分区...

分区被分布到集群中的多个服务器上，每个服务器处理它分到的分区，根据配置每个分区还可复制到其它服务器作为备份容错。 
每个分区有一个leader零或多个follower。Leader处理此分区的所有的读写请求而follower被动的复制数据
```
#### 部署
```bash
#部署JAVA （ Kafka 依赖 Java version >= 1.7 ）
#部署Kafka
[root@localhost ~]# tar -zxf kafka_2.11-1.0.1.tgz -C /home/ && ln -sv /home/kafka_2.11-1.0.1 /home/kafka

#部署Kafka自带的Zookeeper
[root@localhost ~]# cd /home/kafka/config/ && ll
-rw-r--r--. 1 root root  906 2月  22 06:26 connect-console-sink.properties
-rw-r--r--. 1 root root  909 2月  22 06:26 connect-console-source.properties
-rw-r--r--. 1 root root 5807 2月  22 06:26 connect-distributed.properties
-rw-r--r--. 1 root root  883 2月  22 06:26 connect-file-sink.properties
-rw-r--r--. 1 root root  881 2月  22 06:26 connect-file-source.properties
-rw-r--r--. 1 root root 1111 2月  22 06:26 connect-log4j.properties
-rw-r--r--. 1 root root 2730 2月  22 06:26 connect-standalone.properties
-rw-r--r--. 1 root root 1221 2月  22 06:26 consumer.properties           #消费者
-rw-r--r--. 1 root root 4727 2月  22 06:26 log4j.properties
-rw-r--r--. 1 root root 1919 2月  22 06:26 producer.properties           #生产者
-rw-r--r--. 1 root root 6852 2月  22 06:26 server.properties             #Kafka配置文件
-rw-r--r--. 1 root root 1032 2月  22 06:26 tools-log4j.properties
-rw-r--r--. 1 root root 1023 2月  22 06:26 zookeeper.properties          #Zookeeper

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
log.dirs=/tmp/kafka-logs                    #数据存放路径（注意需要先创建：mkdir -p  /tmp/kafka-logs）
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
delete.topic.enable=true                    #物理删除topic需设为true，否则只是标记删除!
group.initial.rebalance.delay.ms=0 

#启停
[root@localhost config]# cd /home/kafka/
bin/zookeeper-server-start.sh config/zookeeper.properties &     #启动ZK
bin/kafka-server-start.sh -daemon config/server.properties      #启动Kafka
bin/kafka-server-stop.sh                                        #停止Kafka
```
#### 运维
```bash
#创建主题（保存时长：delete.retentin.ms）
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --create --partitions 1 --replication-factor 1 --topic TEST \
--config delete.retention.ms=86400000    #定义保存时间（1天）
--config retention.bytes=1073741824      #定义保存容量（针对的是每个分区，因此实际占用容量 = 此值 * 分区数）
#线上环境将自动创建topic禁用，改为手动创建"auto.create.topics.enable=false"
#parttitions和replication－factor是两个必备选项（需要严格读取Topic消息顺序的时候，只使用1个partition）
#分区 是消费并行度的一个重要参数（多Partition时只有Partition的learder才能进对于该partiotion读写，其余都是副本）
#副本 极大提高了Topic的可用性.备份因子默认是1，相当于没有备份，注意其值不能大于broker个数，否则会报错。
#同时还可以指定Topic级别的配置，这种特定的配置会覆盖默认配置，并存储在zookeeper的/config/topics/[topic_name]节点

#主题清单
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --list

#主题详情
./kafka-topics.sh --zookeeper 192.168.133.130:2181 -describe -topic ES

#删除主题，在配置中需要开启删除主题的功能：delete.topic.enable=true
./kafka-topics.sh --zookeeper 192.168.133.130:2181 --delete --topic ES

#生产者客户端命令（生产者产生信息时已经从ZK获取到了Broker的路由，因此这里要填入Broker的地址列表）
bin/kafka-console-producer.sh --broker-list 192.168.133.130:9092 --topic ES

#消费者客户端命令（从头消费：--from-beginning）
./kafka-console-consumer.sh -zookeeper  192.168.133.130:2181 --topic ES --from-beginning

#为Topic增加Partition
./kafka-topics.sh –-zookeeper 127.0.0.1:2181 -–alter -–partitions 20 -–topic ES
#只能增加不能减少，若原有分散策略是hash的方式，将会受影响。发送端（默认10min会刷新本地元信息）/消费端无需重启即生效

#修改消息过期时间 (保存期限)
./kafka-topics.sh –-zookeeper 127.0.0.1:2181 –alter –-topic ES --config delete.retention.ms=1

#修改主题内的分区数
./kafka-topics.sh -–zookeeper 127.0.0.1:2181 -alter –partitions 5 –topic TEST

#查看正在进行消费的 group ID ：（旧/新）
kafka-consumer-groups.sh --zookeeper localhost:2181 --list
kafka-consumer-groups.sh --new-consumer --bootstrap-server 127.0.0.1:9292 --list

#通过 group ID 查看当前详细的消费情况（旧/新）
./kafka-consumer-groups.sh --zookeeper localhost:2181 --group TEAM1 --describe
./kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9292 --new-consumer  --group TEAM1--describe
#消费者组                       话题id         分区id     当前已消费条数    总条数                   未消费条数
#GROUP                         TOPIC          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG      OWNER
#console-consumer-28542        test_find1     0          303094          303094          0               
#console-consumer-28542        test_find1     2          303713          303713          0  

#重平衡
./kafka-preferred-replica-election.sh --zookeeper 192.168.52.130:2181

#查看所有kafka节点，在ZK的bin目录:
./zkCli.sh ---> ls /brokers/ids 就可以看到zk中存储的所有 broker id，查看：get /brokers/ids/{x}
```
#### 查看特定TOPIC分区大小
```bash
#查看某特定TOPIC在各Broker上的分区容量信息
./kafka-log-dirs.sh --bootstrap-server <broker:port>  \
--describe --topic-list <topics> --broker-list <broker.id_list> \
| grep '^{' \
| jq '[ ..|.size? | numbers ] | add'

#--bootstrap-server:     必填项, <broker:port>.
#--broker-list:  可选, 可指定查看某个broker.id上topic-partitions的size, 默认所有Broker!
#--describe:     描述
#--topic-list:   要查询的特定 topic 分区在disk上的空间占用情况，默认所有Topic

{
    "version": 1,
    "brokers": [{
        "broker": 0,
        "logDirs": [{
            "logDir": "/data/kafka-logs",
            "error": null,
            "partitions": [{
                "partition": "afei-1",
                "size": 567,            #单位byte
                "offsetLag": 0,
                "isFuture": false
            }, {
                "partition": "afei-2",
                "size": 639,            #单位byte
                "offsetLag": 0,
                "isFuture": false
            }, {
                "partition": "afei-0",
                "size": 561,            #单位byte
                "offsetLag": 0,
                "isFuture": false
            }]
        }]
    }]
}
```
#### 性能测试
```bash
#消费
./kafka-consumer-perf-test.sh --zookeeper 172.22.241.162:9092/kafka \
--messages 50000000 --topic TEST --threads 1
#输出格式
start.time,end.time, compression, message.size, batch.size, total.data.sent.in.MB, MB.sec,total.data.sent.in.nMsg, nMsg.sec

#生产
./kafka-producer-perf-test.sh --broker-list 172.22.241.162:9092 --threads 3 \
--messages 10000 --batch-size 1 --message-size 1024 --topics topic_test --sync
#--messages       生产者发送的消息总量
#--message-size   每条消息大小
#--batch-size     每次批量发送消息的数量
#--topics         生产者发送的topic
#--threads        生产者使用几个线程同时发送
#--producer-num-retries 每条消息失败发送重试次数
#--request-timeout-ms   每条消息请求发送超时时间
#--compression-codec    ?设置生产端压缩数据的codec，可选参数："none"，"gzip"， "snappy"

#--producer-props PROP-NAME = PROP-VALUE [PROP-NAME = PROP-VALUE ...]
#                 生成器相关的配置属性，如bootstrap.servers，client.id等。这些优先于通过--producer.config传递的配置
#--producer.config CONFIG-FILE
#                 生成器配置属性文件

#输出格式：
start.time,end.time, compression, message.size, batch.size, total.data.sent.in.MB, MB.sec,total.data.sent.in.nMsg, nMsg.sec
2015-05-2611:44:12:728, 2015-05-26 11:52:33:540, 0, 100, 200, 4768.37, 9.5213, 50000000,99837.8633
#replicationfactor不会影响consumer的吞吐性能，因为consumer只从每个partition的leader读数据
#一般情况下：分区越多，单线程生产者吞吐率越小，副本越多，吞吐率越低，异步生产数据比同步产生的吞吐率高近3倍
#短消息对Kafka来说是更难处理的使用方式，可以预期，随着消息长度的增大，records/second会减小
#当消息长度为10Byte时，因为要频繁入队花了太多时间获取锁，CPU成了瓶颈，并不能充分利用带宽...
```
#### 数据存储机制
```bash
log.dirs：/data/kafka           #配置文件中定义的数据存储路径
                 \
                  \             #TOPIC:TEST
                   TEST-0       #partiton:1
                        \
                         \...
                   TEST-1       #partiton:2
                        \
                         \...
                         xxxx.index     #索引
                         xxxx.log       #数据
```
