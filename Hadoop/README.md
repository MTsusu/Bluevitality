```txt
Hadoop单独使用的JAVA_HOME、NameNode 和 DataNode 的内存配置信息在 etc/hadoop/hadoop-env.sh
因虚拟机资源限制，将SN,NN,YARN仍放在1个节点 (Node1) , 需注意集群各节点NTP同步及主机名调整
注意! 在 Hadoop 2.0 中不再需要 secondary namenode 或 backup namenode，它们的工作由 Standby namenode 承担
JobTracker在 Hadoop 2.0 中已被整合到 YARN 的 ResourceManger 中

journalNode的作用是存放EditLog的：
    在MR1中editlog是和fsimage存放在一起的然后SecondNamenode做定期合并
    后来的Yarn不用SecondNamanode...

Node1(192.168.0.3)作为Master：   NN，SNN，YARN(RsourceManager) 
Node2-4(192.168.0.4/7/8)作为：   DN(NodeManager)

    [Node1] ----- [Node2]
           \ ---- [Node3]
            \ --- [Node4]
```
#### 在部署Hadoop集群前先在所有节点执行如下
```bash
[root@localhost ~]# systemctl disable firewalld
[root@localhost ~]# systemctl stop firewalld
[root@localhost ~]# sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux &&　setenforce 0
[root@localhost ~]# date -s "yyyy-mm-dd HH:MM"      #生产环境要使用ntpdate，若不进行同步在执行YARN任务时会报错

#2.7+版本的Hadoop在生产环境中应使用"1.8+"的JDK环境，否则执行Spark任务时易出现报错
[root@localhost ~]# yum -y install java-1.7.0-openjdk.x86_64 java-1.7.0-openjdk-devel.x86_64
[root@localhost ~]# cat > /etc/profile.d/java.sh <<'eof'
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.x86_64/
export PATH=$JAVA_HOME/bin:$PATH
eof

#在所有节点解压软件包并设置环境变量
[root@localhost ~]# tar -zxf hadoop-2.7.6.tar.gz -C /  &&  chown -R root.root /hadoop-2.7.6
[root@localhost ~]# ln -sv /hadoop-2.7.6/ /hadoop
[root@localhost ~]# cat > /etc/profile.d/hadoop.sh <<'eof'
export HADOOP_PREFIX="/hadoop"                          
export PATH=$PATH:${HADOOP_PREFIX}/bin:${HADOOP_PREFIX}/sbin
export HADOOP_COMMON_HOME=${HADOOP_PREFIX}
export HADOOP_HDFS_HOME=${HADOOP_PREFIX}
export HADOOP_MAPRED_HOME=${HADOOP_PREFIX}
export HADOOP_YARN_HOME=${HADOOP_PREFIX}
eof
[root@localhost ~]# . /etc/profile

#节点间主机名映射信息
[root@localhost ~]# cat >> /etc/hosts <<eof
192.168.0.3   node1 master
192.168.0.4   node2
192.168.0.7   node3
192.168.0.8   node4
eof

#使用hadoop用户进行部署和使用，降低root权限被劫持的风险
[root@localhost ~]# groupadd hadoop && useradd hadoop -g hadoop && echo "123456" | passwd --stdin hadoop

#使所有Hadoop集群中的节点能够以"hadoop"用户的身份进行免密钥互通（Master启动时将通过SSH的方式启动各节点的daemon进程）
#注意设置namenode节点到datanode节点的免密码登陆（集群环境的使用必须通过ssh无密码登陆来执行）
[root@localhost ~]# su - hadoop                  
[hadoop@localhost ~]$ ssh-keygen -t rsa -P ''    
[hadoop@localhost ~]$ for ip in 3 4 7 8;do ssh-copy-id -i .ssh/id_rsa.pub hadoop@192.168.0.${ip};done 
[hadoop@localhost ~]$ for nd in {1..4};do ssh node${nd} "echo test" ;done
[hadoop@localhost ~]$ exit

#在各节点创建HDFS各角色使用的元数据及块数据等路径，修改属主属组，注意权限问题可能引起DN启动失败!
[root@localhost ~]# mkdir -p /data/hadoop/hdfs/{nn,snn,dn}
[root@localhost ~]# chown -R hadoop.hadoop /data/hadoop/hdfs    #要在所有节点执行，出过一次故障...

[root@localhost ~]# mkdir -p /hadoop/logs && chmod -R g+w /hadoop/logs      #日志路径
[root@localhost ~]# chown -R hadoop.hadoop /hadoop/
[root@localhost ~]# chown -R hadoop.hadoop /hadoop                          #软连接
[root@localhost ~]# ll /hadoop
lrwxrwxrwx. 1 hadoop hadoop 14 1月  12 07:00 /hadoop -> /hadoop-2.6.5/
```
#### 在Hadoop集群中的Master节点，即本环境中的NN、SNN、YARN节点（node1）配置如下
```xml
[root@node1 hadoop]# cd $HADOOP_PREFIX
[root@node1 hadoop]# vim etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- 指定NameNode地址，即集群中HDFS的RPC服务端口（NN在哪台机器及端口）可将其认为是HDFS的入口 -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://node1:8020/</value>
        <final>true</final>
    </property>
    <!-- 开启垃圾回收站功能，文件删除后先进入回收站，值为检查点被删除的分钟数，超过后删除，设为0为禁用 --> 
    <property>  
        <name>fs.trash.interval</name>  
        <value>1440</value>  
    </property>
    <property>
         <name>io.file.buffer.size</name>
         <value>131072</value>
    </property>
</configuration>
 
[root@node1 hadoop]# vim etc/hadoop/yarn-site.xml  #用于配置YARN进程及其相关属性，本文件中的node1指的是yarn节点地址
<?xml version="1.0"?>
<configuration>
    <!-- Hadoop集群中YARN的ResourceManager守护所在的主机和监听的端口，对伪分布式来讲为localhost -->
    <!-- ResourceManager 对客户端暴露的地址。客户端通过该地址向RM提交应用程序，杀死应用程序等 -->
    <property>    
        <name>yarn.resourcemanager.address</name> 
        <value>node1:8032</value>                           
    </property>
    <!-- Hadoop集群中YARN的ResourceManager使用的scheduler（作业任务的调度器）所在的地址 -->
    <!-- ResourceManager对ApplicationMaster暴露的访问地址。DN中的ApplicationMaster通过该地址向RM申请、释放资源等 -->
    <property>    
        <name>yarn.resourcemanager.scheduler.address</name> 
        <value>node1:8030</value>
    </property>
    <!-- 资源追踪器的地址 -->
    <!-- ResourceManager对NodeManager暴露的地址。NodeManager通过该地址向RM汇报心跳，领取任务等 -->
    <property>    
        <name>yarn.resourcemanager.resource-tracker.address</name> 
        <value>node1:8031</value>
    </property>
    <!-- YARN管理地址，它是ResourceManager对管理员暴露的访问地址。管理员通过该地址向RM发送管理命令等-->
    <property>    
        <name>yarn.resourcemanager.admin.address</name> 
        <value>node1:8033</value>
    </property>
    <!-- YARN的内置WEB管理地址提供服务的地址及端口 -->
    <property>    
        <name>yarn.resourcemanager.webapp.address</name> 
        <value>node1:8088</value>
    </property>
    <!-- nomenodeManager获取数据的方式是shuffle (辅助服务) -->
    <!-- NodeManager上运行的附属服务。需设为"mapreduce_shuffle"才可运行MapReduce程序 -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <!-- 使用的shuffleHandler类 -->
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <!-- 启用的资源调度器的主类，目前可用的有FIFO、Capacity Scheduler和Fair Scheduler -->
    <property>
        <name>yarn.resourcemanager.scheduler.class</name> 
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
    </property>
    <!-- resourcemanager 失联后重新链接的时间 -->    
    <property>    
        <name>yarn.resourcemanager.connect.retry-interval.ms</name>  
        <value>2000</value>    
    </property>
</configuration>

[root@node1 hadoop]# vim etc/hadoop/hdfs-site.xml
#主要用于配置HDFS相关属性，如复制因子（数据块的副本数）、NN和DN用于存储数据的路径等信息
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.datanode.max.transfer.threads</name>    
        <value>409600</value> 
        <description>Hadoop允许打开最大文件数，默认4096，不设置的话会提示xcievers exceeded错误</description>
    </property> 

    <property>
        <name>dfs.replication</name>
        <value>3</value>
        <description>HDFS保存数据的副本数量，即HDFS的DN下的数据冗余份数，对伪分布式来说应为1</description>
    </property>

    <property>  
        <name>dfs.datanode.du.reserved</name>  
        <value>107374182400</value>
        <description>指定磁盘预留多少空间，防止磁盘被撑满用完，单位为bytes，此处预留100G</description>
    </property> 

    <property>
        <name>dfs.namenode.name.dir</name> 
        <value>file:///data/hadoop/hdfs/nn</value>
        <description>指定hdfs中namenode的存储位置，数据的目录为前面的步骤中专门为其创建的路径</description>
    </property>
    
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>192.168.146.201:50090</value>
        <description>指定 secondary 的节点? （此配置是后补充加入的）</description>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///data/hadoop/hdfs/dn</value>
        <description>指定hdfs中datanode的存储位置，数据的目录为前面的步骤中专门为其创建的路径</description>
    </property>
    
    <property>
        <name>fs.checkpoint.dir</name>
        <value>file:///data/hadoop/hdfs/snn</value>
        <description>设置hdfs中checkpoint文件路径（SNN的追加日志文件路径）此路径为之前专门为其创建的路径</description>
    </property>

    <property>
        <name>fs.checkpoint.edits.dir</name>
        <value>file:///data/hadoop/hdfs/snn</value>
        <description>设置hdfs中checkpoint的编辑目录</description>
    </property>

    <property>
        <name>dfs.permissions</name>
        <value>false</value>
        <description>若需要其他用户对HDFS有写入权限，还需要再添加此定义，此处设为不对权限进行严格的限定</description>
    </property>
    
    <property>  
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
        <description>提供web访问hdfs的权限</description>
    </property>
    
    <property>  
        <name>dfs.client.socket-timeout</name>  
        <value>600000</value>  
    </property>
</configuration>

#mapred-site.xml默认不存在，但有模块文件mapred-site.xml.template，只需要将其复制为mapred-site.xml即可
[root@node1 hadoop]# cp etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
[root@node1 hadoop]# vim etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
          <!-- 用于配置集群的MapReduce framework，此处应该指定使用yarn，另外的可用值还有：local/classic -->
          <!-- 告诉hadoop的MR(Map/Reduce)运行在YARN之上(version 2.0+)，而不是让其直接运行在HDFS之上 -->
          <name>mapreduce.framework.name</name>
          <value>yarn</value>
    </property>

#   <!--配置历史服务器-->
#   <property>
#       <name>mapreduce.jobhistory.address</name>
#       <value>node1:10020</value>
#   </property>
#   <property>
#       <name>mapreduce.jobhistory.webapp.address</name>
#       <value>node1:19888</value>
#   </property>
</configuration>

# conf/slaves配置DN，conf/masters 配置SNN
[root@node1 hadoop]# cat > etc/hadoop/masters <<eof
#输入 SecondaryNameNode 节点的主机名或 IP ，在Namenode的HA环境中此配置应略过!?
node1
eof

[root@node1 hadoop]# cat > etc/hadoop/slaves <<eof
#输入Datanode节点主机名或IP（指明集群中有哪些主机）当执行"start-dfs.sh"时其根据此列表来确定集群中DN节点的信息...
node2
node3
node4
eof
```
#### 在集群的Master节点将配置文件使用hadoop用户推送到各节点
```bash
[root@node1 hadoop]# su - hadoop 
[hadoop@node1 ~]$ cd ${HADOOP_PREFIX}/etc/hadoop
[hadoop@node1 ~]$ for n in {1..4};do scp core-site.xml  hadoop@node${n}:/hadoop/etc/hadoop/core-site.xml ;done
[hadoop@node1 ~]$ for n in {1..4};do scp yarn-site.xml  hadoop@node${n}:/hadoop/etc/hadoop/yarn-site.xml ;done
[hadoop@node1 ~]$ for n in {1..4};do scp mapred-site.xml  hadoop@node${n}:/hadoop/etc/hadoop/mapred-site.xml ;done
[hadoop@node1 ~]$ for n in {1..4};do scp hdfs-site.xml  hadoop@node${n}:/hadoop/etc/hadoop/hdfs-site.xml ;done
[hadoop@node1 ~]$ for n in {1..4};do scp slaves  hadoop@node${n}:/hadoop/etc/hadoop/slaves ;done
[hadoop@node1 ~]$ for n in {1..4};do scp masters  hadoop@node${n}:/hadoop/etc/hadoop/masters ;done
#core-site.xml，mapred-site.xml，hdfs-site.xml，master，slave等配置文件在各节点中都是一样的
```
#### 启动 Hadoop Cluster
```bash
[root@node1 hadoop]# su - hadoop                        #先在Master节点对NN进行格式化，然后才能启动hdfs
[hadoop@node1 ~]$ hdfs namenode -format                 #第一次启动Hadoop集群时需要对NameNode进行格式化
# 注：有2种启动方式
#     1. 在各节点分别启动要启动的服务
#     2. 在Master节点使用Apache官方提供的脚本启动整个集群

[root@node1 ~]# su - hadoop

#启动HDFS，注：自动通过配置信息到所有NN/DN启动（关闭：stop-dfs.sh）
[hadoop@node1 ~]$ start-dfs.sh
Starting namenodes on [node1]
node1: starting namenode, logging to /hadoop/logs/hadoop-hadoop-namenode-node1.out
node4: starting datanode, logging to /hadoop/logs/hadoop-hadoop-datanode-node4.out
node2: starting datanode, logging to /hadoop/logs/hadoop-hadoop-datanode-node2.out
node3: starting datanode, logging to /hadoop/logs/hadoop-hadoop-datanode-node3.out
Starting secondary namenodes [0.0.0.0]                  #因为不存在snn，它直接找0.0.0.0去了 (实际上找的是本机)
hadoop@0.0.0.0\'s password: 
0.0.0.0: starting secondarynamenode, logging to /hadoop/logs/hadoop-hadoop-secondarynamenode-node1.out  

[root@node3 hadoop]# su - hadoop -c "jps"               #此时在集群的其他节点执行jps可以看到dn已经启动    
46321 Jps
46248 DataNode

#启动Yarn，注：在Master节点启动YARN，此操作也会将所有DN节点的"NodeManager"启动
[hadoop@node1 ~]$ start-yarn.sh
starting yarn daemons
starting resourcemanager, logging to /hadoop/logs/yarn-hadoop-resourcemanager-node1.out
node2: starting nodemanager, logging to /hadoop/logs/yarn-hadoop-nodemanager-node2.out
node3: starting nodemanager, logging to /hadoop/logs/yarn-hadoop-nodemanager-node3.out
node4: starting nodemanager, logging to /hadoop/logs/yarn-hadoop-nodemanager-node4.out

[root@node4 hadoop]# su - hadoop -c "jps"               #在其他节点验证nodemanager是否启动
46004 DataNode
46120 NodeManager
46265 Jps

#除上述start-dfs.sh、start-yarn.sh的顺序启动方式外，还有"start-all.sh"脚本用于一次性启动Hadoop集群...
```
#### 在Master节点通过YARN执行Apache提供的MapReduce的 "wordcount.jar"测试运行状态（单词统计）
```bash
#执行分词统计前先录入需要分析的数据到HDFS
[hadoop@node1 ~]$ hdfs dfs -mkdir /test
[hadoop@node1 ~]$ hdfs dfs -ls -R /
drwxr-xr-x   - hadoop supergroup          0 2017-01-13 21:36 /test
[hadoop@node1 ~]$ hdfs dfs -put /etc/fstab /test/fstab          #灌入数据到HDFS
```
###### 通过HDFS内建的WEB页面查看 
![img](资料/Hadoop分布式WEB.gif)
```bash
#在Master节点通过YARN执行Apache提供的MapReduce的 "wordcount"（单词统计）jar包测试运行状态
#以下命令将执行结果保存在HDFS的"/test/fstab.analyze.out"目录内，需使用 "hdfs dfs -cat" 命令进行查看
[hadoop@node1 mapreduce]$ yarn jar /hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.5.jar \
> wordcount /test/fstab /test/fstab.analyze.out         
18/01/13 21:52:36 INFO client.RMProxy: Connecting to ResourceManager at node1/192.168.0.3:8032
18/01/13 21:52:37 INFO input.FileInputFormat: Total input paths to process : 1
18/01/13 21:52:37 INFO mapreduce.JobSubmitter: number of splits:1
18/01/13 21:52:37 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1484314634480_0002
18/01/13 21:52:37 INFO impl.YarnClientImpl: Submitted application application_1484314634480_0002
18/01/13 21:52:37 INFO mapreduce.Job: The url to track the job: http://node1:8088/proxy/application_1484314634480_0002/
18/01/13 21:52:37 INFO mapreduce.Job: Running job: job_1484314634480_0002
18/01/13 21:52:46 INFO mapreduce.Job: Job job_1484314634480_0002 running in uber mode : false
18/01/13 21:52:46 INFO mapreduce.Job:  map 0% reduce 0%
18/01/13 21:52:52 INFO mapreduce.Job:  map 100% reduce 0%
18/01/13 21:53:02 INFO mapreduce.Job:  map 100% reduce 100%
18/01/13 21:53:02 INFO mapreduce.Job: Job job_1484314634480_0002 completed successfully
18/01/13 21:53:02 INFO mapreduce.Job: Counters: 49
        File System Counters
                FILE: Number of bytes read=555
                FILE: Number of bytes written=215267
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=558
                HDFS: Number of bytes written=397
                HDFS: Number of read operations=6
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
        Job Counters 
                Launched map tasks=1
                Launched reduce tasks=1
                Other local map tasks=1
                Total time spent by all maps in occupied slots (ms)=4836
                Total time spent by all reduces in occupied slots (ms)=5752
                Total time spent by all map tasks (ms)=4836
                Total time spent by all reduce tasks (ms)=5752
                Total vcore-milliseconds taken by all map tasks=4836
                Total vcore-milliseconds taken by all reduce tasks=5752
                Total megabyte-milliseconds taken by all map tasks=4952064
                Total megabyte-milliseconds taken by all reduce tasks=5890048
        Map-Reduce Framework
                Map input records=11
                Map output records=54
                Map output bytes=589
                Map output materialized bytes=555
                Input split bytes=93
                Combine input records=54
                Combine output records=38
                Reduce input groups=38
                Reduce shuffle bytes=555
                Reduce input records=38
                Reduce output records=38
                Spilled Records=76
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=496
                CPU time spent (ms)=2610
                Physical memory (bytes) snapshot=441872384
                Virtual memory (bytes) snapshot=2112487424
                Total committed heap usage (bytes)=277348352
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters 
                Bytes Read=465
        File Output Format Counters 
                Bytes Written=397
```
###### 通过YARN内建的WEB页面查看
![img](资料/MP-result.gif)
```bash
[hadoop@node1 mapreduce]$ hdfs dfs -ls -R /test
-rw-r--r--   2 hadoop supergroup        465 2017-01-13 21:37 /test/fstab
drwxr-xr-x   - hadoop supergroup          0 2018-01-13 21:53 /test/fstab.analyze.out
-rw-r--r--   2 hadoop supergroup          0 2018-01-13 21:53 /test/fstab.analyze.out/_SUCCESS
-rw-r--r--   2 hadoop supergroup        397 2018-01-13 21:53 /test/fstab.analyze.out/part-r-00000

#查看分词统计后的输出到HDFS的执行结果 ( Mapper + Reducer 处理后的) ：
[hadoop@node1 mapreduce]$ hdfs dfs -cat /test/fstab.analyze.out/part-r-00000
#       7
'/dev/disk'     1
/       1
/boot   1
/dev/mapper/centos-root 1
/dev/mapper/centos-swap 1
/etc/fstab      1
0       6
06:32:32        1
20      1
2017    1
Accessible      1
Created 1
Mon     1
Nov     1
See     1
UUID=2ad33313-a113-4cf8-863a-da3c9e79e4f0       1
anaconda        1
and/or  1
are     1
blkid(8)        1
by      2
defaults        3
filesystems,    1
findfs(8),      1
for     1
fstab(5),       1
info    1
maintained      1
man     1
more    1
mount(8)        1
on      1
pages   1
reference,      1
swap    2
under   1
xfs     2
```
#### 附 yarn 命令相关参数
```txt
[root@node4 hadoop]# yarn
Usage: yarn [--config confdir] COMMAND
where COMMAND is one of:
  resourcemanager -format-state-store   deletes the RMStateStore        #删除RM的状态存储
  resourcemanager                       run the ResourceManager
  nodemanager                           run a nodemanager on each slave
  timelineserver                        run the timeline server
  rmadmin                               admin tools
  version                               print the version
  jar <jar>                             run a jar file
  application                           prints application(s)
                                        report/kill application
  applicationattempt                    prints applicationattempt(s)
                                        report
  container                             prints container(s) report
  node                                  prints node report(s)
  queue                                 prints queue information
  logs                                  dump container logs
  classpath                             prints the class path needed to
                                        get the Hadoop jar and the
                                        required libraries
  daemonlog                             get/set the log level for each
                                        daemon
 or
  CLASSNAME                             run the class named CLASSNAME
Most commands print help when invoked w/o parameters.
```
#### hadoop-daemon.sh （Hadoop集群的其他启动命令）
```txt
单独启动某个服务:
    hadoop-deamon.sh start namenode
    
demo：
    ./hadoop-daemon.sh start datanode
    ./hadoop-daemon.sh start namenode
    ./hadoop-daemon.sh start secondarynamenode
    ./hadoop-daemon.sh start nodemanager
    ./hadoop-daemon.sh start jobtracker
    ./hadoop-daemon.sh start tasktracker
```
