#### 环境
```txt
            容器网段：10.1.0.0/24        10.2.0.0/24
                     |                      |
                    [Host1]   <------>  [Host2]
                     /                       \
            主机IP:192.168.0.3            主机IP:192.168.0.4
```
#### 部署流程 @ Host1
```bash
[root@node1 ~]# ovs-vsctl add-br obr0                                               #创建网桥：0br0
[root@node1 ~]# ovs-vsctl add-port obr0 gre0                                        #添加接口gre0到网桥obr0
[root@node1 ~]# ovs-vsctl set interface gre0 type=gre options:remote_ip=192.168.0.4 #启用Gre设备并设置对端外网IP
[root@node1 ~]# ovs-vsctl show
286c02ff-a812-42ab-ac8a-cd342aeb6275
    Bridge "obr0"
        Port "gre0"
            Interface "gre0"                                    #
                type: gre
                options: {remote_ip="192.168.0.4"}
        Port "obr0"
            Interface "obr0"                                    #端口内可配置多个接口
                type: internal
    ovs_version: "2.7.0"
[root@node1 ~]# yum -y install bridge-utils
[root@node1 ~]# brctl addbr br0                                 #创建网桥br0
[root@node1 ~]# ifconfig br0 10.1.0.0 netmask 255.255.255.0     #设置网桥br0的IP地址（每个Node节点不能相同）
[root@node1 ~]# brctl addif br0 obr0                            #将obr0添加到br0
[root@node1 ~]# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.b659c28ce04f       no              obr0
docker0         8000.024263517750       no
[root@node1 ~]# vim /etc/sysconfig/docker-network  #--->  DOCKER_NETWORK_OPTIONS="-b=br0"
[root@node1 ~]# systemctl daemon-reload
[root@node1 ~]# systemctl restart docker
[root@node1 ~]# ip route add 10.2.0.0/24 via 192.168.0.4 dev eno16777736    #设置到对端节点的路由
```
#### 部署流程 @ Host2
```bash
[root@node2 ~]# ovs-vsctl add-br obr0
[root@node2 ~]# ovs-vsctl add-port obr0 gre0
[root@node2 ~]# ovs-vsctl set interface gre0 type=gre options:remote_ip=192.168.0.3
[root@node2 ~]# ovs-vsctl show
4dcf9f5c-f225-477b-a6be-0ae836399b1f
    Bridge "obr0"
        Port "obr0"
            Interface "obr0"
                type: internal
        Port "gre0"
            Interface "gre0"
                type: gre
                options: {remote_ip="192.168.0.3"}
    ovs_version: "2.7.0"
[root@node2 ~]# yum -y install bridge-utils
[root@node2 ~]# brctl addbr br0
[root@node2 ~]# ifconfig br0 10.1.0.0 netmask 255.255.255.0
[root@node2 ~]# brctl addif br0 obr0
[root@node2 ~]# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.b659c28ce04f       no              obr0
docker0         8000.024263517750       no
[root@node2 ~]# vim /etc/sysconfig/docker-network  #--->  DOCKER_NETWORK_OPTIONS="-b=br0"
[root@node2 ~]# systemctl daemon-reload
[root@node2 ~]# systemctl restart docker
```
#### 测试
```bash
#到此，如果没有出现任何问题的话，最后node1和node2上的两个容器之间能够互相ping通
[root@node2 ~]# docker run -it docker.io/bash
bash-4.4# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN 
    link/gre 0.0.0.0 brd 0.0.0.0
3: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
8: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:0a:02:00:02 brd ff:ff:ff:ff:ff:ff
    inet 10.2.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:aff:fe02:2/64 scope link tentative 
       valid_lft forever preferred_lft forever
       
[root@node1 ~]# docker run -it docker.io/bash 
bash-4.4# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN 
    link/gre 0.0.0.0 brd 0.0.0.0
3: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
9: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:0a:01:00:02 brd ff:ff:ff:ff:ff:ff
    inet 10.1.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:aff:fe01:2/64 scope link tentative 
       valid_lft forever preferred_lft forever
bash-4.4# ping 10.2.0.2
PING 10.2.0.2 (10.2.0.2): 56 data bytes
64 bytes from 10.2.0.2: seq=0 ttl=62 time=0.721 ms
64 bytes from 10.2.0.2: seq=1 ttl=62 time=0.616 ms
```
