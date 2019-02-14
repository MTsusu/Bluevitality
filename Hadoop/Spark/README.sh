#!/bin/bash
#本次安装的前提是Hadoop环境已经部署完成...
#Spark允许将中间输出和结果存储在内存中，节省了大量磁盘IO。同时自身的DAG执行引擎也支持数据在内存中的计算
#Spark支持SQL查询、流式计算、图计算、机器学习等。通过对Java、Python、Scala、R等语言的支持从而极大方便了用户的使用。
#自带了80多个高等级操作符，允许在Scala，Python，R的shell中进行交互式查询，支持SQL及Hive SQL对数据查询
#与MapReduce只能处理离线数据相比，Spark还支持实时的流计算。Spark依赖Spark Streaming对数据进行实时的处理，其流式处理能力还要强于Storm
#Spark官网声称性能比Hadoop快100倍

#准备安装包：
#    jdk1.8.tar.gz
#    scala-2.10.4.tgz
#    spark-2.3.0-bin-hadoop2.7.tgz

#安装scala（注：在Spark的所有节点都要安装Scala环境）
tar -zxf scala-2.10.4.tgz && ln -sv scala-2.10.4.tgz scala

cat > /etc/profile.d/scala.sh <<'eof'
export SCALA_HOME=/home/hadoop/scala
export PATH=$SCALA_HOME/bin:$PATH
eof

source /etc/profile.d/scala.sh

#验证： scala -version

#安装spark
tar -zxf spark-2.3.0-bin-hadoop2.7.tgz && ln -sv spark-2.3.0-bin-hadoop2.7 spark

cd ~/spark/conf && cp spark-env.sh.template spark-env.sh
cat > spark-env.sh <<'eof'
export JAVA_HOME=/home/hadoop/jdk1.8    #部署Spark应使用大于等于1.8以上的版本，否则会报错! ( 与1.7环境完全分离!执行应用时报错... )
export SCALA_HOME=/home/hadoop/scala
export HADOOP_HOME=/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_LOG_DIR=/home/hadoop/spark/logs
export SPARK_PID_DIR=/home/hadoop/spark
#通过加入Zookeeper写入Znode数据，实现Spark集群中Master节点的高可用...
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER
-Dspark.deploy.zookeeper.url=node1:2181,node2:2181,node3:2181 -Dspark.deploy.zookeeper.dir=/spark"
#export SPARK_MASTER_IP=node1           #集群的Master节点的ip地址（由于使用Zookeeper实现了HA，此配置可省略）
export SPARK_LOCAL_DIRS=/home/hadoop/spark
export SPARK_WORKER_CORES=16            #每个worker节点所占有的CPU核数目
export SPARK_DRIVER_MEMORY=64G          #每个Worker节点能够最大分配给exectors的内存大小
export SPARK_WORKER_INSTANCES=1         #每台机器上开启的worker节点的数目
eof

cat > slaves <<'eof'
#在Slaves文件下填上Spark的各节点主机名
node2
node3
eof

#将配置文件拷贝给所有Spark节点（需要注意的是其他的Slave节点同样也需要安装Scala!）
#当Spark与Hadoop节点不在同一主机时需要拷贝hdfs-site.xml、yarn-site.xml、hive-site.xml等文件到Spark的conf下
scp spark-env.sh  X.X.X.X:$(pwd)
scp slave  X.X.X.X:$(pwd)

#选个主节点启动Spark ( start-master.sh + start-slaves.sh ==> start-sll.sh ) 其将顺便依slaves的信息启动所有Slave节点
sbin/start-all.sh

#选个备节点启动Master，其将自动转为监听状态来监听主节点存活，可通过其URL:8080查看状态...
sbin/start-master.sh

#各节点验证 Spark 是否安装成功
$ jps | grep -iE "Master|Worker"
7805 Master

#URL：    http://master:8080
#CLI：    cd ~/spark/bin && ./spark-shell
---------------------------------------------------------------  Example

#本地模式两线程运行
./bin/run-example SparkPi 10 --master local[2]

#Spark Standalone 集群模式运行
./bin/spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master spark://master:7077 \
    lib/spark-examples-1.3.0-hadoop2.4.0.jar \
    100
  
#Spark on YARN 集群上 yarn-cluster 模式运行
./bin/spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master yarn-cluster \  # can also be `yarn-client`
    lib/spark-examples*.jar \
    10
    
#计算圆周率
./spark-submit --class org.apache.spark.examples.SparkPi \
--master yarn-cluster ../examples/jars/spark-examples_2.11-2.3.0.jar


说明：
./bin/spark-submit \
  --class <main-class> \    指定jar包的入口位置,不是物理位置 ( 作业的主类 )
  --master <master-url> \   指定spark执行的master和端口号，可以在程序中SparkConf中进行指定
  --deploy-mode client \    client 模式表示作业的AM会放在Master节点运行。若设置此参数则需同时指定上面 master 为 yarn
  --conf <key>=<value> \
  --executor-cores 2  \     各 executor 使用的并发线程数目，即每个 executor 最大可并发执行的 Task 数
  --executor-memory 20G \   各 executor 使用的最大内存，不可超过单机的最大可使用内存
  --num-executors 50 \  创建多少个 executor
  ... # other options \
  <application-jar> \   编译好jar包的位置
  [application-arguments]
  
-----------------------------------------------------------------------------------------

#基本概念：
#RDD（resillient distributed dataset）：弹性分布式数据集（RDD的每个partition实际上是1个用于计算的task。这些task被分布在集群里并行计算）
#Task：具体执行任务。Task分为ShuffleMapTask和ResultTask两种。ShuffleMapTask、ResultTask分别类似于Hadoop中的Map、Reduce
#Job：用户提交的作业。一个Job可能由一到多个Task组成
#Stage：Job分成的阶段。一个Job可能被划分为一到多个Stage
#Partition：数据分区。即一个RDD的数据可以划分为多少个分区
#NarrowDependency：窄依赖。即子RDD依赖于父RDD中固定的Partition。NarrowDependency分为OneToOneDependency和RangeDependency2种
#ShuffleDependency：shuffle依赖，也称为宽依赖。即子RDD对父RDD中的所有Partition都有依赖
#DAG（Directed Acycle graph）：有向无环图。用于反映各RDD之间的依赖关系

#基本架构：
#Cluster Manager：
#   Spark的集群管理器，主要负责资源的分配与管理
#   集群管理器分配的资源属于一级分配，它将各个Worker上的内存、CPU等资源分配给应用程序，但是并不负责对Executor的资源分配
#   目前，Standalone、YARN、Mesos、EC2等都可以作为Spark的集群管理器
#Worker：
#   Spark的工作节点。对Spark应用程序来说，由集群管理器分配得到资源的Worker节点主要负责以下工作：
#   1、创建Executor，将资源和任务进一步分配给Executor
#   2、同步资源信息给Cluster Manager
#   集群中每台计算机是1个节点。1个节点可以有1或多个worker，一般就配1个worker
#   每个worker可以申请1或多个核心（这里的核心实际上代表起的线程），核心数量一般不超过CPU物理核心数量
#Executor：
#   执行计算任务的一线进程。主要负责任务的执行以及与Worker、Driver App的信息同步
#Driver App：
#   客户端驱动程序，也可以理解为客户端应用程序，用于将任务程序转换为RDD和DAG，并与Cluster Manager进行通信与调度
