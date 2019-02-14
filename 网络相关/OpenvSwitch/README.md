```txt
OpenvSwitch简称OVS，是虚拟交换软件，主要用于虚拟机VM环境
作为一个虚拟交换机，支持Xen/XenServer, KVM, and VirtualBox多种虚拟化技术。OpenvSwitch还支持多个物理机的分布式环境
在网络中换机和桥都是同一个概念，OVS实现了一个虚拟机的以太交换机，换句话说OVS也就是实现了一个以太桥
在OVS中给一个交换机或者说一个桥，用了一个专业的名词叫做：DataPath

OpenVSwitch 的核心组件
    ovsdb-server：
          轻量级的数据库，用于整个OVS的配置信息，包括接口，交换内容，VLAN等。
          ovs-vswitchd根据数据库中的配置工作，ovs-vswitchd与ovsdb-server通信使用OVSDB协议
    ovs-vswitchd：    
          是OVS核心，实现交换，和Linux内核兼容模块通过netlink通信并一起实现基于流的交换：flow-based switching
          和上层controller通信遵从OPENFLOW协议，支持多个独立datapath（网桥）通过更改flow table实现绑定和VLAN等功能...
    ovs kernel module：
          内核模块实现多个数据路径：DataPath（类似交换机）每个都可有多个：vports，类似交换端口。
          每个数据路径也通过关联流表"flow table"操纵

OpenVSwitc Tools
    ovs-dpctl   用于配置交换机内核模块，可控制转发的规则
    ovs-vsctl   获取或更改ovs-vswitchd配置，此工具操作时更新ovsdb-server
    ovs-controller  简单的OpenFlow流控工具
    ovs-ofctl   用来控制OVS作为OpenFlow交换机工作时的流表内容。
    ovs-pki  OpenFlow交换机创建和管理公钥框架
    ovs-tcpundump   tcpdump的补丁（解析OpenFlow消息）
    ovs-appctl   一般不用（主要向OVS守护进程发送命令），用于查询和管理ovs daemon
    ovs-dpctl   用于管理ovs的datapath
    brocompat.ko    Linux bridge compatibility module
    openvswitch.ko  Open vSwitch switching datapath
```
#### 部署
```bash 
[root@node1 ~]# yum -y install rpm-build selinux-policy-devel python-six
[root@node1 ~]# ll
总用量 6008
-rw-r--r--. 1 root root 6149523 12月 30 02:33 openvswitch-2.7.0.tar.gz   #下载源码并创建rpm包
[root@node1 ~]# setenforce 0
[root@node1 ~]# mkdir -p ~/rpmbuild/SOURCES
[root@node1 ~]# tar -zxf openvswitch-2.7.0.tar.gz && cp openvswitch-2.7.0.tar.gz ~/rpmbuild/SOURCES/
[root@node1 ~]# sed 's/openvswitch-kmod, //g' openvswitch-2.7.0/rhel/openvswitch.spec > \
openvswitch-2.7.0/rhel/openvswitch_no_kmod.spec  
[root@node1 ~]# rpmbuild -bb --nocheck openvswitch-2.7.0/rhel/openvswitch_no_kmod.spec

[root@node1 ~]# mkdir /etc/openvswitch                      #创建ovs配置目录并安装制作好的rpm包
[root@node1 ~]# yum -y localinstall rpmbuild/RPMS/x86_64/openvswitch-2.7.0-1.x86_64.rpm

#启动服务
[root@node1 ~]# systemctl start openvswitch
[root@node1 ~]# ovs-vsctl show            
286c02ff-a812-42ab-ac8a-cd342aeb6275
    ovs_version: "2.7.0"
```
#### Demo
```bash
[root@node1 ~]# ovs-vsctl add-br br0                        #新建网桥设备
[root@node1 ~]# ovs-vsctl add-br br0 parent VLAN            #新建网桥设备的同时指定其所属VLAN
[root@node1 ~]# ovs-vsctl del-br ...                        #删除指定桥
[root@node1 ~]# ovs-vsctl del-port ... ...                  #删除特定桥的指定端口 
[root@node1 ~]# ovs-vsctl set bridge br0 stp_enable=true    #对指定的交换机启用生成树
[root@node1 ~]# ovs-vsctl add-port br0 eth0                 #添加接口到网桥（网桥中加入的物理接口不可以有IP地址）
[root@node1 ~]# ovs-vsctl add-port br0 eth1                 #
[root@node1 ~]# ovs-vsctl add-bond br0 bond0 eth2 eth3      #多网卡绑定 add-bond <bridge> <port> <iface...>
[root@node1 ~]# ifconfig br0 192.168.128.5/24               #为网桥设置IP (internal port 可配IP地址)
[root@node1 ~]# ovs-vsctl list-br                           #列出所有桥
[root@node1 ~]# ovs-vsctl list-ports br0                    #列出br0上的端口（不包括internal port）
[root@node1 ~]# ovs-vsctl list-ifaces br0                   #列出br0上的所有接口（端口内包含多个接口，类似物理拓扑）
[root@node1 ~]# ovs-vsctl list interface eth8               #列出OVS中端口eth1的详细数据
[root@node1 ~]# ovs-vsctl port-to-br xxx                    #列出挂载某网络接口的所有网桥
[root@node1 ~]# ovs-vsctl show                              #查看全部信息，信息来自于ovsdb-server

#VLAN
[root@node1 ~]# ovs-vsctl set port eth0 tag=10              #设置br0中的端口eth0为VLAN 10
[root@node1 ~]# ovs-svctl add-port br0 eth1 tag=10          #添加eth1到指定bridge br0并将其置成VLAN 10
[root@node1 ~]# ovs-vsctl add-port br0 eth1 trunk=9,10,11   #在br0上添加port eth1为VLAN 9,10,11的trunk
[root@node1 ~]# ovs-vsctl remove port eth0 tag=10           #移除VLAN_ID

#在同一个宿主机内将两台虚拟交换机建立连接
[root@node1 ~]# ovs-vsctl add-br br0 
[root@node1 ~]# ovs-vsctl add-br br1
[root@node1 ~]# ip link add veth1.1 type veth peer name veth1.2
[root@node1 ~]# ip link set veth1.1 up
[root@node1 ~]# ip link set veth1.2 up
[root@node1 ~]# ovs-vsctl add-port br0 veth1.1
[root@node1 ~]# ovs-vsctl add-port br1 veth1.2

#GRE tunnel
[root@node1 ~]# ovs-vsctl add-port br0 br0-gre -- set interface br0-gre type=gre options:remote_ip=1.2.3.4

#STP
[root@node1 ~]# ovs-vsctl set bridge ovs-br stp_enable=[true|false]         #开启、关机STP生成树
[root@node1 ~]# ovs-vsctl get bridge ovs-br stp_enable                      #查询STP生成树配置信息
[root@node1 ~]# ovs−vsctl set bridge br0 other_config:stp-priority=0x7800   #设置Priority
[root@node1 ~]# ovs−vsctl set port eth0 other_config:stp-path-cost=10       #设置Cost
[root@node1 ~]# ovs−vsctl clear bridge ovs-br other_config                  #移除STP设置

#创建 internal port
#internal port 可配置IP，普通port上配置的IP是不起作用的。
[root@node1 ~]# ovs-vsctl add-br br0 in0 -- set interface in0 type=internal #在br0创建internal port: in0
[root@node1 ~]# ip addr add 10.10.10.10/24 dev in0

#创建 Bond
[root@node1 ~]# ovs-vsctl add-br ovsbr1
[root@node1 ~]# ovs-vsctl add-bond ovsbr1 bond0 eth1 eth3 [lacp=active]
[root@node1 ~]# ovs-vsctl set port bond0 lacp=active                        #modify the properties
```
#### Trunk - IEEE 802.1Q
```bash
[root@node1 ~]# modinfo 8021q       #Linux默认加载了支持Dot1q的模块
filename:       /lib/modules/3.10.0-327.el7.x86_64/kernel/net/8021q/8021q.ko
version:        1.8
license:        GPL
alias:          rtnl-link-vlan
rhelversion:    7.2
srcversion:     2E63BD725D9DC11C7DA6190
depends:        mrp,garp
intree:         Y
vermagic:       3.10.0-327.el7.x86_64 SMP mod_unload modversions 
signer:         CentOS Linux kernel signing key
sig_key:        79:AD:88:6A:11:3C:A0:22:35:26:33:6C:0F:82:5B:8A:94:29:6A:B3
sig_hashalgo:   sha256

```
