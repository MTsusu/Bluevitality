#### 简介
```txt
Xtrabackup是由percona提供的mysql备份工具，据官方介绍这也是惟一一款开源的能够对innodb和xtradb数据库进行热备的工具
xtrabackup只能备份InnoDB和XtraDB两种数据引擎的数据而不能备份MyISAM数据，而innobackupex封装了xtrabackup...
innobackupex是脚本封装，能同时处理innodb和myisam，但处理myisam时需加读锁
最新版可从 http://www.percona.com/software/percona-xtrabackup/ 获得...

原理：
innobackupex在后台线程不断追踪InnoDB的日志文件，然后复制InnoDB的数据文件（备份时不会对表加锁）。
数据文件复制完成之后其日志的复制线程也会结束，这样就得到了不在同一时间点的数据副本和开始备份以后的事务日志。
完成上面的步骤之后就可以使用InnoDB崩溃恢复代码执行事务日志（redo log）以达到数据的一致性。

备份分为两个过程：
1. backup      备份阶段，追踪事务日志和复制数据文件（物理备份）
2. preparing   重放事务日志，使所有的数据处于同一个时间点，达到一致性状态

特点：
1. 备份过程快速、可靠；
2. 备份过程不会打断正在执行的事务；
3. 能够基于压缩等功能节约磁盘空间和流量；
4. 自动实现备份检验；
5. 还原速度快；

```

#### 常用参数
```txt
--user=                   指定数据库备份用户
--password=               指定数据库备份用户密码
--port=                   指定数据库端口
--host=                   指定备份主机
--socket=                 指定socket文件路径
--databases=              备份指定数据库,多个空格隔开，如--databases="dbname1 dbname2"（默认情况下备份所有库）
--defaults-file=          指定my.cnf配置文件路径
--apply-log               日志回滚（利用其记录的事物日志信息使数据恢复到同一时间点上一致的状态）
--incremental=            增量备份，后跟增量备份路径
--incremental-basedir=    增量备份，指上次增量备份路径（即：以哪个时间点的备份数据做本次增量的基础）
--redo-only               合并全备和增量备份数据文件（增量还原时其指定的是最初的全备路径）
--copy-back               将备份数据复制到数据库，数据库目录要为空
--no-timestamp            生成备份文件不以时间戳为目录名
--stream=                 指定流的格式做备份,--stream=tar,将备份文件归档
--remote-host=user@ip DST_DIR     备份到远程主机
```
#### "流"及"备份压缩"
```bash
# Xtrabackup对备份的数据文件支持“流”功能，即将备份的数据通过STDOUT传给tar进行归档，而不是默认的直接保存至某目录
# 要使用此功能，仅需要使用--stream选项即可
[root@localhost /]# innobackupex --stream=tar  /backup | gzip > /backup/`date +%F_%H-%M-%S`.tar.gz

# 也可以使用类似如下命令将数据备份至其它服务器：
[root@localhost /]# innobackupex --stream=tar  /backup | ssh \
user@www.magedu.com  "cat -  > /backups/`date +%F_%H-%M-%S`.tar" 

# 在执行本地备份时还可用'--parallel'对多个文件进行并行复制。此选项用于指定在复制时启动的线程数
# 在实际备份时要利用其便利性则需启用innodb_file_per_table或共享表空间通过innodb_data_file_path选项存储在多个ibdata文件中
# 对某一数据库的多个文件的复制无法利用到此功能。其简单使用方法如下：
[root@localhost /]# innobackupex --parallel  /path/to/backup

# innobackupex备份的数据文件也可以存储至远程主机，可用--remote-host实现：
[root@localhost /]# innobackupex --remote-host=root@www.magedu.com  /path/IN/REMOTE/HOST/to/backup
```

#### 备份目录说明：
```txt
# ls 2016-05-07_23-06-04
backup-my.cnf：           记录innobackup使用到mysql参数
xtrabackup_binary：       备份中用到的可执行文件
xtrabackup_checkpoints：  记录备份的类型、开始和结束的日志序列号（如完全或增量）、状态和LSN（日志序列号）范围信息
xtrabackup_logfile：      备份中会开启1个log copy线程用来监控innodb日志文件（ib_logfile），若修改则复制到此文件
xtrabackup_binlog_info    记录二进制日志的文件和日志点，可用于slave同步change master配置
```
