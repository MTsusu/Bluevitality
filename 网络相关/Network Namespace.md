#### Network Namespace
```txt
虚拟机KVM-dom*内网卡后半段接入网桥"br internal"，此桥又接入宿主机内独立的网络名称空间，此空间内实现了DHCP及路由器功能
此名称空间内的路由器接口的后半段又接入了宿主机的br0网桥，br0内部桥接了宿主机网卡及Net-Namespace内路由器的后半段网卡...
相当于此"internal桥"通过路由器直接接入了物理网络，即KVM-dom1借助宿主机的Namespace实现了独立于宿主机的网络
相当于虚机绕开宿主机直接接入了宿主机所在的物理网络...
注：下面拓扑中：[br internal]与[Host br0]是宿主机上的桥设备，此处"Net-Namespace"即名为"Instance1"的网络名称空间
    "Instance1"扮演了路由器的角色，所有dom的gateway均指向其加入Instance的接口地址"veth1.5"
    [Host br0]与[br internal]逻辑上成为了使用路由器隔离出来的网络（即：Instance1与宿主机无任何联系）

|   Node1: 
|                                                                                   |
|       [KVM-dom1]          [KVM-dom2]         .                                    |
|           \'veth1.2'       /                 .                                    |
|            \              /                  .                                    |
|             \'veth1.1'   /'veth1.*'          .                                    |
|              [br internal]                   .                                    |
|                 |'veth1.5'                   .                [Host eno16777736]  |
|                 |                            .                    |               | 
|                 |'veth1.4'                   .                    |               |
|                 ↓192.168.1.1                 .                    ↓               |
|             【Net-Namespace】'veth1.6'    --------->  'veth1.7'[Host br0] -----> Internat  :-)
|                   |          192.168.1.254   .                                    |
|              (DHCP,Route)                    .                                    | 
```

```bash
[root@node1 ~]# ip netns help
Usage: ip netns list
       ip netns add NAME
       ip netns set NAME NETNSID
       ip [-all] netns delete [NAME]
       ip netns identify [PID]
       ip netns pids NAME
       ip [-all] netns exec [NAME] cmd ...      #实现在指定的命名空间内运行任何程序，并且其对其他的名称空间不可见!
       ip netns monitor
       ip netns list-id
       
[root@node1 ~]# echo 1 > /proc/sys/net/ipv4/ip_forward  #只有宿主机开启核心转发才能使用网络名称空间的ip_forward
[root@node1 ~]# ip netns add Instance1      #创建1个网络名称空间，名为"Instance1"
[root@node1 ~]# ip netns list
Instance1
[root@node1 ~]# ip netns exec Instance1 ip link show    #查看指定的网络名称空间内的网卡信息
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

#创建虚拟机使用的桥设备"internal"
[root@node1 ~]# brctl addbr internal
[root@node1 ~]# ip link set dev internal up
    
#将物理网卡加入到br0桥中，并且将物理网卡的地址赋予br0
[root@node1 ~]# brctl addbr br0
[root@node1 ~]# ip link set dev br0 up
[root@node1 ~]# ip addr del 192.168.0.5/24 dev eno16777736
[root@node1 ~]# ip addr add 192.168.0.5/24 dev br0
[root@node1 ~]# brctl addif br0 eno16777736

#创建一对网卡：veth1.1/1.2 （逻辑上是一个），将veth1.1放入桥设备"internal"，1.2在KVM的dom中
[root@node1 ~]# ip link add veth1.1 type veth peer name veth1.2 
[root@node1 ~]# ip link set veth1.1 up
[root@node1 ~]# ip link set veth1.2 up
[root@node1 ~]# brctl addif internal veth1.1
[root@node1 ~]# 此处省略再KVM的dom1和dom2中启动时指定其网卡为veth1.2/veth1.*，及其网关指向veth1.4的步骤
    
#可以对网卡直接改名字，使其更人性化
[root@node1 ~]# ip netns exec Instance1 ip link set veth1.1 name eth0   
[root@node1 ~]# ip netns exec Instance1 ip link show
22: eth0@if21: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state UP mode DEFAULT qlen 1000
    link/ether f2:d7:c1:cf:a0:0b brd ff:ff:ff:ff:ff:ff link-netnsid 0

#在"[br internal]"与"[Net-Namespace]"间建立连接，并对此网络设备的后半段设置IP地址
[root@node1 ~]# ip link add veth1.4 type veth peer name veth1.5
[root@node1 ~]# ip link set veth1.4 up
[root@node1 ~]# ip link set veth1.5 up
[root@node1 ~]# brctl addif internal veth1.5
[root@node1 ~]# ip link set dev veth1.4 netns Instance1
[root@node1 ~]# ip netns exec Instance1 ip addr add 192.168.1.1/24 dev veth1.4 up    #它是所有虚机的网关

#在"[Net-Namespace]"与"[Host br0]"之间创建连接
[root@node1 ~]# ip link add veth1.6 type veth peer name veth1.7
[root@node1 ~]# ip link set veth1.6 up
[root@node1 ~]# ip link set veth1.7 up
[root@node1 ~]# brctl addif br0 veth1.7
[root@node1 ~]# ip link set dev veth1.6 netns Instance1
[root@node1 ~]# ip netns exec Instance1 ip addr add 192.168.1.254/24 dev veth1.6 up
#此IP不要与br0地址冲突，要使用宿主机所在物理网段内的IP地址

#最后，在Instance1内设置其SNAT规则与DHCP服务，使得此路由器内部的domIP可被NAT出去
[root@node1 ~]# ip netns exec Instance1 iptables -t nat -A POSTROUTING -s 192.168.1.0/24 \
! -d 192.168.1.0/24 -j SNAT --to-source  192.168.1.254
```
