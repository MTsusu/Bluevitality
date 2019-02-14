#### 备忘
```
在ZooKeeper集群中有三种角色：
    集群中同一时刻只有一个Leader，其他都是Follower或Observer
        1.Leader
        2.Follower
        3.Observer
    
ZK配置简单，各节点配置文件"zoo.cfg"都是相同的，仅date/myid文件内的ID不同

Zookeeper类似于集群工作中的协调者，又可作为一种集群中存放"全局"变量的角色（不适应存放大容量）
它是分布式，开源的分布式应用程序协调服务，它是集群的管理者，监视着集群中各节点状态根据节点提交的反馈进行下一步合理操作。
所有分布式协商和一致都可利用ZK实现。可理解为一个分布式的带有订阅功能的小型元数据库。
```
#### 部署
```bash
#解压（注意，略过了JAVA的部署，ZK需要JAVA环境）
[root@localhost ~]# tar -zxf zookeeper-3.4.10.tar.gz -C /usr/local/
[root@localhost ~]# cd /usr/local/zookeeper-3.4.10/
[root@localhost zookeeper-3.4.10]# ls
bin         docs             NOTICE.txt            zookeeper-3.4.10.jar
build.xml   ivysettings.xml  README_packaging.txt  zookeeper-3.4.10.jar.asc
conf        ivy.xml          README.txt            zookeeper-3.4.10.jar.md5
contrib     lib              recipes               zookeeper-3.4.10.jar.sha1
dist-maven  LICENSE.txt      src

#创建Zookeeper下的Data及日志目录，ID
[root@localhost zookeeper-3.4.10]# mkdir -p {data,logs} && touch data/myid
[root@localhost zookeeper-3.4.10]# echo '<本节点ID>' > data/myid

#设置环境变量（此处略过JAVA的安装及JAVA_HOME的配置）
[root@localhost zookeeper-3.4.10]# cat > /etc/profile.d/zookeeper.sh <<'eof' 或： cat >> ~/.bash_profile <<'eof'
export ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10/
export PATH=$ZOOKEEPER_HOME/bin:$PATH
eof
[root@localhost zookeeper-3.4.10]# source ~/.bash_profile

#配置ZK，为避免编码问题不要使用中文注释，ZooKeeper集群中每个节点的配置文件都一样，可直接同步配置文件而不做任何修改!
[root@localhost zookeeper-3.4.10]# cd conf
[root@localhost conf]# vim zoo.cfg
#集群间心跳的基本时间单位，C/S间交互的基本时间单元"ms"
tickTime=2000
#集群中的Follower与leader之间初始连接时能容忍的最多心跳数，相当于最大等待时间
initLimit=10
#Leader与Follower之间发送消息，请求和应答的时间长度
syncLimit=5
#保存ZK数据的路径，即内存数据库快照存放地址，此路径要事先创建
dataDir=/usr/local/zookeeper-3.4.10/data
#保存ZK日志的路径，当此配置不存在时默认路径与dataDir一致，此路径要事先创建
dataLogDir=/usr/local/zookeeper-3.4.10/logs
#客户端访问ZK时使用的端口
clientPort=21811
#默认1000，当Server没有空闲来处理更多的客户端请求时，还是允许C端将请求提交到S以提高吞吐性能
#为防止Server内存溢出，这个请求堆积数还是要限制一下  
globalOutstandingLimit=1000

#集群成员相关配置，单节点不需此配置
server.1=192.168.220.128:2888:3888  #需在该节点的Zookeeper/data下 echo '1' > myid 来标明其ID号 
server.2=192.168.220.128:4888:5888  #同上...
server.3=192.168.220.128:6888:7888  #同上...
# 格式说明： server.N=B:C:D
# N 是数字标识，指明其是第几号服务器，此数字标识与myid中的值相同
# B 是集群中的ZK服务器IP地址
# C 指明此节点与集群中的Leader服务器交换信息的端口
# D 标识的是万一集群中的Leader服务器挂了，需要一个端口来重新选出一个新的Leader，此即用来执行选举时服务器间的通信端口

#启动Zookeeper（在分布式环境下ZK的启动命令要尽量在各节点同时执行）
[root@localhost conf]# cd ../bin/
[root@localhost bin]# ./zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper-3.4.10/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

#查看Zookeeper状态
[root@localhost bin]# ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: standalone

#使用客户端工具"zkClient.sh"连接ZK服务端
[root@localhost bin]# ./zkCli.sh –server 127.0.0.1:13331
Connecting to localhost:2181
2017-06-28 20:20:29,331 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT
2017-06-28 20:20:29,334 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=localhost
2017-06-28 20:20:29,334 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.7.0_45
2017-06-28 20:20:29,335 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2017-06-28 20:20:29,335 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.45.x86_64/jre
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/usr/local/zookeeper-3.4.10/bin/../build/classes:/usr/local/zookeeper-3.4.10/bin/../build/lib/*.jar:/usr/local/zookeeper-3.4.10/bin/../lib/slf4j-log4j12-1.6.1.jar:/usr/local/zookeeper-3.4.10/bin/../lib/slf4j-api-1.6.1.jar:/usr/local/zookeeper-3.4.10/bin/../lib/netty-3.10.5.Final.jar:/usr/local/zookeeper-3.4.10/bin/../lib/log4j-1.2.16.jar:/usr/local/zookeeper-3.4.10/bin/../lib/jline-0.9.94.jar:/usr/local/zookeeper-3.4.10/bin/../zookeeper-3.4.10.jar:/usr/local/zookeeper-3.4.10/bin/../src/java/lib/*.jar:/usr/local/zookeeper-3.4.10/bin/../conf:
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=2.6.32-431.el6.x86_64
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2017-06-28 20:20:29,337 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/usr/local/zookeeper-3.4.10/bin
2017-06-28 20:20:29,338 [myid:] - INFO  [main:ZooKeeper@438] - Initiating client connection, connectString=localhost:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@5e411af2
ZooKeeper -server host:port cmd args
        connect host:port
        get path [watch]
        ls path [watch]
        set path data [version]
        rmr path
        delquota [-n|-b] path
        quit 
        printwatches on|off
        create [-s] [-e] path data acl
        stat path [watch]
        close 
        ls2 path [watch]
        history 
        listquota path
        setAcl path acl
        getAcl path
        sync path
        redo cmdno
        addauth scheme auth
        delete path [version]
        setquota -n|-b val path
```
```bash
[zk: localhost:2181(CONNECTED) 23] get /yarn-leader-election/appcluster-yarn/ActiveBreadCrumb
appcluster-yarnrm1
cZxid = 0x1b00133dc0 #Created ZXID,表示该ZNode被创建时的事务ID
ctime = Tue Jan 03 15:44:42 CST 2017 #Created Time,表示该ZNode被创建的时间
mZxid = 0x1d00000063 #Modified ZXID，表示该ZNode最后一次被更新时的事务ID
mtime = Fri Jan 06 08:44:25 CST 2017 #Modified Time，表示该节点最后一次被更新的时间
pZxid = 0x1b00133dc0 #表示该节点的子节点列表最后一次被修改时的事务ID。注意，只有子节点列表变更了才会变更pZxid，子节点内容变更不会影响pZxid。
cversion = 0 #子节点的版本号
dataVersion = 11 #数据节点的版本号
aclVersion = 0 #ACL版本号
ephemeralOwner = 0x0 #创建该节点的会话的seddionID。如果该节点是持久节点，那么这个属性值为0。
dataLength = 22 #数据内容的长度
numChildren = 0  #子节点的个数
#在ZooKeeper中，version属性是用来实现乐观锁机制中的『写入校验』的（保证分布式数据原子性操作）。
```
