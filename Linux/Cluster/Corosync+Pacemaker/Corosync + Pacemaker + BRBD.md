#### 备忘 （ 此 markdown 仅作流程参考!... ）
```txt
构建资源时，各资源使用的用户账号的UID/GID必须保持一致!（包括各个集群资源使用到的文件与目录的属主属组及权限）...

CRMSH 的部分子参数：
    clone-max:           在集群中最多能运行多少份克隆资源，默认和集群中的节点数相同
    clone-node-max：     每个节点上最多能运行多少份克隆资源，默认1
    notify：             当成功启动或关闭一份克隆资源，要不要通知给其它的克隆资源，可用值为false,true；默认true
    globally-unique:     是否为集群中各节点的克隆资源取一个全局唯一名称，用来描述不同的功能，默认true
    ordered：            克隆资源是否按顺序(order)启动，而非一起(parallel)启动,可用值为false,true；默认true
    interleave：         当对端的实例有了interleave，就可以改变克隆资源或主资源中的顺序约束
    master-max：         最多有多少份克隆资源可以被定义成主资源，默认1
    master-node-max：    每个节点上最多有多少份克隆资源可以被提升为主资源，默认1
```
#### 实验环境
```txt
                        corosync  drbd            corosync  drbd
                           ↘     ↙                 ↘     ↙
                            [Node1]    <========>    [Node2]
                               ↑                        ↑
                            Pacemaker                Pacemaker
```
#### 当集群节点为偶数或 2 个时执行如下操作关闭仲裁及 stonith
```bash
[root@node1 ~]# crm configure
crm(live)configure# property stonith-enable=false
crm(live)configure# property no-quorum-policy=ignore
crm(live)configure# rsc_defaults resource-stickiness=100    #资源对当前节点的默认粘性
crm(live)configure# verify
crm(live)configure# commit
```

#### 部署流程
```bash
[root@node1 ~]# crm ra
crm(live)ra# classes
lsb
ocf / heartbeat linbit pacemaker
service
stonith
crm(live)ra# list ocf linbit
drbd
crm(live)ra# meta ocf:linbit:drbd

#定义DRBD资源
crm(live)ra# cd configure
crm(live)configure# primitive mysqlstore2 ocf:linbit:drbd \ #使用DRBD官方提供的linbit（yum安装DRBD后即存在）
params drbd_resource=mystore1 \                         #此处的drbd_resource是在DRBD的配置文件中定义的资源名称
op monitor role=Master intrval=30s timeout=20s \        #若是主资源时...
op mointor role=Slave interval=60s timeout=20s \        #若是从资源时...
op start timeout=240s op stop timeout=100s              #启动时..

#定义主从资源
crm(live)configure# master ms_mysqlstore1 mysqlstore \  #定义主从资源"ms_mysqlstore1"：资源名称 mysqlstore
meta master-max=1 \                                     #一共有几个可以作为主资源
master-node-max=1 \                                     #每个节点上最多可以运行几份克隆
clone-max=2 \                                           #最多能克隆几份
clone-node-max=1 \                                      #每个节点最多可运行多少份克隆
notify="True"                                           #是否要通知
crm(live)configure# shiw
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# cd
crm(live)# node standby node1.ja.com                    #此时发现node2自动提升为主的
crm(live)# status
crm(live)# node online node1.ja.commit                  #让node1再上线，发现node1，是从的；node2还是主的

#为主节点定义文件系统资源
# crm configure
crm(live)configure# primitive WebFS ocf:heartbeat:Filesystem \
params device="/dev/drbd0" \                            #对应的设备
directory="/www" fstype="ext3"                          #挂载点
op monitor intrval=30s timeout=20s \                    #
op mointor interval=60s timeout=20s \                   #
crm(live)configure# colocation WebFS_on_MS_webdrbd \
inf: WebFS MS_Webdrbd:Master                            #定义WebFS必须跟MS_Webdrbd的Master角色在一起
crm(live)configure# order WebFS_after_MS_Webdrbd \
inf: MS_Webdrbd:promote WebFS:start                     #启动顺序，仅当MS_Webdrbd为promote状态时才进行WebFS挂载
crm(live)configure# verify
crm(live)configure# commit
```

#### 验证
```txt
查看集群中资源的运行状态：

crm status
============
Last updated: Fri Jun 17 06:26:03 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============
Online: [ node2.a.org node1.a.org ]
Master/Slave Set: MS_Webdrbd
Masters: [ node2.a.org ]
Slaves: [ node1.a.org ]
WebFS (ocf::heartbeat:Filesystem): Started node2.a.org

由上面的信息可以发现，此时WebFS运行的节点和drbd服务的Primary节点均为node2.a.org
我们在node2上复制一些文件至/www目录（挂载点），而后在故障故障转移后查看node1的/www目录下是否存在这些文件。

# cp /etc/rc./rc.sysinit /www

下面我们模拟node2节点故障，看此些资源可否正确转移至node1。

以下命令在Node2上执行：

# crm node standby
# crm status
============
Last updated: Fri Jun 17 06:27:03 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============
Node node2.a.org: standby
Online: [ node1.a.org ]
Master/Slave Set: MS_Webdrbd
Masters: [ node1.a.org ]
Stopped: [ webdrbd:0 ]
WebFS (ocf::heartbeat:Filesystem): Started node1.a.org

由上面的信息可以推断出，node2已转入standby模式，其drbd服务已经停止但故障转移已经完成，所有资源已经正常转移至node1。
在node1可以看到在node2作为primary节点时产生的保存至/www目录中的数据，在node1上均存在一份拷贝。

让node2重新上线：

# crm node online
[root@node2 ~]# crm status
============
Last updated: Fri Jun 17 06:30:05 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============
Online: [ node2.a.org node1.a.org ]
Master/Slave Set: MS_Webdrbd
Masters: [ node1.a.org ]
Slaves: [ node2.a.org ]
WebFS (ocf::heartbeat:Filesystem): Started node1.a.org
```
