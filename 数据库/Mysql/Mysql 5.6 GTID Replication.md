#### 修改主节点的 Mysql 配置文件： my.cnf
```bash
[root@localhost ~]# cat /etc/my.cnf
[mysqld]

#主从ID标识
server_id = 1

#建议开启Inodb的独立表空间
innodb_file_per_table=1 

skip_resolve_name=1

#使用全局事务唯一标识来进行同步（以下任一参数不开启都会报错）
gtid-mode=on
#强制保证GTID的一致性
enforce-gtid-consistency=true
log-slave-updates=true

#二进制日志
log_bin = mysql-bin
log-bin-index = mysql-bin.index

#二进制日志类型
binlog_format=mixed

#0：事务提交后由系统决定何时处理缓存到持久化
#1：每执行一次事务均回写到二进制日志
#N：每N次事务提交之后由Mysql强制回写到持久化
sync_binlog=1

#需同步的数据库，注：binlog-do-db 与 binlog-ignore-db 为互斥关系
binlog-do-db = 

#需忽略的数据库
binlog-ignore-db = mysql
binlog-ignore-db = performance_schema
binlog-ignore-db = information_schema

#从服务器是否对二进制日志进行校验，NONE可兼容旧版本
binlog_checksum=NONE

#ANSI                   宽松模式，对插入数据校验，若不符合定义类型或长度将调整或截断保存，报warning警告 
#TRADITIONAL            严格模式，当插入数据时，进行严格校验以保证错误数据不能插入，报error错误。用于事物时会进行回滚 
#STRICT_TRANS_TABLES    严格模式，进行数据的严格校验，错误数据不能插入，报error错误
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[root@Master ~]# systemctl restart mysqld       #重读Mysql服务的配置文件
[root@Master ~]# systemctl stop firewalld
[root@Master ~]# setenforce 0
```

#### Master 授权同步账号
```mysql
mysql> grant replication slave on  *.*  to 'username'@'%' identified by 'password';
mysql> flush privileges;
```

#### 将完整备份导到从库
```bash
#拷出主服务器数据
[root@Master ~]# mysqldump -u $name -p --flush-logs --master-data=2 --single-transaction $dbname > ${dbname}.sql 
[root@Master ~]# scp ${dbname}.sql  root@<slave_address>:/var/lib/mysql

#记录主节点的二进制日志位置（在使用传统复制方式时需要进行记录供后续同步操作时使用，使用GTID方式时此步骤直接省略）
MySQL> show master status;
+------------------+----------+--------------+---------------------------------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB                            | Executed_Gtid_Set |
+------------------+----------+--------------+---------------------------------------------+-------------------+
| mysql-bin.000001 |      120 | 123test      | mysql,performance_schema,information_schema |                   |
+------------------+----------+--------------+---------------------------------------------+-------------------+
1 row in set (0.00 sec)

#从服务器还原数据(某些场合需要先创建数据库后在执行导入)
[root@Slave ~]# mysqldump -u $username -p$password $dbname < ${dbname}.sql
[root@Slave ~]# systemctl stop mysqld
```

#### 修改从节点的 Mysql 配置文件： my.cnf
```bash
[mysqld]

#主从ID标识
server-id = 2

#建议开启Inodb的独立表空间
innodb_file_per_table=1 

skip_resolve_name=1

#强制只读，命令行方式修改： Mysql [(none)] > SET @@global.read_only = ON;
#read_only = on

#二进制日志
log_bin = mysql-bin

#使用全局事务唯一标识进行同步并强制GTID的一致性，否则就是普通的复制架构
gtid-mode = on
enforce-gtid-consistency = true

#从服务器的SQL线程数；0表示关闭多线程复制功能（开启多线程复制，5.6版本为1库执行1个sql线程，5.7为1组1线程）
slave-parallel-workers = 6

#自 Mysql 5.7 版本开始支持真正的并行复制（DATABASE：基于库，LOGICAL_CLOCK：基于组）
#slave-parallel-type = [ DATABASE | LOGICAL_CLOCK ]

#SQL线程读取 relay-log 的内容在从节点中回放（中继日志）
relay-log = slave-relay-bin
relay-log-index = slave-relay-bin.index

#当服务关闭时保存主库信息
sync_master_info = 1

#1：I/O线程每次收到Master发来的binlog均写入系统缓冲区然后刷入中继日志 relay log
#0：并不是马上就刷入中继日志里，而是由操作系统决定何时来写入
sync_relay_log = 0

#每间隔多少事务刷新relay-log.info
sync_relay_log_info = 1

#需复制的数据库 ( 与ignore互斥 )
#replicate-do-db = 123test

#不写入二进制日志的数据库，注：bin-do-db,bin-ignore-db 为互斥关系，只需设置其中一项即可
binlog-ignore-db = information_schema
binlog-ignore-db = cluster
binlog-ignore-db = mysql

#需忽略的数据库
replicate-ignore-db = information_schema
replicate-ignore-db = cluster
replicate-ignore-db = mysql

#让备库从主复制数据时写到二进制日志
#备开启log-bin后若直接写数据是记入二进制日志的，但备通过I0线程读取主库二进制日志后通过SQL线程写入的数据不会写入binlog
#当备服务器又作为他服务器的主时需设置此参数
log-slave-updates = true

#定义复制过程中备服务器可忽略的错误号，当复制过程中遇到定义的错误号就可以自动跳过来执行后面的SQL
slave-skip-errors = all

#当从库等待指定的秒数后才认为网络故障，然后再重连并追赶这段时间主库的数据
slave-net-timeout = 60

[root@Master ~]# systemctl restart mysqld
[root@Master ~]# systemctl stop firewalld
[root@Master ~]# setenforce 0
```

#### 在备服务器进行同步
```mysql
mysql> change master to master_host='192.168.139.132',master_user='root', master_password='123456'
    -> master_auto_position=1; 
mysql> start slave;
MySQL> show global variables like'%gtid%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| binlog_gtid_simple_recovery     | OFF   |
| enforce_gtid_consistency        | ON    |
| gtid_executed                   |       |
| gtid_mode                       | ON    |
| gtid_owned                      |       |
| gtid_purged                     |       |
| simplified_binlog_gtid_recovery | OFF   |
+---------------------------------+-------+
7 rows in set (0.01 sec)
MySQL> show slave status\G;
            ................
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
                    SQL_Delay: 0
            ................
```

#### UUID的问题
```bash
MySQL [123test]> show variables like 'datadir';    
+---------------+--------+
| Variable_name | Value  |
+---------------+--------+
| datadir       | /data/ |
+---------------+--------+
1 row in set (0.00 sec)

#在实验环境中使用的是克隆机，因UUID相同导致了备服务器的IO线程打不开，因此需要修改此UUID
[root@localhost etc]# cat /data/auto.cnf    
[auto]
server-uuid=764eb613-8165-11e7-b960-000c29b97472
```
