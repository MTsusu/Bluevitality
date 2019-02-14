#### 用途
```txt
Sentinel 用于管理多个 Redis 服务器（instance），其主要执行以下三个任务：
  一，监控（Monitoring）：     
        Sentinel 会不断地检查主/从服务器是否运作正常
  二，提醒（Notification）：   
        当被监控的某个 Redis 出现问题时 Sentinel 可通过 API 向管理员或者其他应用发送通知
  三，自动故障迁移（Automatic failover）：     
        当主不能正常工作时， Sentinel 会自动进行故障迁移操作， 将失效主服务器的其中一个从服务器升级为新的主服务器
        并让失效主服务器的其他从服务器改为复制新的主服务器
        当客户端试图连接失效的主时集群会向其返回新的主服务器地址，使得集群可用新的主服务器代替失效的
```
#### 备忘
```txt
Redis Sentinel 是一个分布式的系统，可在一个架构中运行多个 Sentinel 进程
这些进程使用流言协议（gossip protocols）来接收关于主服务器是否下线的信息
并使用投票协议（agreement protocols）来决定是否执行自动故障迁移，以及选择哪个从服务器作为新的主服务器。

虽然 Redis Sentinel 释出为一个单独的可执行文件 redis-sentinel 但实际上它只是一个运行在特殊模式下的 Redis 服务器
你可以在启动一个普通 Redis 服务器时通过给定 "--sentinel" 选项来启动 Redis Sentinel

[root@localhost src]# pwd
/root/redis-3.2.11/src
[root@localhost src]# ll redis-sentinel                 # redis-sentinel /etc/sentinel.conf
-rwxr-xr-x. 1 root root 5191045 11月 20 21:48 redis-sentinel
[root@localhost src]# redis-server -h
Usage: ./redis-server [/path/to/redis.conf] [options]
       ./redis-server - (read config from stdin)
       ./redis-server -v or --version
       ./redis-server -h or --help
       ./redis-server --test-memory <megabytes>

Examples:
       ./redis-server (run the server with default conf)
       ./redis-server /etc/redis/6379.conf
       ./redis-server --port 7777
       ./redis-server --port 7777 --slaveof 127.0.0.1 8888
       ./redis-server /etc/myredis.conf --loglevel verbose

Sentinel mode:
       ./redis-server /etc/sentinel.conf --sentinel     # 相当于：redis-sentinel 

#启动 Sentinel 实例必须指定相应的配置文件
#系统会使用配置文件来保存 Sentinel 的当前状态， 并在 Sentinel 重启时通过载入配置文件来进行状态还原。
```
#### 配置文件 sentinel.conf
```txt
[root@localhost redis-3.2.11]# cat sentinel.conf    #monitor可出现多次（监控多个主从复制架构）
sentinel monitor mymaster 127.0.0.1 6379 2          #被监视的主节点（将其判为失效至少要2个Sentinel同意才故障转移）
sentinel down-after-milliseconds mymaster 60000     #认为服务器已经断线所需的毫秒数
sentinel failover-timeout mymaster 180000           #
sentinel parallel-syncs mymaster 2                  #执行故障转移时最多可有多少个从服务器同时对新的主服务器进行同步
sentinel monitor resque 192.168.1.3 6380 4          #
sentinel down-after-milliseconds resque 10000       #
sentinel failover-timeout resque 180000             #若在该时间"ms"内未能完成failover操作，则认为failover失败...
sentinel parallel-syncs resque 5                    #
```
#### Sentinel 命令
```txt
PING ：              
#返回 PONG 。

SENTINEL masters ：  
#列出所有被监视的主服务器，以及这些主服务器的当前状态。

SENTINEL slaves <master name> ： 
#列出给定主服务器的所有从服务器，以及这些从服务器的当前状态。

SENTINEL get-master-addr-by-name <master name> ：
#返回给定名字的主服务器的 IP 地址和端口号。如果这个主服务器正在执行故障转移操作， 
#或者针对这个主服务器的故障转移操作已经完成， 那么这个命令返回新的主服务器的 IP 地址和端口号

SENTINEL reset <pattern> ：  
#重置所有名字和给定模式 pattern 相匹配的主服务器。 pattern 参数是一个 Glob 风格的模式。
#重置操作清楚主服务器目前的所有状态， 包括在执行中的故障转移并移除目前已发现和关联的主服务器的所有从服务器和 Sentinel

SENTINEL failover <master name> ：   
#当主服务器失效时， 在不询问其他 Sentinel 意见的情况下， 强制开始一次自动故障迁移 
#（不过发起故障转移的 Sentinel 会向其他 Sentinel 发送一个新的配置，其他 Sentinel 会根据这个配置进行相应的更新）
```
