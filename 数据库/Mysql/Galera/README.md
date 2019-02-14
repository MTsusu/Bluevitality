#### 备忘
```txt
Galera Cluster 是在 Mysql / mariadb 基础上提供的一种底层复制机制，使用 Galera 需要下载集成此功能的数据库进行编译才可以
注：设置Galera集群至少要3台服务器（若仅两台的话需特殊配置："arbitrator" 详情请参照官方文档）其原理复杂但实现简单.....

支持使用Wresp协议进行复制的发行版：（安装 Galera-Cluster 时将替换掉正常使用的 RDBMS ）
  1.Percona-Cluster
  2.Mariadb-Cluster ---> https://mariadb.com/kb/en/library/yum/#installing-mariadb-galera-cluster-with-yum

特性：
  1.同步复制
  2.真正的 multi-master，所有节点可以同时读写数据库
  3.自动的成员控制，失效节点自动被清除（当失效节点重新加入集群时需修改 wsrep_cluster_address 参数为集群内互活跃成员地址）
  4.新节点加入数据自动复制
  5.真正的并行复制，行级，同时具有读和写的扩展能力
  6.用户可以直接连接集群，使用感受上与MySQL完全一致
  7.节点间数据是同步的,而 Master/Slave 模式是异步的,不同 slave 上的 binlog 可能是不同的
  8.不存在丢失交易的情况，当节点发生崩溃时无数据丢失
  9.数据复制保持连续性

```
#### Galera Cluster 部署流程 （ 环境：CentOS7 ）
```bash
[root@localhost ~]# vim /etc/hosts                              #在每个节点上配置集群内各节点的主机名与IP映射
[root@localhost ~]# systemctl stop firewalld
[root@localhost ~]# systemctl disable firewalld

[root@localhost ~]# cat >> /etc/yum.repos.d/MariaDB.repo <<eof 
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
eof
[root@localhost ~]# yum install -y mariadb Mariadb-Galera-server Mariadb-Galera-common galera rsync \
MariaDB-server MariaDB-client                                   #新版本或许会改变RPM包名字（此处全部下载）...
[root@localhost ~]# systemctl start mariadb
[root@localhost ~]# mysql_secure_installation                   #进行安全初始化
[root@localhost ~]# systemctl stop mariadb
[root@localhost ~]# rpm -ql galera | grep smm.so                #提供 wsrep 协议的插件
/usr/lib64/galera/libgalera_smm.so
[root@localhost ~]# cat /etc/my.cnf.d/galera.cnf                #加入 galera Cluster 的配置信息
[galera]
wsrep_on=ON
wsrep_provider=/usr/lib64/galera/libgalera_smm.so               #指向提供 wsrep 的插件，rpm -ql x | grep smm.so
wsrep_cluster_address="gcomm://192.168.1.112,192.168.1.113 "    #可用/etc/hosts映射（集群内任1成员IP即可，可多个）
binlog_format=row                                               #binlog格式，在 Galera 集群应使用：row 或 mix
default_storage_engine=InnoDB                                   #默认存储引擎（目前Galera仅支持Innodb）
innodb_autoinc_lock_mode=2                                      #锁格式
bind-address=0.0.0.0                                            #wsrep的监听地址
wsrep_cluster_name="Galera-Cluster"                             #当前的 Galera 集群的名字标识
wsrep_node_address="192.168.1.112"                              #本节点的IP地址
wsrep_node_name="node1"                                         #本节点的hostname值（必须）
#wsrep_sst_method=rsync
#wsrep_sst_auth=root:command
#wsrep_provider_options="socket.ssl_key=/etc/pki/galera/galera.key; socket.ssl_cert=/etc/pki/galera/galera.crt;"

#因systemd默认不支持加入参数，手动启动, ⚠ --wsrep-new-cluster 参数仅在初始化集群时使用! 且只能在任1个节点使用!（初始化）
[root@localhost ~]# /usr/libexec/mysqld --wsrep-new-cluster --user=root &  

[root@localhost ~]# tail -f /var/log/mariadb/mariadb.log                    #观察日志
150701 19:54:17 [Note] WSREP: wsrep_load(): loading provider library 'none'
150701 19:54:17 [Note] /usr/libexec/mysqld: ready for connections.          #出现ready for connections 证明启动成功
Version: '5.5.40-MariaDB-wsrep'  socket: '/var/lib/mysql/mysql.sock' port: 3306  MariaDB Server, ......

[root@mariadb-2 ~]# systemctl start mariadb            #陆续启用其他节点
[root@mariadb-3 ~]# systemctl start mariadb
[root@mariadb-4 ~]# systemctl start mariadb            #查看 /var/log/mariadb/mariadb.log 可看到节点均加入了集群


[root@localhost4 ~]#mysql -uroot -p123456  -e 'show status like "wsrep_%";'
wsrep_connected = on        #链接已开启
wsrep_local_index = 1       #在集群中的索引值
wsrep_cluster_size =3       #集群中节点的数量
wsrep_incoming_addresses = 10.128.20.17:3306,10.128.20.16:3306,10.128.20.18:3306    #集群中节点的访问地址
```
#### 为集群加入冲裁者： Galera arbitrator
```txt
对于只有2个节点的 Galera Cluster 和其他集群一样需要面对极端情况下的"脑裂"状态。为避免这种问题，Galera引入了"arbitrator"
"仲裁人"节点上没有数据，它在集群中的作用就是在集群发生分裂时进行仲裁，集群中可以有多个"仲裁人"节点。
"仲裁人"节点加入集群的方法很简单，运行如下命令即可:
[root@arbitrator ~]# garbd -a gcomm://192.168.0.171:4567 -g my_wsrep_cluster -d
 
参数说明:
    -d  以daemon模式运行
    -a  集群地址
    -g  集群名称
```
#### 注意
```txt
/etc/my.cnf.d/galera.cnf的配置参数 "wsrep_cluster_address" 中的 "gcomm://" 是特殊的地址：
  wsrep_cluster_address 仅在 Galera cluster 初始化启动时使用
  如果集群启动以后我们关闭了第一个节点（初始化节点），那么再次启动的时候必须先修改 "gcomm://" 为其他活跃节点的集群地址

为了能够引入配置，需要在/etc/my.cnf中加入：!includedir /etc/my.cnf.d/
```
