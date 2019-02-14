#### 实验环境
```txt
                                  corosync                    corosync
                                     ↓                           ↓ 
                                  [Node1]    <==========>     [Node2]
                                     ↑                           ↑
                                  Pacemaker                   Pacemaker
```
#### CRMSH 下的帮助信息 ...
```bash
[root@localhost ~]# crm_verify -V -L      #检查并显示当前集群的配置是否存在问题
[root@localhost ~]# crm
crm(live)# help                           #进入SHELL后输入help可进入类似于Less命令的翻页模式查看帮助
Help overview for crmsh                   #命令可用TAB键补全

Available topics:

        Overview       Help overview for crmsh
        Topics         Available topics
        Description    Program description
        CommandLine    Command line options
        Introduction   Introduction
        Interface      User interface
        Completion     Tab completion
        Shorthand      Shorthand syntax
        Features       Features
        Shadows        Shadow CIB usage
        Checks         Configuration semantic checks
        Templates      Configuration templates
        Testing        Resource testing
        Security       Access Control Lists (ACL)
        Resourcesets   Syntax: Resource sets
        AttributeListReferences Syntax: Attribute list references
        AttributeReferences Syntax: Attribute references
        RuleExpressions Syntax: Rule expressions
        Reference      Command reference

Available commands:

        cd             Navigate the level structure
        help           Show help (help topics for list of topics)
        ls             List levels and commands
        quit           Exit the interactive shell
        report         Create cluster status report
        status         Cluster status
        up             Go back to previous level
        verify         Verify cluster status

        assist/        Configuration assistant
                template       Create template for primitives
                weak-bond      Create a weak bond between resources

        cib/           CIB shadow management                                     #
                cibstatus      CIB status management and editing                 #cib的子命令
                commit         Copy a shadow CIB to the cluster                  #
                delete         Delete a shadow CIB                               #
                diff           Diff between the shadow CIB and the live CIB      #
                import         Import a CIB or PE input file to a shadow         #
                list           List all shadow CIBs                              #
                new            Create a new shadow CIB                           #
                reset          Copy live cib to a shadow CIB                     #
                use            Change working CIB                                #
                                                                                 #
        cibstatus/     CIB status management and editing
                load           Load the CIB status section                       #cibstatus的子命令
                node           Change node status                                #
                op             Edit outcome of a resource operation              #
                origin         Display origin of the CIB status section          #
                quorum         Set the quorum                                    #
                run            Run policy engine                                 #
                save           Save the CIB status section                       #
                show           Show CIB status section                           #
                simulate       Simulate cluster transition                       #
                ticket         Manage tickets                                    #

        cluster/       Cluster setup and management
                add            Add a new node to the cluster                     #....
                copy           Copy file to other cluster nodes                  #
                diff           Diff file across cluster                          #
                geo_init       Configure cluster as geo cluster                  #
:
```
#### CRM commands Example
```txt
crm(live)# status           #查看当前集群状态
Stack: corosync             #在 corosync 下（V2版默认）则Pacemaker需作为一个独立的服务运行....
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Wed Dec 20 22:41:07 2017
Last change: Wed Dec 20 21:59:03 2017 by hacluster via crmd on node1

2 nodes configured
0 resources configured

Online: [ node1 node2 ]

No resources

crm(live)# configure show       #查看集群配置信息（配置信息在底层是XML格式，使用configure show xml 可查看）
node 3232235523: node1          #指明了当前集群有几个节点
node 3232235524: node2          #指明了当前集群有几个节点
property cib-bootstrap-options: \                   #指明了集群的全局属性（基本工作特性）
        stonith-enabled=false \                     #
        have-watchdog=false \                       #
        dc-version=1.1.16-12.el7_4.5-94ff4df \      #
        cluster-infrastructure=corosync             #
        
crm(live)#  configure       #也可进入命令的对应子命令模式执行相关操作
crm(live)configure# show
node 3232235523: node1
node 3232235524: node2
property cib-bootstrap-options: \
        stonith-enabled=false \
        have-watchdog=false \
        dc-version=1.1.16-12.el7_4.5-94ff4df \
        cluster-infrastructure=corosync
        
[root@localhost ~]# crm configure show  #也可以直接在BASH命令行一次性写全命令...
node 3232235523: node1
node 3232235524: node2
property cib-bootstrap-options: \
        stonith-enabled=false \
        have-watchdog=false \
        dc-version=1.1.16-12.el7_4.5-94ff4df \
        cluster-infrastructure=corosync
        
        
[root@localhost ~]# crm
crm(live)# configure
crm(live)configure# property   #进入configure接口后输入property（配置模式）并连敲2下TAB将显示所有可编辑的全局属性
batch-limit=                   enable-startup-probes=      node-health-strategy=       startup-fencing= 
cluster-delay=                 have-watchdog=              node-health-yellow=         stonith-action= 
cluster-ipc-limit=             is-managed-default=         notification-agent=         stonith-enabled= 
cluster-recheck-interval=      load-threshold=             notification-recipient=     stonith-timeout= 
concurrent-fencing=            maintenance-mode=           pe-error-series-max=        stonith-watchdog-timeout= 
crmd-transition-delay=         migration-limit=            pe-input-series-max=        stop-all-resources= 
dc-deadtime=                   no-quorum-policy=           pe-warn-series-max=         stop-orphan-actions= 
default-action-timeout=        node-action-limit=          placement-strategy=         stop-orphan-resources= 
default-resource-stickiness=   node-health-base=           remove-after-stop=          symmetric-cluster= 
election-timeout=              node-health-green=          shutdown-escalation=           
enable-acl=                    node-health-red=            start-failure-is-fatal= 

crm(live)configure# property  stonith-enabled=  #输入stonith-enabled后连敲2下TAB会提示其值类型为布尔值（默认True）
stonith-enabled (boolean, [true]): 
    Failed nodes are STONITH'd  
    
crm(live)configure# verify                          #检查CIB数据库中有无语法错误，若无将不提示任何信息
crm(live)configure# property stonith-enabled=false  #禁用stonith设备（其可关闭电源并响应软件命令）若不禁用则集群无法正常运行
crm(live)configure# show 
node 3232235523: node1
node 3232235524: node2
property cib-bootstrap-options: \
        stonith-enabled=false \                     #可看到stonith-enabled=false配置信息已经被写入CIB
        have-watchdog=false \
        dc-version=1.1.16-12.el7_4.5-94ff4df \
        cluster-infrastructure=corosync
        
crm(live)configure# commit                          #将修改后的配置提交使其立即生效（否则配置信息仅保存在内存）
crm(live)configure# cd ..
crm(live)# node
crm(live)node# help                                 #查看node的子命令
Node management
Node management and status commands.
Commands:
        attribute      Manage attributes
        clearstate     Clear node state             #常用，清理当前node节点的状态信息
        delete         Delete node                  #用于删除一个节点
        fence          Fence node   
        maintenance    Put node into maintenance mode
        online         Set node online              #常用，使当前节点处于online状态（使用"crm status"查看集群状态）
        ready          Put node into ready mode
        server         Show node hostname or server address
        show           Show node                    #常用，显示所有的node节点：show node
        standby        Put node into standby        #常用，将当前节点设置为备用模式（使用"crm status"查看集群状态）
        status         Show nodes' status as XML    #查看Node节点的信息
        status-attr    Manage status attributes
        utilization    Manage utilization attributes

        cd             Navigate the level structure
        help           Show help (help topics for list of topics)
        ls             List levels and commands     #显示所有可用的节点
        quit           Exit the interactive shell
        up             Go back to previous level
        
crm(live)node# show
node1(3232235523): normal
node2(3232235524): normal
crm(live)node# cd ..
crm(live)# resource
crm(live)resource# help
Resource management
At this level resources may be managed.
All (or almost all) commands are implemented with the CRM tools
such as crm_resource(8).
Commands:
        ban            Ban a resource from a node
        cleanup        Cleanup resource status              #清理资状态
        clear          Clear any relocation constraint
        constraints    Show constraints affecting a resource
        demote         Demote a master-slave resource
        failcount      Manage failcounts                    #管理错误次数统计次数
        locate         Show the location of resources
        maintenance    Enable/disable per-resource maintenance mode
        manage         Put a resource into managed mode     #把资源重新定义为可被管理的状态
        meta           Manage a meta attribute
        move           Move a resource to another node      #手动迁移资源到其他节点（旧版本为：migrate）
        operations     Show active resource operations
        param          Manage a parameter of a resource
        promote        Promote a master-slave resource
        refresh        Refresh CIB from the LRM status
        reprobe        Probe for resources not started by the CRM
        restart        Restart resources                    #重启一个资源
        scores         Display resource scores  
        secret         Manage sensitive parameters  
        start          Start resources                      #启用一个资源
        status         Show status of resources             #资源的状态
        stop           Stop resources                       #关闭一个资源
        trace          Start RA tracing
        unmanage       Put a resource into unmanaged mode   #使资源处于不被管理的状态，使其不被集群所自动调度
        untrace        Stop RA tracing
        utilization    Manage a utilization attribute

        cd             Navigate the level structure
        help           Show help (help topics for list of topics)
        ls             List levels and commands             #
        quit           Exit the interactive shell
        up             Go back to previous level
crm(live)resource# cd ..
crm(live)# ra
crm(live)ra# help       #资源代理（查看资源代理的类别，参数等...）
Resource Agents (RA) lists and documentation
This level contains commands which show various information about
the installed resource agents. It is available both at the top
level and at the configure level.
Commands:
        classes        List classes and providers   #显示共有多少个资源类别的支持，如：LSB OCF SERVICE STONITH...
        info           Show meta data for a RA      #重要~
        list           List RA for a class (and provider)
        providers      Show providers for a RA and a class
        validate       Validate parameters for RA

        cd             Navigate the level structure
        help           Show help (help topics for list of topics)
        ls             List levels and commands
        quit           Exit the interactive shell
        up             Go back to previous level
crm(live)ra# list lsb           #查看lsb中有哪些资源代理可用
netconsole  network     
crm(live)ra# list ocf           #查看ocf中有哪些资源代理可用
CTDB           ClusterMon         Delay         \Dummy              Filesystem    HealthCPU        HealthSMART
IPaddr         IPaddr2            IPsrcaddr     \LVM                MailTo        NodeUtilization  NovaEvacuate
Route          SendArp            Squid         \Stateful           SysInfo       SystemHealth     VirtualDomain
Xinetd         apache             attribute     \clvm               conntrackd    controld         db2
dhcpd          docker             ethmonitor    \exportfs           galera        garbd            iSCSILogicalUnit
iSCSITarget    iface-vlan         mysql         \nagios             named         nfsnotify        nfsserver
nginx          nova-compute-wait  oraasm        \oracle             oralsnr       pgsql            ping
pingd          portblock          postfix       \rabbitmq-cluster   redis         remote           rsyncd
slapd          symlink            tomcat  
crm(live)ra# list service       #service就是LSB而已~!
......（略）
crm(live)ra# info               #查看某一个资源代理自己的帮助信息(注：RA的systemd脚本调的资源要在各节点enable后使用...)
Display all 285 possibilities? (y or n)
lsb:netconsole                           service:microcode                        systemd:exim 
lsb:network                              service:netconsole                       systemd:firewalld 
ocf:heartbeat:CTDB                       service:network                          systemd:getty@tty1 
ocf:heartbeat:Delay                      service:nfs-config                       systemd:gssproxy 
ocf:heartbeat:Dummy                      service:nfs-idmapd                       systemd:ip6tables 
ocf:heartbeat:Filesystem                 service:nfs-mountd                       systemd:iptables 
ocf:heartbeat:IPaddr                     service:nfs-secure-server                systemd:irqbalance 
ocf:heartbeat:IPaddr2                    service:nfs-server                       systemd:kmod-static-nodes 
ocf:heartbeat:IPsrcaddr                  service:nfs-utils                        systemd:ldconfig 
ocf:heartbeat:LVM                        service:pacemaker                        systemd:libvirtd 
crm(live)ra# help info      #info的帮助信息
Show meta data for a RA

Show the meta-data of a resource agent type. This is where users
can find information on how to use a resource agent. It is also
possible to get information from some programs: pengine,
crmd, cib, and stonithd. Just specify the program name
instead of an RA.

Usage:

info [<class>:[<provider>:]]<type>
info <type> <class> [<provider>] (obsolete)

Example:

info apache
info ocf:pacemaker:Dummy    #INFO 哪个资源代理类别：哪个provider:哪个资源代理 ---> 查看执行的详细的使用帮助信息
info stonith:ipmilan
info pengine

crm(live)ra# info ocf:heartbeat:IPaddr  #Demo
Manages virtual IPv4 and IPv6 addresses (Linux specific version) (ocf:heartbeat:IPaddr)

This Linux-specific resource manages IP alias IP addresses.
It can add an IP alias, or remove one.
In addition, it can implement Cluster Alias IP functionality
if invoked as a clone resource.

If used as a clone, you should explicitly set clone-node-max >= 2,
and/or clone-max < number of nodes. In case of node failure,
clone instances need to be re-allocated on surviving nodes.
This would not be possible if there is already an instance on those nodes,
and clone-node-max=1 (which is the default).

Parameters (*: required, []: default):

ip* (string): IPv4 or IPv6 address
    The IPv4 (dotted quad notation) or IPv6 address (colon hexadecimal notation)
    example IPv4 "192.168.1.1".
    example IPv6 "2001:db8:DC28:0:0:FC57:D4C8:1FFF".

nic (string): Network interface
    The base network interface on which the IP address will be brought
    online. 
    If left empty, the script will try and determine this from the
    routing table.
    
    Do NOT specify an alias interface in the form eth0:1 or anything here;
    rather, specify the base interface only.
    If you want a label, see the iflabel parameter.
    
    Prerequisite:
    
    There must be at least one static IP address, which is not managed by
    the cluster, assigned to the network interface.
......................（略）
```
#### 通过 CRM 进行资源的配置（定义集群资源）的说明 Demo
```bash
[root@localhost ~]# crm configure 
crm(live)configure# help group                      #定义组资源
crm(live)configure# help clone                      #定义克隆资源
crm(live)configure# help primitive                  #定义基本资源（常用）
crm(live)configure# help ms                         #定义主从资源
crm(live)configure# help location                   #定义位置约束
crm(live)configure# help order                      #定义顺序约束
crm(live)configure# help colocation                 #定义排列约束

crm(live)configure# help primitive
Define a resource

The primitive command describes a resource. It may be referenced
only once in group, clone, or master-slave objects. If it's not
referenced, then it is placed as a single resource in the CIB.

Operations may be specified anonymously, as a group or by reference:

* "Anonymous", as a list of op specifications. Use this
  method if you don't need to reference the set of operations
  elsewhere. This is the most common way to define operations.

* If reusing operation sets is desired, use the operations keyword
  along with an id to give the operations set a name. Use the
  operations keyword and an id-ref value set to the id of another
  operations set, to apply the same set of operations to this
  primitive.

Operation attributes which are not recognized are saved as
instance attributes of that operation. A typical example is
OCF_CHECK_LEVEL.

For multistate resources, roles are specified as role=<role>.

A template may be defined for resources which are of the same
type and which share most of the configuration. See
rsc_template for more information.

Attributes containing time values, such as the interval attribute on
operations, are configured either as a plain number, which is
interpreted as a time in seconds, or using one of the following
suffixes:

* s, sec - time in seconds (same as no suffix)
* ms, msec - time in milliseconds
* us, usec - time in microseconds
* m, min - time in minutes
* h, hr - time in hours

Usage:

primitive <rsc> {[<class>:[<provider>:]]<type>|@<template>} #!...
  [description=<description>]
  [[params] attr_list]
  [meta attr_list]
  [utilization attr_list]
  [operations id_spec]
    [op op_type [<attribute>=<value>...] ...]

attr_list :: [$id=<id>] [<score>:] [rule...]
             <attr>=<val> [<attr>=<val>...]] | $id-ref=<id>
id_spec :: $id=<id> | $id-ref=<id>
op_type :: start | stop | monitor

Example:

primitive apcfence stonith:apcsmart \
  params ttydev=/dev/ttyS0 hostlist="node1 node2" \
  op start timeout=60s \
  op monitor interval=30m timeout=60s

#定义一个资源...
primitive www8 apache \  #www8：资源名称，apache：资源代理， params：传递的参数，operations：额外的操作（如监控）
  params configfile=/etc/apache/www8.conf \
  operations $id-ref=apache_ops

primitive db0 mysql \
  params config=/etc/mysql/db0.conf \
  op monitor interval=60s \
  op monitor interval=300s OCF_CHECK_LEVEL=10

primitive r0 ocf:linbit:drbd \
  params drbd_resource=r0 \
  op monitor role=Master interval=60s \
  op monitor role=Slave interval=300s

primitive xen0 @vm_scheme1 xmfile=/etc/xen/vm/xen0

primitive mySpecialRsc Special \
  params 3: rule #uname eq node1 interface=eth1 \
  params 2: rule #uname eq node2 interface=eth2 port=8888 \
  params 1: interface=eth0 port=9999
```
#### 通过 CRM 进行集群的资源配置
```bash
#资源的定义样例：primitive <资源ID> <class:provider:ra params paraml=value1 param2=value2 op op1=.. op2...

#定义IP地址作为集群资源（资源名称为："web_ip"）：
[root@node1 ~]# crm configure
crm(live)configure# primitive web_ip ocf:heartbeat:IPaddr params ip=172.16.100.100 \
nic=eno16777736 cidr_netmask=16
crm(live)configure# verify                              #验证配置
crm(live)configure# commit                              #提交配置使生效
[root@node1 ~]# ip addr show eno16777736 | grep inet    #在定义资源的本节点可查看到上面定义的web_ip资源正在工作...
    inet 192.168.0.3/24 brd 192.168.0.255 scope global dynamic eno16777736
    inet 172.16.100.100/16 scope global eno16777736
    inet6 fe80::20c:29ff:fecd:c3b7/64 scope link 
[root@node2 ~]# crm status                              #在另一个node2节点查看配置的集群资源
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Wed Dec 20 23:40:32 2017
Last change: Wed Dec 20 23:40:05 2017 by root via cibadmin on node1
2 nodes configured
1 resource configured
Online: [ node1 node2 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr):   Started node1        #资源web_ip启动在了node1节点上
[root@node1 ~]# crm node standby                        #修改之前配置web_ip资源的node1节点为备用模式
[root@node1 ~]# crm status
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Wed Dec 20 23:45:15 2017
Last change: Wed Dec 20 23:45:12 2017 by root via crm_attribute on node1
2 nodes configured
1 resource configured
Node node1: standby
Online: [ node2 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr):   Stopped              #资源停止了
[root@node2 ~]#  ip addr show eno16777736 | grep inet   #在Node2节点上执行ip show可看到其已经取得了web_ip资源
    inet 192.168.0.4/24 brd 192.168.0.255 scope global dynamic eno16777736
    inet 172.16.100.100/16 scope global eno16777736
    inet6 fe80::20c:29ff:fead:abae/64 scope link 
[root@node1 ~]# crm node online                         #使node1节点重新上线                
[root@node1 ~]# crm status                              #
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Wed Dec 20 23:47:54 2017
Last change: Wed Dec 20 23:47:33 2017 by root via crm_attribute on node2
2 nodes configured
1 resource configured
Node node1: standby
Online: [ node2 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr):  Started node2         #资源仍在node2上，并没有自动的迁回
[root@node2 ~]# crm node standby                        #关闭节点2
[root@node1 ~]# crm node online                         #节点1启用
[root@node1 ~]# crm status                              
Stack: corosync
#下面的提示是指集群为防止脑裂需要在偶数个节点设置仲裁机制（法定票数）
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum  
Last updated: Wed Dec 20 23:51:14 2017
Last change: Wed Dec 20 23:51:10 2017 by root via crm_attribute on node1
2 nodes configured
1 resource configured
Node node2: standby
Online: [ node1 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr):   Stopped              #资源没有被仅剩的Node1收回....
[root@node1 ~]# crm
crm(live)# configure
crm(live)configure# property no-quorum-policy=ignore    #使得集群忽略脑裂的仲裁机制（默认开启情况下脑裂时不处理资源）
#                                       注:  quorum 参数：
#                                            stop
#                                            ignore
#                                            freeze
#                                            suicide
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# show                                #查看配置，可使用"edit"命令直接编辑CIB的xml配置文档
node 3232235523: node1 \
        attributes standby=off
node 3232235524: node2 \
        attributes standby=on
primitive web_ip IPaddr \
        params ip=172.16.100.100 nic=eno16777736 cidr_netmask=16
property cib-bootstrap-options: \
        stonith-enabled=false \
        have-watchdog=false \
        dc-version=1.1.16-12.el7_4.5-94ff4df \
        cluster-infrastructure=corosync \
        no-quorum-policy=ignore
[root@node1 ~]# crm status                      #设置仲裁策略为ignore后会发现web-ip资源又在脑裂的节点上启动起来了
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Wed Dec 20 23:57:51 2017
Last change: Wed Dec 20 23:55:15 2017 by root via cibadmin on node1
2 nodes configured
1 resource configured
Node node2: standby
Online: [ node1 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr):   Started node1
[root@node1 ~]# crm resource status             #查看资源状态
 web_ip (ocf::heartbeat:IPaddr):   Started

 
# 总结：
# 配置2个节点的集群时需要设置以下两个CRM的全局属性：（若不设置的话HA是不会在其中一个节点下线以后自动进行节点迁移的）
#     property no-quorum-policy=ignore
#     property stonith-enabled=false
```
#### 定义WEB服务资源（需要确保服务不会开机自启并且其未被启动，因为其需要交由HA管理）
```bash
[root@node1 ~]# yum -y install httpd && systemctl disable httpd
[root@node2 ~]# yum -y install httpd && systemctl disable httpd
[root@node1 ~]# echo node1 > /var/www/html/index.html
[root@node2 ~]# echo node2 > /var/www/html/index.html

[root@node1 ~]# crm
crm(live)# configure
#crm(live)configure# primitive webserver lsb:httpd   #定义资源
crm(live)configure# primitive webser systemd:httpd
crm(live)configure# verify
WARNING: webser: default timeout 20s for start is smaller than the advised 100      #表示共享存储要定义?...
WARNING: webser: default timeout 20s for stop is smaller than the advised 100       #
crm(live)configure# commit
crm(live)configure# cd ..
crm(live)# status
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Thu Dec 21 00:47:05 2017
Last change: Thu Dec 21 00:42:51 2017 by root via cibadmin on node1
2 nodes configured
2 resources configured
Online: [ node1 node2 ]
Full list of resources:
  web_ip (ocf::heartbeat:IPaddr):  Started node2   #验证VIP在node2上
  webser (systemd:httpd):  Started node1           #验证APACHE在node1上
  
#注：两个资源不在同1个Node上是因为集群原则上尽可能的将资源分散到多个node运行....
```
#### 定义资源组及组资源拆分（将多个资源捆绑在一起使得在同一个Node上工作）
```bash
[root@node1 ~]# crm
crm(live)# configure
crm(live)configure# group WEB_RS_GROUP_1 web_ip webser               
INFO: modified location:cli-prefer-web_ip from web_ip to WEB_RS_GROUP_1
crm(live)configure# verify
crm(live)configure# commit

[root@localhost ~]# crm status
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Thu Dec 21 00:56:06 2017
Last change: Thu Dec 21 00:54:58 2017 by root via cibadmin on node1
2 nodes configured
2 resources configured
Online: [ node1 node2 ]
Full list of resources:
 Resource Group: WEB_RS_GROUP_1
     web_ip     (ocf::heartbeat:IPaddr):  Started node2        #两个资源捆绑在了一起
     webser     (systemd:httpd):   Started node2               #两个资源捆绑在了一起
[root@node2 ~]# curl 172.16.100.100         #验证
node2
[root@node2 ~]# crm node standby            #使node2下线，测试资源是否漂移到node1
[root@node2 ~]# crm status      
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Thu Dec 21 00:58:03 2017
Last change: Thu Dec 21 00:57:49 2017 by root via crm_attribute on node2
2 nodes configured
2 resources configured
Node node2: standby
Online: [ node1 ]
Full list of resources:
 Resource Group: WEB_RS_GROUP_1
     web_ip     (ocf::heartbeat:IPaddr): Started node1
     webser     (systemd:httpd):  Started node1
[root@node1 ~]# curl 127.0.0.1              #在node1上验证，木有问题
node1


使捆绑到同一组的多个资源拆开：
[root@node1 ~]# crm configure edit          #直接以VIM的方式打开CIB进行编辑
node 3232235523: node1 \
        attributes standby=off
node 3232235524: node2 \
        attributes standby=on
primitive web_ip IPaddr \
        params ip=172.16.100.100 nic=eno16777736 cidr_netmask=16 \
        meta target-role=Started
primitive webser systemd:httpd
group WEB_RS_GROUP_1 web_ip webser          #把这一行删除即可把资源组拆开~!!!...................
location cli-prefer-web_ip WEB_RS_GROUP_1 role=Started inf: node2
property cib-bootstrap-options: \
        stonith-enabled=false \
        have-watchdog=false \
        dc-version=1.1.16-12.el7_4.5-94ff4df \
        cluster-infrastructure=corosync \
        no-quorum-policy=ignore

#或者使用命令方式（由于正在运行，有可能删不掉）
[root@node1 ~]# crm configure delete WEB_RS_GROUP_1  
#由于正在运行，有可能删不掉的解决办法：
[root@node1 ~]# crm
crm(live)# resource stop webser             #先停服在删除
crm(live)# resource stop web_ip             #
crm(live)# configure delete WEB_RS_GROUP_1  #
```
#### 定义排列约束使得多个资源捆绑在一起使得在同一个Node上工作（类似于Group的方式）
```bash
[root@node1 ~]# crm
crm(live)# configure
crm(live)configure# colocation WEBSER_WITH_WEBIP inf: webser web_ip #inf表亲缘性为无穷大（也可用0~100的数）即其后的资源永远在一起
crm(live)configure# verify
crm(live)configure# commit
[root@node1 ~]# crm status
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Thu Dec 21 01:12:26 2017
Last change: Thu Dec 21 01:11:52 2017 by root via cibadmin on node1
2 nodes configured
2 resources configured
Node node2: standby
Online: [ node1 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr):    Started node1     #又在一起了
 webser (systemd:httpd):    Started node1             #又在一起了
```
#### 定义顺序约束（使得多个资源按顺序启动）
```bash
[root@node1 ~]# crm 
crm(live)# configure
crm(live)configure# order WEBIP_BEFORE_WEBSER Mandatory: web_ip webser  #Mandatory表示强制性使其后的资源按顺序启动
crm(live)configure# verify
crm(live)configure# commit

crm(live)configure#  show
node 3232235523: node1 \
        attributes standby=off
node 3232235524: node2 \
        attributes standby=on
primitive web_ip IPaddr \
        params ip=172.16.100.100 nic=eno16777736 cidr_netmask=16 \
        meta target-role=Started
primitive webser systemd:httpd \
        meta target-role=Started
order WEBIP_BEFORE_WEBSER Mandatory: web_ip webser      #在这里~
colocation WEBSER_WITH_WEBIP inf: webser web_ip
location cli-prefer-web_ip web_ip role=Started inf: node2
property cib-bootstrap-options: \
        stonith-enabled=false \
        have-watchdog=false \
        dc-version=1.1.16-12.el7_4.5-94ff4df \
        cluster-infrastructure=corosync \
        no-quorum-policy=ignore
```
#### 定义位置约束（定义资源与节点之间的粘性）
```bash
[root@node1 ~]# crm
crm(live)# configure
crm(live)configure# location WEBIP_ON_NODE1 web_ip 50: node2         #资源与节点之间的粘性值（倾向性）为50
crm(live)configure# verify
crm(live)configure# commit

#使用RULE规则来实现：
[root@node1 ~]# crm
crm(live)# configure
crm(live)configure# location HTTPD_ON_NODE1 webser rule #uname eq node2 #定义1个规则使资源与名为node2的节点间保持位置约束
#crm(live)configure# location HTTPD_ON_NODE1 webser rule 50: #uname eq node2  #也可对RULE指定倾向性分数，不指定则默认为0值
crm(live)configure# vrify
crm(live)configure# commit
crm(live)configure# show
node 3232235523: node1 \
        attributes standby=off
node 3232235524: node2 \
        attributes standby=on
primitive web_ip IPaddr \
        params ip=172.16.100.100 nic=eno16777736 cidr_netmask=16 \
        meta target-role=Started
primitive webser systemd:httpd \                                #
        meta target-role=Started                                #
location HTTPD_ON_NODE1 webser \                                # up / down 时根据倾向性漂移资源
        rule #uname eq node2                                    #
order WEBIP_BEFORE_WEBSER Mandatory: web_ip webser              #
location WEBIP_ON_NODE1 web_ip 50: node2                        #
colocation WEBSER_WITH_WEBIP inf: webser web_ip                 #
location cli-prefer-web_ip web_ip role=Started inf: node2       #
property cib-bootstrap-options: \                               #
        stonith-enabled=false \                                 #
        have-watchdog=false \                                   #
        dc-version=1.1.16-12.el7_4.5-94ff4df \                  #
        cluster-infrastructure=corosync \                       #
        no-quorum-policy=ignore                                 #

[root@node1 ~]# crm configure
crm(live)configure# property default-resource-stickiness=30     #设置资源默认情况下与其当前节点的倾向性（粘性）
crm(live)configure# vrify
crm(live)configure# commit
```
#### 手动进行资源在节点间的迁移
```bash
[root@node1 ~]# crm resource
crm(live)resource# move web_ip node2                            #将资源手动迁移至node2
INFO: Move constraint created for web_ip to node2
crm(live)resource# cd ..
crm(live)# status
Stack: corosync
Current DC: node1 (version 1.1.16-12.el7_4.5-94ff4df) - partition with quorum
Last updated: Thu Dec 21 00:17:35 2017
Last change: Thu Dec 21 00:17:08 2017 by root via crm_resource on node1
2 nodes configured
1 resource configured
Online: [ node1 node2 ]
Full list of resources:
 web_ip (ocf::heartbeat:IPaddr): Started node2
 
crm(live)# resource
crm(live)resource# stop web_ip                                  #停止资源
crm(live)resource# status web_ip        
resource web_ip is NOT running      
crm(live)resource# start web_ip                                 #启用资源
crm(live)resource# status web_ip
resource web_ip is running on: node2 
```
#### 配置 FileSystem 资源（共享存储）
```bash
[root@node1 ~]# crm configure
crm(live)configure# primitive WEB_NFS ocf:heartbeat:Filesystem \        #使用heartbeat的Filesystem模块?
params device="172.16.1.1:/web/htdocs" \                                #挂载设备
directory="/var/www/html" fstype="nfs" \                                #挂载点
op monitor interval=20s timeout=30s \                                   #开启监控
op start timeout=60s \                                                  #启动成功时
op stop timeout=60s                                                     #启动失败时
crm(live)configure# verify                       #可能会有警告，因为interval与timeout的值小于其建议的默认值...    
crm(live)configure# commit

crm(live)# configure
crm(live)configure# group WEB_RS_GROUP_1 web_ip WEB_NFS webser          #将NFS资源加入资源组
INFO: modified location:cli-prefer-web_ip from web_ip to WEB_RS_GROUP_1
crm(live)configure# verify
crm(live)configure# commit

crm(live)# resource start  WEB_RS_GROUP_1        #启动资源组

crm(live)# resource cleanup WEB_RS_GROUP_1       #若启动不成功则需先清理之前资源的状态信息再启动!（否则其认为是故障）
Cleaning up WEB_RS_GROUP_1 on node2, removing fail-count-web_ip
Cleaning up WEB_RS_GROUP_1 on node1, removing fail-count-web_ip
Waiting for 2 replies from the CRMd.. OK

crm(live)# resource start  WEB_RS_GROUP_1        #启动资源组
crm(live)# resource status  WEB_RS_GROUP_1       #查看资源组状态

#检查：在资源所在的Node使用mount命令查看....
```
#### 开启对资源监控使得可以根据资源的健康状态自动进行迁移
```bash
#默认情况下pacemaker只关心节点的高可用，至于服务是否down掉其默认不关心，因此可在定义集群资源时额外再定义监控的功能

[root@node1 ~]# crm configure       #op monitor interval=10s timeout=5s 即对此资源进行监控并且10s/次，超时为5s
crm(live)configure# primitive web_ip ocf:heartbeat:IPaddr params \
ip=172.16.100.100 nic=eno16777736 cidr_netmask=16 op monitor interval=10s timeout=20s
crm(live)configure# primitive webser systemd:httpd op monitor interval=10s timeout=20s
crm(live)configure# verify          #可能会有警告，因为interval与timeout的值小于其建议的默认值...    
crm(live)configure# commit

#此时若进行Killall httpd 的操作则ha将自动尝试进行资源的重启或迁移及运行 
#若被监控的资源属于一个捆绑的资源组，则此资源失效时其同组的资源均将进行迁移
```

