```txt
部署HA之前应先将ZK集群部署完毕，需要ZK最少3台、journalnode最少3台，目前最多支持2台NN的HA，不过节点可以复用，但不建议

Active NameNode、Standby NameNode：
    两台NameNode形成互备，一台处于Active状态，为主NameNode
    另外一台处于Standby状态，为备NameNode，只有主NameNode才能对外提供读写服务
    Active NameNode和StandbyNameNode使用JouranlNode集群来进行数据同步
    Active NameNode首先把EditLog提交到JournalNode集群，然后Standby NameNode再从JournalNode集群定时同步EditLog
    当N进入Standby状态时会启动EditLogTailer线程，其调用EditLogTailer类的doTailEdits方法从JournalNode集群同步EditLog

主备切换控制器 ZKFailoverController：
    ZKFailoverController作为独立进程运行，对NameNode的主备切换进行总体控制
    ZKFailoverController能及时检测到NameNode健康状况
    在主NameNode故障时借助Zookeeper实现自动的主备选举和切换，当然NameNode也支持不依赖Zookeeper的手动主备切换

Zookeeper集群：
    为主备切换控制器提供主备选举支持
    Zookeeper过于敏感：Hadoop的配置项中Zookeeper的session timeout参数"ha.zookeeper.session-timeout.ms"默认值为5000
    也就是5s，这个值比较小，会导致Zookeeper比较敏感，建议将其调大，避免因网络抖动等原因引起 NameNode 进行无谓的主备切换
    
共享存储系统：
    共享存储系统是实现NN高可用最为关键的部分，共享存储系统保存了NameNode运行过程中所产生的HDFS元数据。
    Active NameNode和Standby NameNode通过共享存储系统实现元数据同步。
    在进行主备切换时新的主NameNode在确认元数据完全同步之后才能继续对外提供服务。
    DataNode同时向主NameNode和备NameNode上报数据块的位置信息
```

#### vim etc/hadoop/hdfs-site.xml
```xml
<!-- 名称服务的逻辑名称 -->
<property>
    <name>dfs.nameservices</name>
    <value>sxt</value>
</property>

<!-- 名称服务中每个NameNode的唯一标识，这将由DataNode用于确定群集中的所有NameNode，目前每个名称服务最多只能配2个NN -->
<property>
    <name>dfs.ha.namenodes.sxt</name>
    <value>nn1,nn2</value>
</property>

<!-- 每个NameNode监听的完全限定的RPC地址，对于之前配置的NameNode ID，需要设置NameNode进程的完整地址和IPC端口 -->
<!-- 此处的RPC地址实际就是"dfs.defaultFS"地址 -->
<property>
    <name>dfs.namenode.rpc-address.sxt.nn1</name>
    <value>node1:8020</value>
</property>
<property>
    <name>dfs.namenode.rpc-address.sxt.nn2</name>
    <value>node2:8020</value>
</property>

<!-- 每个NameNode监听的完全限定的HTTP地址 -->
<property>
    <name>dfs.namenode.http-address.sxt.nn1</name>
    <value>node1:50070</value>
</property>

<property>
    <name>dfs.namenode.http-address.sxt.nn2</name>
    <value>node2:50070</value>
</property>

<!--
这是NameNode读写JNs组的uri。通过此uri，NameNodes可以读写edit log内容
URI的格式"qjournal://host1:port1;host2:port2;host3:port3/journalId"。
这里的host1、host2、host3指的是Journal Node的地址，这里必须是奇数个，至少3个...
通过活动NameNode写入和备用NameNode读取此存储区，使2个NN数据尽可能一致（JournalNodes提供的共享编辑存储）
日志ID是此名称服务唯一标识符，它允许1组JournalNodes为多个联邦名称系统提供存储，虽非要求但重用日志标识符的名称服务ID是好主意
-->
<property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://node1:8485;node2:8485;node3:8485/sxt</value>
</property>

<!-- HDFS客户端用于联系Active NameNode的Java类 （配置自动故障切换实现方式）
配置将由DFS客户端使用的Java类的名称，以确定哪个NameNode是当前的Active，以及哪个NameNode当前正在为客户端请求提供服务
目前Hadoop附带的唯一的实现是ConfiguredFailoverProxyProvider，所以使用这个，除非你使用的是自定义的 -->
<property>
    <name>dfs.client.failover.proxy.provider.sxt</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>

<!-- 设置切换时执行的程序，此处SSH到活动NameNode并杀死进程，故障转移期间将用于遏制活动NameNode的脚本或Java类的列表
当NN发生切换时原来active的NN可能仍在写edit log，此时若standby开始写edit log则元数据会"脑裂"。
因此要在切换前杀掉原来active的NN，此处的sshfence即通过SSH登录到原来active的NN并使用fuser命令KILL掉旧的NN进程-->
<property>
    <name>dfs.ha.fencing.methods</name>
    <value>sshfence</value>
</property>

<property>
    <name>dfs.ha.fencing.ssh.connect-timeout</name>
    <value>30000</value>
</property>

<!-- SSH必须能在不提供密码的情况下通过SSH连接到目标。因此还必须配置dfs.ha.fencing.ssh.private-key-files选项 -->
<property>
    <name>dfs.ha.fencing.ssh.private-key-files</name>
    <value>/home/hadoop/.ssh/id_rsa</value>
</property>

<!-- 启用HDFS的HA环境下的自动故障转移 -->
<property>
    <name>dfs.ha.automatic-failover.enabled</name>
    <value>true</value>
</property>
```
#### vim etc/hadoop/core-site.xml
```xml
<!-- 可将Hadoop客户端的默认路径配置为使用新的启用HA的逻辑URI
一旦使用HDFS HA，那么fs.defaultFS就不能写成host:port，而要写成服务方式，即写上"nameservice id"
如果之前使用"mycluster"作为名称服务标识，则这将是所有HDFS路径的权限部分的值。这可能是这样配置的 -->
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://sxt</value>
</property>

<!-- JournalNode守护进程将存储其本地状态的路径，即其自己的数据目录 -->
<property>
    <name>dfs.journalnode.edits.dir</name>
    <value>/opt/data/journal</value>
</property>

<!-- 添加zookeer的server列表 -->
<property>
    <name>ha.zookeeper.quorum</name>
    <value>node1:2181,node2:2181,node3:2181</value>
</property>
```
#### 启动顺序 ref: https://blog.csdn.net/zilong_zilong/article/details/51703399
```bash
在所有节点执行：
    chown hadoop.hadoop -R /opt/data/journal
    chmod u+rwx -R /opt/data/journal

#启动所有journalnode节点：
#基于QJM的共享存储系统主要用于保存EditLog（并不保存FSImage文件。FSImage文件还是在NameNode的本地磁盘上）
#基于QJM共享存储的基本思想来自Paxos算法，采用多个称为JournalNode的节点组成的JournalNode集群来存储EditLog
#每个JournalNode保存同样的EditLog副本。每次NN写EditLog的同时也会向JournalNode集群中的每个JournalNode发送EditLog的写请求
#在设置了所有必要的配置选项之后，必须先在集群中启动JournalNode守护进程，通过如下命令启动并等待守护进程在每台相关机器上启动

    在所有点启动： hadoop-daemon.sh start journalnode      #必须是在所有节点执行...
    在所有点验证： jps | grep JournalNode

#如果正在设置新的HDFS集群，则应首先在NameNode之一上运行format命令
#如果您已经格式化NameNode，或正在将未启用HA的群集转换为启用HA，则现在应该通过运行命令" hdfs namenode - "
#将您的NameNode元数据目录的内容复制到另一个未格式化的NameNode，bootstrapStandby放在未格式化的NameNode上。
#运行此命令还将确保JournalNodes（由dfs.namenode.shared.edits.dir配置）包含足够的编辑事务，以便能够启动两个NameNode。

    在其中一个namenode节点执行格式化:   hdfs namenode -format

# 附：手动切换HA下的NN节点
#     #将给定NameNode的状态转换为Active或Standby（不使用fencing措施，因此一般不用这2个命令，用hdfs haadmin -failover）
#     hdfs haadmin -transitionToActive <serviceId>
#     hdfs haadmin -transitionToStandby <serviceId>
#     #在两个NameNode之间启动故障转移
#     hdfs haadmin -failover [--forcefence] [--forceactive] <serviceId> <serviceId>
#     #确定给定的NameNode是Active还是Standby
#     hdfs haadmin -getServiceState <serviceId>

#在ZooKeeper中初始化所需的状态，可以通过从其中一个NameNode主机运行以下命令来完成此操作。
#这将在自动故障转移系统存储其数据的ZooKeeper中创建一个znode
    
    hdfs zkfc -formatZK

#启动namenode、同步备用namenode、启动备用namenode
    在NN节点执行：    hadoop-daemon.sh start namenode
    在备用NN节点执行：  hdfs namenode -bootstrapStandby     #从ActiveNameNode拷贝FSImage到本地（避免元数据的不一致）
    在备用NN节点执行：  hadoop-daemon.sh start namenode     #当StandbyNameNode同步FSImage后才能启动此节点的NN

#启动DFSZKFailoverController
#ZKFailoverController作为NameNode机器上的一个独立进程启动 (在hdfs启动脚本之中的进程名为"zkfc")
#当ZKFC启动时将自动选择1个NameNode变为活动状态，它们将创建相应的Znode并写入数据....

    在主备2个NN节点执行：    hadoop-daemon.sh start zkfc

#只需要在NN节点执行如下1条命令即启动所有DN：

    hadoop-daemons.sh start datanode

# 若启动过程中某个节点jps观察，出现问题需要重启时，应先执行如下命令删除已经存在的数据：
    rm -rf /data/hadoop/hdfs/snn/*
    rm -rf /data/hadoop/hdfs/dn/*
    rm -rf /data/hadoop/hdfs/nn/*
```
#### FAQ
```txt
1.ZKFC和NAMENODE有没有特定的启动顺序 
2.需要对ZKFC进程做监控，某些时候自动切换失效是因为ZKFC挂了 
3.如果zookeeper挂了则自动failover失效，但不会到HDFS服务有影响。当zookeeper启动后自动failover功能恢复正常 
4.当前并不能人为的设置某个namenode为primary或者preferred 
5.在自动HA的情况下，可以人为的切换namenode，执行hdfs hadmin命令。
```
