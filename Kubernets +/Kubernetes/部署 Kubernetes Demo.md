#### 实验环境 Centos 7.2
```txt
         etcd    master                  node
             \   /                      /
             [Node1]  <----------->  [Node2]
               |                       |
            192.168.0.3              192.168.0.4
```
#### 在集群内的所有节点先安装如下软件
```bash
[root@nodeX ~]# yum -y install kubernetes* ntp flannel etcd docker  #在所有节点执行安装...
[root@nodeX ~]# setenforce 0 && systemctl stop firewalld
[root@nodeX ~]# ntpdate ntp1.aliyun.com
[root@nodeX ~]# cat >> /etc/hosts <<eof                             #在所有节点/etc/hosts内加入主机名映射
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.3 node1
192.168.0.4 node2
eof
```
#### 部署 etcd 
```bash
[root@node1 ~]# cat /etc/etcd/etcd.conf                        #配置etcd服务器(k8s的数据库系统)
#[Member]
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"                     #数据存储目录
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"                  #写入监听地址（client通信端口）
ETCD_NAME="default"
.......
#
#[Clustering]
#ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:2380"                       #peer初始化广播端口
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379,http://192.168.0.3:2379"      #写入通告地址（集群成员）
#ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
.......
#ETCD_ENABLE_V2="true"
[root@node1 ~]# systemctl enable etcd && systemctl start etcd

[root@node1 ~]# etcdctl member list                            #检查etcd集群成员列表，这里只有一台
8e9e05c52164694d: name=default peerURLs=http://localhost:2380 clientURLs=http://192.168.0.3:2379,\
http://localhost:2379 isLeader=true

#配置etcd（曾用/24出故障） 此处为配置kubernetes中集群成员（容器）使用的网络地址...
[root@node1 ~]# etcdctl set /k8s/network/config '{"Network": "192.168.0.0/16"}' 
{"Network": "192.168.0.0/16"}

[root@node1 ~]# etcdctl get /k8s/network/config                #查看KV设置
{"Network": "192.168.0.0/16"}
```
#### 部署 Master 
```bash
[root@node1 ~]# cat /etc/kubernetes/config                     #配置master服务器
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://192.168.0.3:8080"                 #APISERVER服务所在的地址+端口

[root@node1 ~]# cat /etc/kubernetes/apiserver    
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"             #绑定的地址
KUBE_API_PORT="--port=8080"                                    #监听的端口
KUBELET_PORT="--kubelet_port=10250"                            # Port minions listen on (node节点监听地址?)
KUBE_ETCD_SERVERS="--etcd-servers=http://192.168.0.3:2379"     #etcd服务的地址+端口
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=192.168.0.0/24"  #集群中Service的CIDR范围，不可与物理机IP段重合
KUBE_ADMISSION_CONTROL="--admission-control=AlwaysAdmit,NamespaceLifecycle,NamespaceExists,\
LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
KUBE_API_ARGS=""

[root@node1 ~]# cat /etc/kubernetes/controller-manager         #
KUBE_CONTROLLER_MANAGER_ARGS=""

[root@node1 ~]# cat /etc/kubernetes/scheduler                  #配置kube-scheduler配置文件
KUBE_SCHEDULER_ARGS="--address-0.0.0.0"

#取消账户认证，否则要部署CA并设置TLS证书，之前的测试环境在这里卡住了，注意生产环境需要做数字证书认证和HA!....
[root@node1 ~]# sed -i '/KUBE_ADMISSION_CONTROL/{s/ServiceAccount,//g}' /etc/kubernetes/apiserver 

[root@node1 ~]# systemctl daemon-reload
[root@node1 ~]# systemctl enable kube-apiserver kube-scheduler kube-controller-manager
[root@node1 ~]# systemctl start  kube-apiserver kube-scheduler kube-controller-manager
```
#### Node 1
```bash
[root@node1 ~]# vim /etc/sysconfig/docker                      #配置Docker使其允许从私有的registry中拉取镜像
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
OPTIONS='--insecure-registry registry:5000'                    #

#配置网络，本环境采用flannel的方式，如需其他overlay方案请参考K8s官网
[root@node1 ~]# cat /etc/sysconfig/flanneld    
FLANNEL_ETCD_ENDPOINTS="http://192.168.0.3:2379"               #告知etcd服务，其使用etcd作为数据库
FLANNEL_ETCD_PREFIX="/k8s/network"                             #获取etcd中的网络配置，即：etcdctl set时的"URL"key
FLANNEL_OPTIONS="--iface=eno16777736"                          #使用的网卡...

[root@node1 ~]# cat /etc/kubernetes/config                     #配置node1 kube-proxy
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://192.168.0.3:8080"

[root@node1 ~]# grep -v '^#' /etc/kubernetes/proxy                  
KUBE_PROXY_ARGS="--bind-address=0.0.0.0"

[root@node1 ~]# cat /etc/kubernetes/kubelet                    #配置node1 kubelet
KUBELET_ADDRESS="--address=0.0.0.0"                            #绑定的地址
KUBELET_PORT="--port=10250"                                    #node监听端口，需与Master的KUBELET_PORT保持一致
KUBELET_HOSTNAME="--hostname-override=node1"                   #汇报的本机名称
KUBELET_API_SERVER="--api-servers=http://192.168.0.3:8080"     #位于Master的API-SERVER地址
KUBELET_ARGS=""
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
# kubenet服务的启动需依赖名为"pause"的镜像，默认k8s将从google镜像服务下载，由于GFW原因不会成功因此需指定其他镜像源地址!
# 本目录软件文件夹内已保存了pause镜像，在所有节点手动载入："docker load < gopause.tar" 并修改上面这一行参数为如下设置即可!
# KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=gcr.io/google_containers/pause-amd64:3.0"
# 使用手动方式镜像下载: "docker pull docker.io/kubernetes/pause"
# pause镜像主要用来实现Pod的概念

[root@node1 ~]# systemctl daemon-reload
[root@node1 ~]# systemctl start flanneld         #overlay网络相关 (提供 xlan 网络)
[root@node1 ~]# systemctl start kube-proxy       #是工作节点上运行的网络代理，其监听每个服务端点创建/删除
[root@node1 ~]# systemctl start kubelet          #它是Pod中Node节点的manager，是与主节点通信的代理

[root@node1 ~]# systemctl stop docker
[root@node1 ~]# mk-docker-opts.sh -i             #设置docker0网桥的IP地址（flannel将覆盖docker0网桥）
[root@node1 ~]# source /run/flannel/subnet.env
[root@node1 ~]# ifconfig docker0 ${FLANNEL_SUBNET}
[root@node1 ~]# systemctl start docker

[root@node1 ~]# systemctl enable flanneld   
[root@node1 ~]# systemctl enable kube-proxy 
[root@node1 ~]# systemctl enable kubelet    
[root@node1 ~]# systemctl enable docker     
```
#### Node 2
```bash
[root@node1 ~]# vim /etc/sysconfig/docker                      #配置Docker
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
OPTIONS='--insecure-registry registry:5000'

[root@node2 ~]# cat /etc/sysconfig/flanneld    
FLANNEL_ETCD_ENDPOINTS="http://192.168.0.3:2379"               #告知etcd服务所在地址和端口
FLANNEL_ETCD_PREFIX="/k8s/network"                             #获取etcd中的网络配置（etcdctl set时的"URL"key）
FLANNEL_OPTIONS="--iface=eno16777736"

[root@node2 ~]# cat /etc/kubernetes/config                     #配置node2 kube-proxy
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://192.168.0.3:8080"

[root@node2 ~]# grep -v '^#' /etc/kubernetes/proxy                  
KUBE_PROXY_ARGS="--bind=address=0.0.0.0"


[root@node2 ~]# cat /etc/kubernetes/kubelet
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_PORT="--port=10250"
KUBELET_HOSTNAME="--hostname-override=node2"
KUBELET_API_SERVER="--api-servers=http://192.168.0.3:8080" 
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
KUBELET_ARGS=""

[root@node1 ~]# systemctl daemon-reload
[root@node2 ~]# systemctl start flanneld
[root@node2 ~]# systemctl start kube-proxy
[root@node2 ~]# systemctl start kubelet

[root@node1 ~]# systemctl stop docker
[root@node1 ~]# mk-docker-opts.sh -i 
[root@node1 ~]# source /run/flannel/subnet.env
[root@node1 ~]# ifconfig docker0 ${FLANNEL_SUBNET}
[root@node1 ~]# systemctl start docker

[root@node1 ~]# systemctl enable flanneld   
[root@node1 ~]# systemctl enable kube-proxy 
[root@node1 ~]# systemctl enable kubelet    
[root@node1 ~]# systemctl enable docker

#注：为了管理Pod，每个Node节点上至少要运行 container runtime（如docker或rkt）、kubelet、kube-proxy
```
#### kuberctl 测试 ......
```bash
[root@node1 ~]# kubectl cluster-info                                            #查看集群信息
Kubernetes master is running at http://localhost:8080

[root@node1 ~]# kubectl -s http://localhost:8080 get componentstatuses          #查看各组件信息
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok                   
scheduler            Healthy   ok                   
etcd-0               Healthy   {"health": "true"}

[root@node1 ~]# kubectl get nodes               #至此，整个Kubernetes集群搭建完毕    
NAME      STATUS     AGE
node1     Ready      9m
node2     NotReady   8s

[root@node1 ~]# kubectl get service
NAME         CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes   192.168.0.1   <none>        443/TCP   22m
```
#### 在k8s集群内使用私有的镜像服务器
```bash
#创建docker registry secret
[root@node1 ~]# kubectl create secret docker-registry regsecret \
--docker-server=<your-registry-server> \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email>

#容器中引用该secret：
[root@node1 ~]# cat xxx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
    - name: private-reg-container
      image: <your-private-image>               #指定其使用的私有镜像地址
  imagePullSecrets:
    - name: regsecret
```
