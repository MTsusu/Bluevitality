#### 环境
```txt
      consul-server            consul-agent
             |                      |
            [Node1]   <------>  [Node2]
             /                       \
    主机IP:192.168.0.3            主机IP:192.168.0.4
----------------------------------------------------------------------------
docker主机集群通过key/value存储共享数据，在7946端口上相互间通过gossip协议学习各宿主机运行了哪些容器
守护进程根据这些数据来在vxlan1设备上生成静态MAC转发表

overlay网络依赖宿主机三层网络的组播实现，需要在所有宿主机的防火墙上打开下列端口：
      4789/udp	      容器之间流量的vxlan端口
      7946/udp/tcp	docker守护进程的控制端口
```
#### 部署流程
```bash
[root@node1 ~]# setenforce 0                                    #在各节点均进行如下设置
[root@node1 ~]# systemctl stop firewalld                        
[root@node1 ~]# hostnamectl set-hostname node1                  #节点名称必须不同!...
[root@node1 ~]# vim /etc/sysconfig/network                      #---> hostname=node1 
[root@node1 ~]# unzip consul_0.8.1_linux_amd64.zip && mv consul /bin/

#启动consul服务端
[root@node1 ~]# nohup consul agent -server -bootstrap -data-dir /home/consul -bind=192.168.0.3 -client=0.0.0.0 &

#运行consul节点代理
[root@node2 ~]# nohup consul agent -data-dir /home/consul -bind=127.0.0.1 -client=0.0.0.0 &
[root@node2 ~]# consul join 192.168.0.3                         #加入consul集群
Successfully joined cluster by contacting 1 nodes.
[root@node1 ~]# consul members                                  #服务端验证集群成员
Node   Address           Status  Type    Build  Protocol  DC
node1  192.168.0.3:8301  alive   server  0.8.1  2         dc1
node2  127.0.0.1:8301    failed  client  0.8.1  2         dc1

[root@node1 ~]# vim /etc/sysconfig/docker-network    #所有节点此处的设置均相同
DOCKER_NETWORK_OPTIONS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock \
--cluster-store consul://192.168.0.3:8500 --cluster-advertise eno16777736:2375"
[root@node1 ~]# systemctl restart docker

[root@node2 ~]# vim /etc/sysconfig/docker-network    #所有节点此处的设置均相同
DOCKER_NETWORK_OPTIONS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock \
--cluster-store consul://192.168.0.3:8500 --cluster-advertise eno16777736:2375"
[root@node2 ~]# systemctl restart docker

# 注：
# –cluster-store=       指向docker daemon所使用key value service的地址
# –cluster-advertise=   决定了所使用网卡以及docker daemon端口信息

#在Node1节点创建overlay网络（在node1创建的multihost会通过consul同步到node2上面）
[root@node1 ~]#  docker network create -d overlay --subnet 172.18.0.0/16 multihost
56656e3e6af2eedb600f305ea96f6b7f453c5d2d6e296ccf54461e6d0a6f3719

[root@node2 ~]# docker network ls   #node2实时同步...
NETWORK ID          NAME                DRIVER              SCOPE
e86e6ed88d4d        bridge              bridge              local               
78552a6870d2        host                host                local               
56656e3e6af2        multihost           overlay             global              
d523566ec70f        none                null                local 
```
#### 测试
```bash
#下面的--network-alias用于指定容器在用户定义网络中的别名，使本网络内其他的容器可通过此别名进行通信
[root@node2 ~]# docker run -it --net=multihost --network-alias test-server --name=node2_c1 docker.io/bash 
bash-4.4# ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
6: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP 
    link/ether 02:42:0a:00:00:03 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.3/24 scope global eth0                           #此IP地址用于-p映射到主机地址使用？
       valid_lft forever preferred_lft forever
    inet6 fe80::42:aff:fe00:3/64 scope link 
       valid_lft forever preferred_lft forever
9: eth1@if10: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.2/16 scope global eth1                         #自定义网络中可直接ping其--name指定的容器名
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe12:2/64 scope link 
       valid_lft forever preferred_lft forever

[root@node1 ~]# docker run -it --net=multihost --network-alias test-server2 --name=node1_c1 docker.io/bash
bash-4.4# ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
6: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP 
    link/ether 02:42:0a:00:00:02 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:aff:fe00:2/64 scope link 
       valid_lft forever preferred_lft forever
9: eth1@if10: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.2/16 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe12:2/64 scope link 
       valid_lft forever preferred_lft forever
bash-4.4# ping 10.0.0.3
PING 10.0.0.3 (10.0.0.3): 56 data bytes
64 bytes from 10.0.0.3: seq=0 ttl=64 time=0.610 ms
64 bytes from 10.0.0.3: seq=1 ttl=64 time=0.587 ms
```
#### 使用静态IP地址
```txt
以上的实验步骤。container的ip都是自动分配的，如果需要静态的固定ip，怎么办？
在创建网络的过程中有区别:
sudo docker network create -d overlay \
--ip-range=192.168.2.0/24 \
--subnet=192.168.2.0/24 \
--gateway=192.168.2.1 multihost

node1节点容器启动时指定地址：
docker run -d --name host1 --net=multihost --ip=192.168.2.2 hanxt/centos:7

node2节点容器启动时指定地址：
docker run -d --name host2 --net=multihost --ip=192.168.2.3 hanxt/centos:7
```
