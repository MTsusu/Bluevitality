#### CLVM
```bash
[root@localhost ~]# yum -y install lvm2-cluster     #在集群中的所有节点安装
[root@localhost ~]# sed -Ei 's/(locking_type =).*/\13/g' /etc/lvm/lvm.conf  #使用内置的集群锁
[root@localhost ~]# lvmconf --enable-cluster        #同上 (命令行方式自动修改配置文件)
[root@localhost ~]# service clvmd start             #Centos7中无此daemon进程....?
```

#### GFS2
```bash
[root@localhost ~]# yum -y install gfs2-utils
[root@localhost ~]# gfs2_           #GFS2相关的工具
gfs2_convert          gfs2_edit             gfs2_grow             gfs2_jadd             gfs2_withdraw_helper
[root@localhost ~]# mkfs.gfs2 -h
Usage:
mkfs.gfs2 [options] <device> [size]

Create a gfs2 file system on a device. If a size, in blocks, is not specified, the whole device will be used.

Options:
 -b <size>                File system block size, in bytes
 -c <size>                Size of quota change file, in megabytes
 -D                       Enable debugging code
 -h                       Display this help, then exit
 -J <size>                Size of journals, in megabytes   #日志区域的空间大小，默认128MB
 -j <number>              Number of journals  #指定创建的日志区域数量（几个区域即支持几个客户端同时挂载，相当C端数量）
 -K                       Don‘t try to discard unused blocks
 -O                       Don‘t ask for confirmation
 -o <key>[=<value>][,..]  Specify extended options. See '-o help'.
 -p <name>                Name of the locking protocol #使用的锁协议：<lock_dlm|lock_none> 即 "分布式锁/不使用锁"
 -q                       Don‘t print anything
 -r <size>                Size of resource groups, in megabytes
 -t <name>                Name of the lock table  #指定锁表名称，即在集群内的若干分布式FS中使用的唯一的名字
 -V                       Display program version information, then exit
 
#指定2个客户使用的GFS2：
[root@localhost ~]# mkfs.gfs2 -j 2 -p lock_dlm  -t  <cluster_name:fs_name> /dev/sda
 
#列出集群FS相关的信息：
[root@localhost ~]# tunegfs2 -l /dev/sda

#向GFS2中添加一个日志区域（新增客户端，需要在已经挂载的节点上）：
[root@localhost ~]# gfs2_jadd -j 1 /dev/sda

#在使用lvm对逻辑卷扩展之后扩展GFS的逻辑边界：
[root@localhost ~]# gfs2_grow /dev/vg01/lv01
```
