#### brctl
```bash
# CentOS7的NetworkManager默认不支持桥接模式，建议改用CentOS6系列的Network
[root@localhost ~]# systemctl stop NetworkManager
[root@localhost ~]# systemctl start network

# 安装对内核的网桥管理的命令行工具 brctl
[root@localhost ~]# yum -y install bridge-utils

# 流程：
[root@localhost ~]# brctl addbr br0                 #添加网桥
[root@localhost ~]# brctl show                      #查看桥列表
bridge name     bridge id           STP enabled   interfaces
br0             8000.000000000000   no
[root@localhost ~]# ip link set dev br0 up          #启用网桥

# 清除 interface ip
[root@localhost ~]# ifconfig eno16777736 0.0.0.0
# 网桥内的物理网卡作为一个端口运行于混杂模式，且在链路层工作，所以不需要IP

# 先拆除eno16777736的地址之后再加入br0
[root@localhost ~]# brctl addif br0 eno16777736     #将eno16777736添加至网桥br0
[root@localhost ~]# brctl stp br0 on                #开启br0的生成树功能

# 设置桥ip，Linux网桥能配成多个逻辑网段，相当于在交换机内部划分多个VLAN
# 给 br0 配置IP：192.168.1.1，实现远程管理网桥，192.168.1.0/24 内主机都可 telnet 到网桥对其配置
[root@localhost ~]# ifconfig br0 192.168.1.1 up
[root@localhost ~]# route add default gw 192.168.1.100

[root@localhost ~]# brctl --help
Usage: brctl [commands]
commands:
        addbr           <bridge>                        add bridge
        delbr           <bridge>                        delete bridge
        addif           <bridge> <device>               add interface to bridge
        delif           <bridge> <device>               delete interface from bridge
        hairpin         <bridge> <port> {on|off}        turn hairpin on/off
        setageing       <bridge> <time>                 set ageing time
        setbridgeprio   <bridge> <prio>                 set bridge priority             #STP桥优先级
        setfd           <bridge> <time>                 set bridge forward delay
        sethello        <bridge> <time>                 set hello time
        setmaxage       <bridge> <time>                 set max message age
        setpathcost     <bridge> <port> <cost>          set path cost
        setportprio     <bridge> <port> <prio>          set port priority
        show            [ <bridge> ]                    show a list of bridges
        showmacs        <bridge>                        show a list of mac addrs
        showstp         <bridge>                        show bridge stp info            
        stp             <bridge> {on|off}               turn stp on/off                 #启用生成树
```
##### 添加一对虚拟网卡(逻辑上是1个)，并且将其中一个添加到宿主机内的网桥设备中【本内容仅参考，生产中直接对br0内的veth2配置IP即可】
```bash
# 虚机1/2的eth0的下半段分别在宿主机br0的veth0/1上，宿主机的veth2在br0内，并且下半段在veth3接口
# 例：
#          [virtual-1]               [virtual-2]
#              \veth1@br0            /veth0@br0
#                 [ Host - veth2@br0 ]
#                            |
#                           veth3，eno16777736 -------> Internet
#

[root@node1 ~]# ip link add veth2 type veth peer name veth3
[root@node1 ~]# ip link set veth2 up
[root@node1 ~]# ip link set veth3 up
[root@node1 ~]# brctl addbr br0
[root@node1 ~]# brctl addif br0 veth2              #宿主机内的其他虚拟机均通过其本机网卡接入此桥设备
[root@node1 ~]# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.a62f5a8e91ba       no              veth2           # <------
                                                        ...（略）
docker0         8000.0242859adf2e       no
virbr0          8000.52540055c3f3       yes             virbr0-nic
[root@node1 ~]# ip address add 192.168.2.254/24 dev veth3               #对宿主机中的veth设备添加地址

[root@virtual-host ~]# ping 192.168.2.254
64 bytes from 192.168.2.254: icmp_seq=1 ttl=128 time=0.1 ms
64 bytes from 192.168.2.254: icmp_seq=2 ttl=128 time=0.7 ms

[root@node1 ~]# echo 1 > /proc/sys/net/ipv4/ip_forward                  #开启宿主机路由转发功能
[root@virtual-host ~]# route add default gw 192.168.2.254               #对虚机设置GW指向宿主机veth2后其可访问外网

# 注：此环境下若不使用Iptables做NAT则虚机内的数据包能出去但回不来...
[root@node1 ~]# iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -j SNAT --to-source <eno16777736_address>
```
