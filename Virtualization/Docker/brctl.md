#### Bridge
```bash
# CentOS7的NetworkManager默认不支持桥接模式.... （建议改用CentOS6系列的Network）
[root@localhost ~]# systemctl stop NetworkManager
[root@localhost ~]# systemctl start network

# 安装对内核的网桥管理的命令行工具 brctl
[root@localhost ~]# yum -y install bridge-utils

# 流程：
[root@localhost ~]# brctl addbr br0                 #添加网桥
[root@localhost ~]# brctl show                      #查看桥列表
bridge name     bridge id               STP enabled     interfaces
br0             8000.000000000000       no
# 清除 interface ip
# 网桥的每个物理网卡作为一个端口运行于混杂模式，且在链路层工作，所以不需要 IP
[root@localhost ~]# ifconfig eno16777736 0.0.0.0
# 先拆除eno16777736的地址之后再加入br0
[root@localhost ~]# brctl addif br0 eno16777736     #将eno16777736添加至网桥br0
[root@localhost ~]# brctl stp br0 on                #开启br0的生成树功能
# 设置网桥 ip [ Linux 网桥能配成多个逻辑网段（相当于交换机中划分多个 VLAN）]
# 给 br0 配置IP：192.168.1.1，实现远程管理网桥，192.168.1.0/24 内主机都可 telnet 到网桥对其配置
[root@localhost ~]# ifconfig br0 192.168.1.1 up
[root@localhost ~]# route add default gw 192.168.1.100

[root@localhost ~]# brctl --help
Usage: brctl [commands]
commands:
        addbr           <bridge>                add bridge
        delbr           <bridge>                delete bridge
        addif           <bridge> <device>       add interface to bridge
        delif           <bridge> <device>       delete interface from bridge
        hairpin         <bridge> <port> {on|off}        turn hairpin on/off
        setageing       <bridge> <time>         set ageing time
        setbridgeprio   <bridge> <prio>         set bridge priority
        setfd           <bridge> <time>         set bridge forward delay
        sethello        <bridge> <time>         set hello time
        setmaxage       <bridge> <time>         set max message age
        setpathcost     <bridge> <port> <cost>  set path cost
        setportprio     <bridge> <port> <prio>  set port priority
        show            [ <bridge> ]            show a list of bridges
        showmacs        <bridge>                show a list of mac addrs
        showstp         <bridge>                show bridge stp info
        stp             <bridge> {on|off}       turn stp on/off
```
