### 备忘
```txt
分布式复制块设备"DRBD"，是基于软件的，无共享，复制的存储解决方案，可简单将其理解为是内核中提供某种功能的代码
它在服务器之间对块设备（硬盘，分区，逻辑卷等）进行镜像。DRBD全称：Distributed ReplicatedBlock Device 分布式块设备
DRBD由内核模块和相关脚本构成，用以构建高可用集群。其在内核发送数据的存储请求的同时兵分两路经网络设备将数据镜像到其他节点
其实现方式是通过网络镜像整个设备。可看作一种网络RAID ( 允许在远程机器建立本地块设备的实时的镜像 ) 
在Linux内核的2.6.3+版本之后才开始在内核中支持DRBD，若在此版本之前使用的的话需要重新编译内核或安装第三方做的相应内核模块
通常情况下，节点间使用DRBD镜像的设备仅有一个可以被执行写操作，而另一个不能写（仅在故障时其他节点可提升为主）
若期望将其多个节点可同时被读写则需要用到分布式锁管理器，即双主模型的实现...
由DRBD组成的向上提供服务的设备名为：/dev/drbd#，其中主设备编号为147，次设备编号从0开始递增...
在某些场景中甚至可以把DRBD转换为HA的资源以完成资源故障后的的自动转换!...
-------------------------------------------------------------------------------------------------------------
工作流程：
    1 DRBD Primary: 负责接收数据，把数据写到本地磁盘**并发送**给另一台主机： DRBD Secondary
    2 DRBD Secondary: 主机将数据存到自己的磁盘（DRBD的Node之间的数据同步是在磁盘上按位对齐的）
    3 DRBD 通常由两个节点构成: 与HA集群类似也有主/备之分
    4 在带有主要设备的节点上，应用和系统可运行和访问DRBD设备（/dev/drbd*）

支持的底层设备：
    DRBD需构建在底层设备之上，然后构建出块设备。对用户来说DRBD设备就像是物理磁盘，可在其内创建文件系统。  
    DRBD所支持的底层设备有以下这些：  
        磁盘或是磁盘的分区  
        soft raid设备  
        LVM的逻辑卷  
        EVMS（Enterprise Volume Management System，企业卷管理系统）的卷  
        其他任何的块设备  

DRBD的三种块复制方式（工作模式）：
    A - 异步复制协议：
        一旦本地磁盘写入已完成且数据包已在发送队列中则写被认为是完成的  
        在一个节点发生故障时可能发生丢失，因为被写入到远程节点上的数据可能仍在发送队列  
        尽管在故障转移节点上的数据是一致的但没有及时更新  
        通常用于地理上分开的节点（本地写成功后立即返回，数据放在发送buffer中，可能丢失） 
        
    B - 内存同步（半同步）复制协议：
        一旦本地磁盘写入完成且复制数据包达到了对等节点则认为写在主节点上被认为是完成的  
        数据丢失可能发生在参加的两个节点同时故障的情况，因为在传输中的数据可能不会被提交到磁盘  
        如果双机掉电，数据可能丢失
        
    C - 同步复制协议：
        只有在本地和远程节点的磁盘均确认了写操作完成时写才被认为完成。没有任何数据丢失！  
        所以这是一个群集节点的流行模式，但I/O吞吐量依赖于网络带宽  
        一般使用协议C，但选择C协议将影响流量，从而影响网络时延  
        本地和对方写成功确认后返回。若双机掉电或磁盘同时损坏则数据可能丢失  
-------------------------------------------------------------------------------------------------------------
DRBD的配置工具：
    1.drbdadm：       高级管理工具，管理/etc/drbd.conf，向drbdsetup和drbdmeta发送指令
    2.drbdsetup：     配置装载进kernel的DRBD模块，平时很少用
    3.drbdmeta：      管理DRBD的META"元"数据结构，平时很少用

主配置文件：
    为了管理的便捷性通常会将些配置文件分多个部分，但都保存至/etc/drbd.d目录  
    主配置文件中仅使用"include"指令将这些配置文件片断整合  
    通常/etc/drbd.d中的文件为global_common.conf和所有以.res结尾的文件  
    其中：  
        1. global_common.conf中主要定义global段和common段  
        2. 每个.res文件用于定义一个资源  
    
    参考：http://www.cnblogs.com/bluevitality/p/6513763.html  
```
#### 配置步骤
```txt
1. 安装drbd  
2. 配置资源文件（定义资料名称，磁盘，节点信息，同步限制等）  
3. 将drbd加入到系统服务chkconfig --add drbd   
4. 初始化资源组 drbdadm create-md resource_name  
5. 启动服务 service drbd start  
6. 设置primary主机并同步数据  
7. 分区、格式化/dev/drbd\*  
8. 一个节点进行挂载  
9. 查看状态  
```
#### 单主模式：
在单主模式下任何资源在任何特定的时间，集群中只存在一个主节点。  
正因为这样在集群中只能有一个节点可随时操作数据，其可用在任何的文件系统上（EXT3、EXT4、XFS...）  
部署DRBD单主节点模式可保证集群的高可用性（fail-over遇故障转移的能力）  
 
#### 双主模式：
这是DRBD8.0之后的新特性  
在双主模式下任何资源在任何特定的时间，集群中都存在两个主节点。  
由于双方数据存在并发可能性因此需一个共享的集群文件系统，利用分布式的锁机制进行管理，如GFS和OCFS2。  
部署双主模式时，DRBD是负载均衡的集群，这就需要从两个并发的主节点中选取一个首选的访问数据。  
这种模式默认是禁用的，如果要是用的话必须在配置文件中进行声明。  

## 部署流程
```bash
#在两台主机之间配置host文件将名字指向对方：
cat /etc/hosts
10.0.0.7 data-1.localdomain                     #建议增加去往此网段的路由到指定出接口
10.0.0.8 data-2.localdomain                     #建议增加去往此网段的路由到指定出接口

parted /dev/sda mklabel gpt                     #在各Node节点内均创建分区（或磁盘设备）
parted /dev/sda mkpart logical ext3 20GB 20GB   #数据区
partprobe
partx -a /dev/sda                               #重读分区

#软件安装
service iptables stop && setenforce 0
yum -y install gcc kernel-devel kernel-headers flex
export LC_ALL=C
wget http://oss.linbit.com/drbd/8.4/drbd-8.4.1.tar.gz
tar xzf drbd-8.4.1.tar.gz
cd drbd-8.4.1
./configure --prefix=/usr/local/drbd --with-km --with-heartbeat --sysconfdir=/etc/drbd     
# --with-km 激活内核模块 
# --with-heartbeat 激活heartbeat相关配置
# --with-heartbeat 安装完成后会在/usr/local/drbd/etc/ha.d/resource.d生成drbddisk和drbdupper文件
# 把这两个文件复制到/usr/local/heartbeat/etc/ha.d/resource.d目录
# 命令cp -R /usr/local/drbd/etc/ha.d/resource.d/* /etc/ha.d/resource.d
make KDIR=/usr/src/kernels/$(uname -r)/
# KDIR=指定内核源码路径，依实际情况设置（查内核路径：ls -l /usr/src/kernels/$(uname -r)/）
make install 

mkdir -p /usr/local/drbd/var/run/drbd  
cp /usr/local/drbd/etc/rc.d/init.d/drbd /etc/rc.d/init.d  
chkconfig --add drbd  && chkconfig drbd on    
cd drbd
#安装drbd模块
make clean
make KDIR=/usr/src/kernels/2.6.32-220.17.1.el6.x86_64/  
cp drbd.ko /lib/modules/`uname -r`/kernel/lib/  
depmod
modprobe drbd               #载入模块（模块路径大致为：/lib/modules/3.10.0-693.el7.x86_64/extra/drbd84/drbd.ko）
lsmod | grep -i drbd        #检查是否装载DRBD模块

#编辑配置文件 Example 
[root@node1 ~]# cat /etc/drbd.conf                      #仅提供了其他配置文件的include功能
include "drbd.d/global_common.conf";                    #全局及公共的配置
include "drbd.d/*.res";                                 #定义DRBD设备
[root@node1 ~]# vim /etc/drbd.d/global_common.conf      #请参考本路径下的conf文件夹...
[root@node1 ~]# vim /etc/drbd.d/r0.res                  #请参考本路径下的conf文件夹...
[root@node1 ~]# scp -r /etc/drbd* root@node2:/etc/      #注意! 在DRBD的各节点之间其配置文件都要保持一致

dd if=/dev/zero of=/dev/sda{1..2} bs=1M count=100       #将一些数据放入需同步的设备中以防止create-md时出错
sync

drbdadm dreate-md Mysqls  #在各节点执行，对配置文件指定的资源初始化（创建DRBD元数据信息，管理命令：drbdadm --help）
drdbadm attach all        #附加到备份设置。这步将drbd资源和后端设备连接
drbdadm <up/down> all     #启动DRBD，或指定资源名进行启动
/etc/init.d/drbd start    #在各节点执行，启动服务

#注：以上每个步骤都需在主备服务器上进行操作！( 使用"scp" )

#查看DRBD信息：
cat /proc/drbd
version: 8.3.11 (api:88/proto:86-96) 
GIT-hash: 0de839cee13a4160eed6037c4bddd066645e23c5 build by root@drbd2.localdomain, 2011-07-08  
11:10:20 
1: cs:Connected ro:Secondary/Primary ds:UpToDate/UpToDate C r----  #注 ro:Secondary/Primary <-> ro:自身/对端角色
    ns:0 nr:32 dw:32 dr:0 al:0 bm:1 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0 
 
#cs:    连接状态！可能出现的有Connected,WFC,Stanalone,SyncSource 
#ro:    角色！ 正常会出现主辅，不正常的会现unkown. 
#ds:    同步更新的状态！ 正常的话是UpToDate/UpToDate,正在更新UpToDate/Inconsistent
#ns:    network send 
#nr:    network receive
#dr:    disk read
#pe:    pending(waiting forack)

#在特定的Node执行如下使其成为指定资源的主（默认各节点启动时都处于secondary，需手工将其设成primary才能正常被挂载工作）
drbdadm  --  --overwrite-data-of-peer  primary  --force <资源名>    #覆盖对端数据：--overwrite-data-of-peer
 
#在主节点格式化并挂载：（mount只能在Primary端使用，其他的Node节点仅提供镜像功能）
#只需将数据写入'/dData'即自动的同步到backupNode的/dev/sda2（仅需挂载逻辑设备，不挂载其下层的分区而由DRBD后台挂载用）
mkfs.ext4 /dev/drbd1
mount /dev/drbd1 /dData

-------------------------------------------------------------------------------------------------------------
#主备切换：

#首先在主上先将设备卸载，同时将主降为备：
umount /dev/drbd1
drbdadm secondary <资源名>  
 
#然后登录备，将备升为主，同时挂载/dev/drbd1到/dData。最后进入/dData就可看到之前在另一host写入的数据，若没有则同步失败
drbdadm primary <资源名>
mount /dev/drbd1 /dData/ 
 
#查看节点的角色：
drbdadm role <资源名>

#一个DRBD设备（即/dev/drbdX）叫做一个"资源"
#里面包含DRBD设备的主备节点的ip信息，底层存储设备名称及设备大小，meta信息存放方式，drbd对外提供的设备名等...
```
