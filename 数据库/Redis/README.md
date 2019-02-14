#### 特点
```txt
编译Redis时不需要configure，直接Make即可（将在当前的make目录生成可使用的src子目录）...
支持两种数据持久化，可将内存中数据保持在磁盘并在重启的时再次加载...
不仅支持简单的key:value型数据，同时还提供list，set，zset，hash等丰富的数据结构的存储及操作方式...
支持数据的备份，即 "Master/Slave" 模式，一般情况下其读：110000/s，写：81000/s
Redis的所有操作都是原子性的，还支持对几个操作全并后的原子性执行（事物）
还支持 publish/subscribe：发布/订阅通知, key过期，事物模拟等特性...
```
#### 数据的两种持久化方式
```txt
1. Snapshotting ( 半持久化模式 )
    利用了快照的原理，使得数据以异步方式从内存中传输到磁盘中去，默认是个二进制文件："dump.rdb"
    在conf中格式是：save N M 表示在N秒之内至少发生M次修改则抓快照到磁盘。当然也可手动执行save或bgsave (异步)做快照
    
    例：
    save 900 10         #900秒内如果超过10个key被修改，则发起快照保存
    save 300 20         #300秒内容如超过20个key被修改，则发起快照保存

2. AOF ( 全持久化模式：append only file )
    把每次的写操作都直接附加在磁盘的现有文件后面
    Snapshotting方式在redis异常死掉时最近的数据会丢失（丢失数据的多少视save策略的配置）所以这是它最大的缺点
    当业务量很大时Snapshotting丢失的数据很多
    Append-only方法可以做到全部数据不丢失，但redis的性能就要差些（默认情况下AOF是关闭的）
    当redis重启时会读取AOF文件进行重放以恢复到关闭前的最后时刻
    
    AOF模式下文件刷新的三种方式：
        appendfsync always      #每次提交都调用fsync刷新到AOF文件，非常慢但是非常安全
        appendfsync everysec    #每秒都调用fsync刷新到AOF文件，很快但可能会丢失一秒内的数据
        appendfsync no          #依靠OS进行刷新，redis不主动刷新AOF，这样最快但安全性最差
    
```
#### redis-check-* 命令
```txt
redis-check-dump    #检测RDB备份文件
redis-check-aof     #检测AOF备份文件
```
#### 部署
```txt
[root@localhost redis-3.2.11]# redis-server -h
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
       ./redis-server /etc/sentinel.conf --sentinel
       
常用的管理命令
    1 ping  测试服务器是否在线，若在线则返回PONG
    2 echo  与SHELL的echo类似
    3 select 选择数据库 select [0-16个] 数据库
    4 quit 退出链接
    5 dbsize  返回数据库的键的个数
    6 info  返回服务器状态相关的信息...（使用INFO XXX 可查看其列出的具体信息...）
    7 KILL 指明IP+PORT可以直接关闭对应的连接上来的Client
    8 flushdb  清空当前数据库所有键值
    9 flushall  删除所有数据库中所有的键
    10 bgsave  用异步方式手动将数据快照存储到磁盘
    11 config get ...  返回配置信息
    12 config set ...  设置配置信息
    13 config rewrite  将在内存中修改的配置回写至配置文件...
    14 shutdown  把所有数据的同步到磁盘之后安全的关闭服务（参数：nosave/save）
```

#### 设置主从
```txt
配置从服务器非常简单， 只要在配置文件中增加以下一行代码即可：
    slaveof <master_ip_address> <port>

另外一种方法是调用 SLAVEOF 命令， 输入主服务器的 IP 和端口， 然后同步就会开始：
    127.0.0.1:6379> SLAVEOF 192.168.1.1 10086
    OK
```
