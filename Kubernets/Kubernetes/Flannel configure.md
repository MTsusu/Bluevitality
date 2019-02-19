#### Flannel 网络设置
```bash
systemctl stop firewalld.service

#systemd使用到的环境变量配置文件 ( Flannel必须先于Docker启动 )
cat /etc/flannel/flanneld.conf          
# Flanneld configuration options
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="-etcd-endpoints=http://192.63.63.1:2379"
# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="-etcd-prefix=/test/network/config"
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
etcdctl mk /test/network/config  \
'{"Network": "172.22.0.0/16", "SubnetLen": 24, "SubnetMin": "172.22.0.0","SubnetMax": "172.22.255.254", \
"Backend": {"Type": "vxlan"}}'

#Network        设置容器ip网段，docker0默认是172.17.0.0/16
#SubnetMin      起始网段，可不写
#SubnetMax      终止网段，可不写
#Backend        数据字段
#type	        默认为udp方式，此处指定为vxlan方式
#VNI	        指定vlan id 默认是1


#每个节点都感知其它节点的存在：
etcdctl ls /test/network --recursive
/test/network/config
/test/network/subnets
/test/network/subnets/172.22.9.0-24         #每个地址都是1个Node节点能分配给其自身运行的Pod地址范围
/test/network/subnets/172.22.21.0-24
/test/network/subnets/172.22.90.0-24

#查看具体某个节点的配置信息如下：
etcdctl get /test/network/subnets/172.22.9.0-24 | python -m json.tool
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
#/usr/bin/flanneld -etcd-endpoints=http://192.63.63.1:2379 -etcd-prefix=/test/network/config

#启动后会从etcd读取flannel的配置信息，获取一个subnet并开始监听etcd数据的变化
#flanneld还会配置相关backend并将信息写入/run/flannel/subnet.env :
#Docker安装完成后，需修改其启动参数以使其能够使用flannel进行IP分配及网络通讯
#生成的环境变量文件包含了当前主机要使用flannel通讯的相关参数，如下：
FLANNEL_NETWORK=172.22.0.0/16
FLANNEL_SUBNET=172.22.9.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=false
#可使用flannel提供的脚本将subnet.env转写成Docker启动参数，创建好的启动参数默认生成在/run/docker_opts.env中：
cat /run/docker_opts.env
# /opt/flannel/mk-docker-opts.sh -c
# cat /run/docker_opts.env
DOCKER_OPTS=" --bip=172.22.9.1/24 --ip-masq=false --mtu=1450"

修改docker的服务启动文件如下：
# vim /lib/systemd/system/docker.service
EnvironmentFile=/run/docker_opts.env
ExecStart=/usr/bin/dockerd $DOCKER_OPTS -H fd://
#或：
#将docker daemon的配置信息写入 /run/flannel/docker 
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
```
