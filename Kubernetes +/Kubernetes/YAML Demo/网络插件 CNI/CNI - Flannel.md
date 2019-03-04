#### Flannel 网络设置
```txt

CNI插件是可执行文件，会被kubelet调用:  ( 以下参数在使用kudeadm时是默认设置 )
kubelet --network-plugin=cni --cni-conf-dir /etc/cni/net.d --cni-bin-dir /opt/cni/bin

备忘：
Flannel 基于3层网络实现虚拟的2层网络
Flannel 为每个host分配一个subnet，容器从这个subnet中分配IP，这些IP可以在host间路由，容器间无需使用nat和端口映射即通信
每个subnet都是从一个更大的IP池中划分的，flannel会在每个主机上运行一个叫flanneld的agent，其职责就是从池子中分配subnet
Flannel 使用etcd存放网络配置、已分配 的subnet、host的IP等信息
Flannel 数据包在主机间转发是由backend实现的，目前已经支持 UDP、VxLAN、host-gw、AWS VPC和GCE路由等多种
"Tunnel"协议的另外一个重要的特性就是软件扩展性，是软件定义网络（Software-defined Network，SDN）的基石之一

流程：
1. 容器直接使用目标容器的ip访问，默认通过容器内部的eth0发送出去。
2. 报文通过veth pair被发送到vethXXX。
3. vethXXX是直接连接到虚拟交换机docker0的，报文通过虚拟bridge docker0发送出去。
4. 查找路由表，外部容器ip的报文都会转发到flannel0虚拟网卡，这是P2P的虚拟网卡，然后报文就被转发到监听在另一端的flanneld。
5. flanneld通过etcd维护了各个节点之间的路由表，把原来的报文UDP封装一层，通过配置的iface发送出去。
6. 报文通过主机之间的网络找到目标主机。
7. 报文继续往上，到传输层，交给监听在8285端口的flanneld程序处理。
8. 数据被解包，然后发送给flannel0虚拟网卡。
9. 查找路由表，发现对应容器的报文要交给docker0。
10. docker0找到连到自己的容器，把报文发送过去。

Flannel启动过程解析： ( 须先于Docker启动 )
1. 从etcd中获取network的配置信息
2. 划分subnet，并在etcd中进行注册
3. 将子网信息记录到/run/flannel/subnet.env中

参数：
--public-ip="": IP accessible by other nodes for inter-host communication. Defaults to the IP of the interface being used for communication.
--etcd-endpoints=http://127.0.0.1:4001: a comma-delimited list of etcd endpoints.
--etcd-prefix=/coreos.com/network: etcd prefix.
--etcd-keyfile="": SSL key file used to secure etcd communication.
--etcd-certfile="": SSL certification file used to secure etcd communication.
--etcd-cafile="": SSL Certificate Authority file used to secure etcd communication.
-v=0: log level for V logs. Set to 1 to see messages related to data path.
```
```bash
systemctl stop firewalld.service

#systemd使用到的环境变量配置文件 ( Flannel必须先于Docker启动 )
cat /etc/flannel/flanneld.conf          
# Flanneld configuration options
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="-etcd-endpoints=http://192.63.63.1:2379"
# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="-etcd-prefix=/coreos.com/network/config"
# Any additional options that you want to pass

#systemd
cat /usr/lib/systemd/system/flanneld.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service
 
[Service]
Type=notify
EnvironmentFile=-/etc/flannel/flanneld.conf #/etc/flannel/flanneld.conf
ExecStart=/usr/bin/flanneld $FLANNEL_ETCD_ENDPOINTS $FLANNEL_ETCD_PREFIX $FLANNEL_OPTIONS
ExecStartPost=/usr/libexec/flannel/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target

#flannel有基于etcd cluster的数据交换中心
#每个节点有flannel service，每个节点被分配不同网段，每个节点上的container从该网段获取IP
#节点间通过一个overlay网络保证container可以互联互通

#Flannel的初始网络配置如下：
#对于所有加入flannel的节点和container来讲，flannel给它们呈现的是一个flat的/16大三层网络，每个节点获取里面一个/24的网段
{
  "Network": "172.22.0.0/16",
  "SubnetLen": 24,
  "Backend": {
    "Type": "vxlan"
   }
 }

#在Etcd中修改Flannel默认配置：
etcdctl mk /coreos.com/network/config  \
'{"Network": "172.22.0.0/16", "SubnetLen": 24, "SubnetMin": "172.22.0.0","SubnetMax": "172.22.255.0", \
"Backend": {"Type": "vxlan"}}'

#Network      设置容器ip网段，docker0默认是172.17.0.0/16 ( 指定Flannel地址池 )
#SubnetMin    起始网段，可不写
#SubnetMax    终止网段，可不写
#Backend      数据字段
#type	        默认为udp方式，此处指定为vxlan方式
#VNI	        指定vlan id 默认是1

#每个节点都感知其它节点的存在：
etcdctl ls /coreos.com/network --recursive
/coreos.com/network/config
/coreos.com/network/subnets
/coreos.com/network/subnets/172.22.9.0-24         #每个地址都是1个Node节点能分配给其自身运行的Pod地址范围
/coreos.com/network/subnets/172.22.21.0-24
/coreos.com/network/subnets/172.22.90.0-24

#查看具体某个节点的配置信息如下：
etcdctl get /coreos.com/network/subnets/172.22.9.0-24 | python -m json.tool
{
    "PublicIP": "192.168.166.102",
    "BackendType": "vxlan",
    "BackendData": {
        "VtepMAC": "1a:9a:e1:c1:be:3f"
    }
}

[root@node-1 ~]# systemctl enable flanneld.service
[root@node-1 ~]# systemctl start flanneld.service
#node上的flannel service在启动时会以如下的方式运行：
#/usr/bin/flanneld -etcd-endpoints=http://192.63.63.1:2379 -etcd-prefix=/coreos.com/network/config

#启动后会从etcd读取flannel的配置信息，获取一个subnet并开始监听etcd数据的变化
#并且还会配置相关backend并将信息写入/run/flannel/subnet.env
#Docker安装完成后，需修改其启动参数以使其能够使用flannel进行IP分配及网络通讯
#生成的环境变量文件包含了当前主机要使用flannel通讯的相关参数，如下：
FLANNEL_NETWORK=172.22.0.0/16
FLANNEL_SUBNET=172.22.255.0/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=false
#可使用flannel提供的脚本将subnet.env转写成Docker启动参数，创建好的启动参数默认生成在/run/docker_opts.env中：
cat /run/docker_opts.env
# /opt/flannel/mk-docker-opts.sh -c
# cat /run/docker_opts.env
DOCKER_OPTS=" --bip=172.22.9.1/24 --ip-masq=false --mtu=1450"
#
修改docker的服务启动文件如下：
# vim /lib/systemd/system/docker.service
EnvironmentFile=/run/docker_opts.env
ExecStart=/usr/bin/dockerd $DOCKER_OPTS -H fd://
#或将docker daemon的配置信息写入 /run/flannel/docker:
DOCKER_OPT_BIP="--bip=172.22.9.1/24"
DOCKER_OPT_IPMASQ="--ip-masq=true"
DOCKER_OPT_MTU="--mtu=1450"
DOCKER_NETWORK_OPTIONS=" --bip=172.22.9.1/24 --ip-masq=true --mtu=1450"
[root@node-1 ~]# systemctl daemon-reload
[root@node-1 ~]# systemctl restart docker

#启动之后，flanneld会在node上面创建一个flannel.1的vxlan设备并将节点对应的子网赋给docker0(由)
#流程： [ 容器Pod1--> docker0 --> flannel1 ] <---> <Router> <---> [ flannel1 --> docker0 --> 容器Pod2 ]
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN 
    link/ether 02:42:e0:e9:e9:52 brd ff:ff:ff:ff:ff:ff
    inet 172.22.9.1/24 scope global docker0
       valid_lft forever preferred_lft forever
4: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN 
    link/ether 1a:9a:e1:c1:be:3f brd ff:ff:ff:ff:ff:ff
    inet 172.22.9.0/32 scope global flannel.1
       valid_lft forever preferred_lft forever
    inet6 fe80::189a:e1ff:fec1:be3f/64 scope link 
       valid_lft forever preferred_lft forever

# ip route #基于VXLAN的环境下：
default via 192.168.166.2 dev ens33 proto static metric 100 
172.22.0.0/16 dev flannel.1         #flannel
172.22.9.0/24 dev docker0 proto kernel scope link src 172.22.9.1    #docker0 ---> flannel
192.168.166.0/24 dev ens33 proto kernel scope link src 192.168.166.102 metric 100



CNI：
是Container Network Interface的是一个标准的，通用的接口。现在容器平台：docker，kubernetes，mesos，容器网络解决方案。
flannel，calico，weave。只要提供标准的接口就能为同样满足该协议的所有容器平台提供网络功能，而CNI正是这样的标准接口协议。


#Flannel为container提供网络解决方案。
#Flannel有一个基于etcd cluster的数据交换中心，每个节点上有flannel service，每个节点被分配不同的网段
#每个节点上的container从该网段获取IP。一个节点之间通过一个overlay网络保证container可以互联互通。
```