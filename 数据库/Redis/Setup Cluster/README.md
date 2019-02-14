#### 备忘
```txt
Redis集群的优势:
    自动分割数据到不同的节点。
    集群部分节点失败或不可达情况下能继续处理命令。
    
集群使用于Redis3.0以上版本，Redis集群是提供在多个节点间共享数据的程序集
为了在部分节点失败或大部分节点无法通信时集群仍然可用，所以集群也使用了主从复制模型，每个节点都会有N-1个复制品
要让集群正常运作至少要3个主节点，不过强烈建议用6个节点：其中3个为主，其余3个是各主节点的从节点，当主Down时其升为备
Redis Cluster在设计时就考虑了去中心化，去中间件，也就是说集群中的每个节点都是平等关系，是对等的
每个节点都保存各自的数据和整个集群的状态。每个节点都和其他所有节点连接，而且这些连接保持活跃
集群会把数据存在1个master节点，然后在这个master和其对应的salve间同步。当读数据时也根据一致性哈希算法到对应的master获取。
只有当一个Master挂掉后，才会启动其对应的Salve节点来充当Master
```
#### 集群配置示例 Demo
```txt
daemonize    yes                   后台运行
port 7000                          各节点的工作端口
cluster-enabled yes                启用集群模式
cluster-config-file nodes.conf     指明保存集群内节点配置的路径，其无须人为修改，由集群在启动时创建并在有需要时更新
cluster-node-timeout 5000          请求超时，默认15秒
appendonly yes                     开启AOF日志，它会为每次写操作都记录1条日志
```
#### 部署 Redis Cluster
```bash
#Redis3.0版自身支持cluster模式
#Redis提供的创建集群的工具为ruby脚本，所以在部署Cluster前需先装ruby（包括ruby,rubygems）以及ruby的redis支持包
#Redis-trib.rb是Redis官方推出的ruby脚本，集成在redis源码src目录内，是基于Redis提供的集群命令封装的简单实用工具

#安装 Ruby + rubygems + redis.gem
cd /home/zyzx/sww/ruby && tar -zxf ruby-2.2.2.tar.gz -C . && cd ruby-2.2.2
./configure --prefix=/home/zyzx/ruby
make && make install

export PATH=.:/home/zyzx/ruby/bin:$PATH
echo "PATH=$PATH" >> ~/.bash_profile

cd /home/zyzx/sww/ruby && tar -zxf rubygems-2.4.6.tgz -C .
cd rubygems-2.4.6 && ruby setup.rb
cd /home/zyzx/sww/ruby && gem install -l redis-3.2.1.gem
#若上面的步骤出问题，参考：http://www.51testing.com/html/77/497177-3709664.html

# 编译安装Redis
tar -zxvf redis-3.0.0.tar.gz -C . && cd redis-3.0.0 && make

#创建实例的路径并拷贝数据，此处是单机多实例，注意！由于是三主三从的模式，共需启动六个实例!
mkdir -p /home/zyzx/redis/redis-master-{1..3}/{bin,config,data,log}
mkdir -p /home/zyzx/redis/redis-slave-{1..3}/{bin,config,data,log}
cp -p /home/zyzx/sww/redis-3.0.0/src/* /home/zyzx/redis/redis-master-{1..3}/bin/
cp -p /home/zyzx/sww/redis-3.0.0/src/* /home/zyzx/redis/redis-slave-{1..3}/bin/

#Redis配置样例
#具体每个redis为了支持集群和保证在集群中的唯一性，需要更改每个节点的redis.conf配置，部分参数要区别配置
vim /home/zyzx/redis/redis1/config/redis-21301.conf
daemonize yes
#若单机多实例，每个实例的PID路径要注意区别
pidfile /var/run/redis.pid
#端口号，单机部署集群时不要重复         
port 21301
#绑定本机网卡IP地址（可多地址，中间空格分开），要确保集群中IP:PORT唯一                        
bind 172.17.15.149
#是否启用集群
cluster-enabled yes
#集群创建后，6个集群节点的的集群相关信息存储的文件，若多个实例在同一节点时此文件不要冲突
cluster-config-file nodes.conf
#集群主从节点之间检测超时心跳时间      
cluster-node-timeout 2000
#集群允许某些分片无法分配主节点情况下仍然是可用的，对外提供访问。
cluster-require-full-coverage no 
#开启aof持久化方式
aof-rewrite-incremental-fsync yes
tcp-backlog 511
timeout 0
tcp-keepalive 0
loglevel verbose
#需要注意多实例时此路径的区别
logfile "/home/zyzx/redis/redis1/log/21301.log"
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error no
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-entries 512
list-max-ziplist-value 64
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
```
#### Redis启停脚本样例
```bash
#启动脚本，注意! 部署到现在的六个节点目前还是单实例模式，随后要使用 redis-trib.rb 工具创建集群
cat redis_startAllServer.sh 
#!/bin/bash

p=$(pwd)
cd redis-master-1/bin
./redis-server ../config/redis-21301.conf
sleep 1
cd $P && cd redis-master-2/bin
./redis-server ../config/redis-21302.conf
sleep 1
cd $P && cd redis-master-3/bin
./redis-server ../config/redis-21303.conf
sleep 1
cd $P && cd redis-slave-1/bin
./redis-server ../config/redis-22301.conf
sleep 1
cd $P && cd redis-slave-2/bin
./redis-server ../config/redis-22302.conf
sleep 1
cd $P
cd redis-slave-3/bin
./redis-server ../config/redis-22303.conf
echo "Redis Service Start Success!"

#停止脚本
cat redis_stopAllServer.sh 
#!/bin/bash

cd redis-master-1/bin
./redis-cli  -h 192.168.21.177 -p 21301 shutdown
sleep 1
./redis-cli  -h 192.168.21.177 -p 21302 shutdown
sleep 1
./redis-cli  -h 192.168.21.177 -p 21303 shutdown
sleep 1
./redis-cli  -h 192.168.21.177 -p 22301 shutdown
sleep 1
./redis-cli  -h 192.168.21.177 -p 22302 shutdown
sleep 1
./redis-cli  -h 192.168.21.177 -p 22303 shutdown
echo "Redis Service Stop Success!"
```
#### 创建 Redis Cluster
```bash
#创建Redis集群的前提是先把redis各节点都正常启动，以下创建命令只需在某个节点执行一次即可!
#注意! 安装redis集群需要用到redis-trib.rb脚本，运行.rb脚本需系统安装支持ruby环境。

cd /home/zyzx/redis/redis1/bin
#下面"--replicas"标识需几个Slave，提示是否创建时输入yes即可，此IP:PORT要保证各中心服务的jar包所在机器可直接访问到
#默认情况下，在redis-trib.rb命令中，前三个为主节点，后三个为从节点（需要事先启动6个Redis实例再做此操作）...
./redis-trib.rb create --replicas 1 192.168.133.128:21301 192.168.133.130:21301 192.168.133.131:21301 \
192.168.133.128:21302 192.168.133.130:21302 192.168.133.131:21302
>>> Creating cluster
Connecting to node 192.168.133.128:21301: OK
Connecting to node 192.168.133.130:21301: OK
Connecting to node 192.168.133.131:21301: OK
Connecting to node 192.168.133.128:21302: OK
Connecting to node 192.168.133.130:21302: OK
Connecting to node 192.168.133.131:21302: OK
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
192.168.133.128:21301
192.168.133.130:21301
192.168.133.131:21301
Adding replica 192.168.133.130:21302 to 192.168.133.128:21301
Adding replica 192.168.133.128:21302 to 192.168.133.130:21301
Adding replica 192.168.133.131:21302 to 192.168.133.131:21301
M: 159edea9d15c63a2537fecb88c8035c1e083f498 192.168.133.128:21301
   slots:0-5460 (5461 slots) master
M: d754834e47865dd2f126593ab3a6618a3aa9dc99 192.168.133.130:21301
   slots:5461-10922 (5462 slots) master
M: a52337f94913f3fa0db10434f432ac72290737be 192.168.133.131:21301
   slots:10923-16383 (5461 slots) master
S: 1d84775ffad4219a7ca63f22b1feaa3d40bad39c 192.168.133.128:21302
   replicates d754834e47865dd2f126593ab3a6618a3aa9dc99
S: 62400b36e721426ef3956ef5d61b3e3986ffae7e 192.168.133.130:21302
   replicates 159edea9d15c63a2537fecb88c8035c1e083f498
S: 594b75b044062def0f91b8f0b7b39f85d50c5554 192.168.133.131:21302
   replicates a52337f94913f3fa0db10434f432ac72290737be
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join.
>>> Performing Cluster Check (using node 192.168.133.128:21301)
M: 159edea9d15c63a2537fecb88c8035c1e083f498 192.168.133.128:21301
   slots:0-5460 (5461 slots) master
M: d754834e47865dd2f126593ab3a6618a3aa9dc99 192.168.133.130:21301
   slots:5461-10922 (5462 slots) master
M: a52337f94913f3fa0db10434f432ac72290737be 192.168.133.131:21301
   slots:10923-16383 (5461 slots) master
M: 1d84775ffad4219a7ca63f22b1feaa3d40bad39c 192.168.133.128:21302
   slots: (0 slots) master
   replicates d754834e47865dd2f126593ab3a6618a3aa9dc99
M: 62400b36e721426ef3956ef5d61b3e3986ffae7e 192.168.133.130:21302
   slots: (0 slots) master
   replicates 159edea9d15c63a2537fecb88c8035c1e083f498
M: 594b75b044062def0f91b8f0b7b39f85d50c5554 192.168.133.131:21302
   slots: (0 slots) master
   replicates a52337f94913f3fa0db10434f432ac72290737be
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

#查看集群的状态，会出现3个M和3个S，及主备关系和分片。
./redis-trib.rb check 192.168.133.128:21301
```

#### redis-trib 命令备忘
```txt
redis-trib.rb具有以下功能：
    create ：创建集群
    check ：检查集群
    info ：查看集群信息
    fix ：修复集群
    reshard ：在线迁移slot
    rebalance ：平衡集群节点slot数量
    add-node ：将新节点加入集群
    del-node ：从集群中删除节点
    set-timeout ：设置集群节点间心跳连接的超时时间
    call ：在集群全部节点上执行命令
    import ：将外部redis数据导入集群
```
