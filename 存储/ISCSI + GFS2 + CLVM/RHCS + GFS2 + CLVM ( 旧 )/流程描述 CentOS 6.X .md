#### 环境（大致流程）
```txt
当前ISCSI的C/S环境已经设置完毕
```
#### 节点设置（非Target端）
```bash
#使客户端支持clvm
[root@localhost ~]# lvmconf --enable-cluster

[root@localhost ~]# yum -y install luci ricci
[root@localhost ~]# useradd ricci
[root@localhost ~]# echo 123456 | passwd ricci --stdin

#关闭集群内所有服务的网络设置为手工绑定并建议关闭NetworkManager服务
#下面的这个配置要在所有的C/S端都进程（保证通过主机名可达即可）
[root@localhost ~]# cat >> /etc/hosts <<eof
192.168.139.101 S_Server_name
192.168.139.102 c_node1_name
192.168.139.103 c_node2_name
eof

启动：
[root@localhost ~]# service luci start  #根据其启动时提示的URL访问其web页面
[root@localhost ~]# service ricci start
```
#### Luci设置页面
  ![png](Images/URL1.png)
  ![png](Images/URL2.png)
  ![png](Images/URL3.png)
  ![png](Images/URL4.png)
  ![png](Images/URL5.png)

#### 创建完之后
```bash
[root@localhost ~]# cman_tool status    #查看状态
Version: 6.2.0
Config Version: 35  #集群配置文件版本号
Cluster Name: mycluster   #集群名称
Cluster Id: 56756
Cluster Member: Yes
Cluster Generation: 2764
Membership state: Cluster-Member
Nodes: 4   #集群节点数
Expected votes: 6   #期望的投票数
Quorum device votes: 2   #表决磁盘投票值
Total votes: 6   #集群中所有投票值大小
Quorum: 4 #集群法定投票值，低于这个值，集群将停止服务
Active subsystems: 9 
Flags: Dirty 
Ports Bound: 0 177  
Node name: web1
Node ID: 4  #本节点在集群中的ID号
Multicast addresses: 239.192.221.146 #集群广播地址 
Node addresses: 192.168.12.230 #本节点对应的IP地址

#查看clvm服务是否启动（启动）
[root@localhost ~]# service clvmd status

#balabala....
[root@localhost ~]# .............创建 pv vg (好像没有lv)

#格式化：（gfs）集群的文件系统
[root@localhost ~]# mkfs.gfs2 -p lock_dlm -t cluster_f0:XXX -j 2    /dev/vg01/<lv名，LV在此时创建>

  #lock_dlm   指定使用分布式的锁协议
  #cluster_f0 是集群名称（luci上是什么，它就是什么）
  #XXX        是标签，随便写
  #-j 2       允许几个节点同时对此设备进行操作（gfs2_jadd -j N /dev/xxxx   对指定设备更改其节点并发限制）

mount 。。。。

#其他的主机也mount，能互相看到对方的操作
```
