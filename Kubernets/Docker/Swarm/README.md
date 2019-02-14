#### 环境
```txt
	Host-A	--->	Master
	Host-B 	--->	Node-1
	Host-C 	--->	Node-2
```
#### 说明
```txt
Swarm支持设置一组Manager Node，通过支持多Manager Node实现HA (集群中包含Manager和Worker两类Node)
Docker 1.12中Swarm已内置了服务发现工具，不再需要像以前使用 Etcd 或 Consul 这些工具来配置服务发现
对于容器来说若没有外部通信但又是运行中的状态会被服务发现工具认为是 Preparing 状态，但若映射了端口则会是 Running 状态。
docker service [ls/ps/rm/scale/inspect/update]

Swarm使用Raft协议保证多Manager间状态的一致性。基于Raft协议，Manager Node具有一定容错功能（可容忍最多有(N-1)/2个节点失效）
每个Node的配置可能不同，比如有的适合CPU密集型应用，有的适合运行IO密集型应用
Swarm支持给每个Node添加标签元数据，这样可根据Node标签来选择性地调度某个服务部署到期望的一组Node上

docker Swarm mode下会为每个节点的docker engine内置一个DNS server
各个节点间的DNS server通过control plane的gossip协议互相交互信息。注：此处DNS server用于容器间的服务发现。
swarm mode会为每个--net=自定义网络的service分配一个DNS entry。注：目前必须是自定义网络，比如overaly。
而bridge和routing mesh的service，是不会分配DNS的!...
默认当创建一个服务连接到网络时，集群为该服务分配vip，vip基于服务名称映射到DNS别名。网络上的容器服务通过gossip共享DNS映射

docker 1.12 的swarm 集群的自动发现有两种方式, virtual IP address (VIP) 与 DNS round-robin

关于sarm create下--publish选项的补充说明：
要将服务端口发布到集群外部使用--publish，集群使每个节点访问目标端口都可访问!
若外部主机连接到任何群集节点上的该端口，则路由网络将其路由到任务。外部主机无需知道服务任务的IP或内部使用的端口与其进行交互
当用户或进程连接到服务时，任何运行服务任务的工作节点都可能会响应。
Example：$ docker service create --name my_web--replicas 3 --publish 8080:80 ngin    （假设当前集群有10个节点）
三个任务最多可运行在三个节点。不需要知道哪些节点正在运行该任务，连接到10个节点中一个的8080端口都将连到3个nginx中的任一个!
```
#### Demo
![img](资料/swarm-multiple-manager-architecture.png)
`Swarm使用了Raft协议来保证多个Manager之间状态的一致性。基于Raft协议，Manager Node具有一定的容错功能`  
`假设Swarm集群中有个N个Manager Node，那么整个集群可以容忍最多有(N-1)/2个节点失效` 
![img](资料/services-diagram.png)
#### 各节点加入swarm集群
```bash
#master节点创建集群并将其他节点加入swarm集群中
[root@host-a ~]# docker swarm init --advertise-addr 192.168.0.3     #IP地址为本节点在集群中对外的地址
Swarm initialized: current node (c4aa18akyid7wctl4e0hpbqmr) is now a manager.
To add a worker to this swarm, run the following command:           #下列输出说明如何将Worker Node加入到集群

    docker swarm join \
    --token SWMTKN-1-17d18kwcn6mef2usiz7p7d38txo6az4rrdxqzxtwdi9qvmrxwx-48hhk1wzm51sjcktwnbnm7qgl \
    192.168.0.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

[root@host-b ~]# docker swarm join \
> --token SWMTKN-1-17d18kwcn6mef2usiz7p7d38txo6az4rrdxqzxtwdi9qvmrxwx-48hhk1wzm51sjcktwnbnm7qgl \
> 192.168.0.3:2377
This node joined a swarm as a worker.

[root@host-c ~]# docker swarm join \
> --token SWMTKN-1-17d18kwcn6mef2usiz7p7d38txo6az4rrdxqzxtwdi9qvmrxwx-48hhk1wzm51sjcktwnbnm7qgl \
> 192.168.0.3:2377
This node joined a swarm as a worker.

[root@host-a ~]# docker node ls   #查看swarm集群节点信息
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
3fcyk6uf3l161uk6p3x1xwpsv    host-b    Ready   Active        
ags2l01cijtxux8kq0ft4mz8l    host-c    Ready   Active        
c4aa18akyid7wctl4e0hpbqmr *  host-a    Ready   Active        Leader
#Active：该Node可被指派Task
#Pause： 该Node不可被指派新Task，但其他已存在的Task保持运行（暂停一个Node后该其不再接收新的Task）
#Drain： 该Node不可被指派新Task，Swarm Scheduler停掉已存在的Task并将它们调度到可用Node上（进行停机维护时可修改\
         AVAILABILITY为Drain状态）

#查看Node状态
[root@host-a ~]# docker node inspect self
[
    {
        "ID": "c4aa18akyid7wctl4e0hpbqmr",
        "Version": {
            "Index": 10
        },
        "CreatedAt": "2017-12-29T16:04:28.575482252Z",
        "UpdatedAt": "2017-12-29T16:04:28.590768171Z",
        "Spec": {
            "Role": "manager",
            "Availability": "active"
        },
        "Description": {
            "Hostname": "host-a",
            "Platform": {
                "Architecture": "x86_64",
                "OS": "linux"
            },
            "Resources": {
                "NanoCPUs": 4000000000,
                "MemoryBytes": 2082357248
            },
            "Engine": {
                "EngineVersion": "1.12.6",
                "Plugins": [
                    {
                        "Type": "Network",
                        "Name": "bridge"
                    },
                    {
                        "Type": "Network",
                        "Name": "host"
                    },
                    {
                        "Type": "Network",
                        "Name": "null"
                    },
                    {
                        "Type": "Network",
                        "Name": "overlay"
                    },
                    {
                        "Type": "Volume",
                        "Name": "local"
                    }
                ]
            }
        },
        "Status": {
            "State": "ready"
        },
        "ManagerStatus": {
            "Leader": true,
            "Reachability": "reachable",
            "Addr": "192.168.0.3:2377"
        }
    }
]
#在Mater上修改其他node状态：（将Node的AVAILABILITY值改为Drain状态，使其只具备管理功能）
[root@host-a ~]# docker node update --availability drain <Node*>

#在Mater上设置各个节点的lable标签元数据
[root@host-a ~]#  docker node update --label-add cpu_num=2 host-b
host-b
[root@host-a ~]#  docker node update --label-add disk_num=2 host-c   
host-c

#改变Node角色：（dorker Node可以变为Manager Node，这样实际Worker Node由工作Node变成了管理Node）
[root@host-a ~]# docker node promote  <node*>		#提权 (升为manager节点)
[root@host-a ~]# docker node demote  <node*>		#降权 (部署服务只能在管理节点manager上进行)
[root@host-a ~]# docker swarm node leave [--force]	#退出所在集群
```
#### 常规部署流程
```bash
#创建Overlay网络（创建Overlay网络my-network后集群中所有的Manager都可访问。以后在创建服务时只要指定使用的网络即可）
[root@host-a ~]# docker network create -d overlay --subnet=10.0.9.0/24  my-network
a88ql269d3t1ev1yq4n828yut

[root@host-a ~]# docker pull docker.io/bashell/alpine-bash     #swarm集群内各节点下载好镜像先...
[root@host-b ~]# docker pull docker.io/bashell/alpine-bash     #
[root@host-c ~]# docker pull docker.io/bashell/alpine-bash     #

#创建bash容器的服务，服务名为t1，使其同时能运行在2个节点上
#若Swarm集群中其他Node的容器也使用my-network网络，那么处于该网络中的所有容器间均可连通！
[root@host-a ~]# docker service create --replicas 2 --network my-network  --name t1  docker.io/bashell/alpine-bash      
9ye311ixoipa4zt372c5smx5i
[root@host-a ~]# docker service ps t1   	#查看t1服务状态
ID                         NAME      IMAGE                          NODE    DESIRED STATE  CURRENT STATE             ERROR
0f0eiadl2npvvfm3qi8jincvn  t1.1      docker.io/bashell/alpine-bash  host-c  Running        Preparing 16 seconds ago  
brz7bfagxyzkmqlcte3h7i6r3  t1.2      docker.io/bashell/alpine-bash  host-b  Running        Preparing 8 seconds ago    
[root@host-a ~]# docker service rm t1   	#删除t1服务
[root@host-a ~]# docker service ls      	#查看集群服务列表
ID            NAME       REPLICAS  IMAGE           COMMAND
436wxwxfb7je  test_bash  0/2       docker.io/bash  
9cziqd3bxk96  bash_test  0/1       docker.io/bash 

[root@host-a ~]# docker service ps test_bash    #查看集群服务的信息
ID                         NAME             IMAGE           NODE    DESIRED STATE  CURRENT STATE             ERROR
7hooklz0thqordkdbdiypyiih  test_bash.1      docker.io/bash  host-a  Running        Preparing 27 minutes ago  
eem9x7ktt4ome0rbgf05e6f45   \_ test_bash.1  docker.io/bash  host-a  Shutdown       Complete 27 minutes ago   
elm590j5t2jmmvfewqgr7g78z  test_bash.2      docker.io/bash  host-b  Running        Preparing 27 minutes ago 

#查看集群服务的详细信息
[root@host-a ~]# docker service inspect test_bash
[
    {
        "ID": "436wxwxfb7jefm10h0fdsp2ro",
        "Version": {
            "Index": 45
        },
        "CreatedAt": "2017-12-29T16:20:14.854181266Z",
        "UpdatedAt": "2017-12-29T16:20:14.856143634Z",
        "Spec": {
            "Name": "test_bash",
            "TaskTemplate": {
                "ContainerSpec": {
                    "Image": "docker.io/bash"
                },
                "Resources": {
                    "Limits": {},
                    "Reservations": {}
                },
                "RestartPolicy": {
                    "Condition": "any",
                    "MaxAttempts": 0
                },
                "Placement": {}
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 2
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause"
            },
            "Networks": [
                {
                    "Target": "a88ql269d3t1ev1yq4n828yut"
                }
            ],
            "EndpointSpec": {
                "Mode": "vip"
            }
        },
        "Endpoint": {
            "Spec": {
                "Mode": "vip"
            },
            "VirtualIPs": [
                {
                    "NetworkID": "a88ql269d3t1ev1yq4n828yut",
                    "Addr": "10.0.9.4/24"
                }
            ]
        },
        "UpdateStatus": {
            "StartedAt": "0001-01-01T00:00:00Z",
            "CompletedAt": "0001-01-01T00:00:00Z"
        }
    }
]
```
#### 服务的扩容缩容及滚动更新
```bash
#Swarm支持服务扩容缩容，通过--mode设置服务类型，提供了两种模式
#replicated：	指定服务个数（需创建几个冗余副本），这也是Swarm默认使用的服务类型
#global：	在Swarm集群的每个Node上都创建一个服务!
#Example：	docker service create --name test --mode global registry.hundsun.com/library/busybox ping 1.1.1.1
		
#服务扩容缩容：在Manager Node上执行（将前面部署的2个副本的myredis服务，扩容到3个副本）格式：docker service scale <ID>=<num>	
[root@host-a ~]# docker service scale myredis=3		
	#查看服务信息：docker service ls
	#ID            NAME    MODE        	REPLICAS  IMAGE
	#kilpacb9uy4q  myapp   replicated  	1/1       alpine:latest
	#vf1kcgtd5byc  myredis replicated  	3/3       redis

	#查看指定服务在各副本的状态：docker service ps myredis
	#ID            NAME       IMAGE  	NODE     	DESIRED     STATE  	CURRENT STATE     ERROR  PORTS
	#0p3r9zm2uxpl  myredis.1  redis  	manager  	Running     Running 	14 minutes ago                
	#ty3undmoielo  myredis.2  redis  	worker1  	Running     Running 	14 minutes ago                
	#zxsvynsgqmpk  myredis.3  redis  	worker2  	Running     Running 	less than a second ago
	#可以看到目前3个Node的Swarm集群，每个Node上都有个myredis服务的副本，可见也实现了很好的负载均衡
	
	#缩容时只需将副本数小于当前应用服务拥有的副本数即可实现！大于指定缩容副本数的副本会被删除
	#若需删除所有服务，只需在Manager Node上执行：
	#docker service rm <服务ID>
		
#服务滚动更新：
[root@host-a ~]# docker service create  --replicas 3  --name redis  --update-delay 10s  redis:3.0.6
#通过--update-delay表示需更新的服务每成功部署1个延迟10秒后再更新下1个。若更新失败则调度器会暂停本次服务的部署更新
	
#更新已部署的服务所在容器中使用的Image的版本：
[root@host-a ~]# docker service update --image redis:3.0.7 redis:3.0.6
#将Redis服务对应的Image版本由3.0.6更新为3.0.7，同样，若更新失败则暂停本次更新。
```
#### 设置服务的挂载卷
```bash
[root@host-a ~]# docker service create --name test --mount src=/root,dst=/root registry.abc.com/library/busybox \
ping 1.1.1.1		#将服务运行所在的主机目录root映射至服务的root目录
```
#### 集群服务访问测试 （集群成员节点：node1,node2,node3）
```bash
[root@node1 ~]# docker network create -d overlay --subnet=10.0.9.0/24  my-network
ezdmu0wh5rjqiw73jnuvgfky5
[root@node1 ~]# docker service create --replicas 2 -p 80:80 --network my-network --name nginx  docker.io/nginx   
1u1zx7kaxqqye5uyj7ql14nc1
[root@node1 ~]# docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS           PORTS               NAMES
ad9d41d128d5        docker.io/nginx:latest   "nginx -g 'daemon off"   48 minutes ago      Up 48 minutes    80/tcp              nginx.1.5et4bssqn7r1f4r20zbaishae
[root@node1 ~]# docker service ls
ID            NAME   REPLICAS  IMAGE            COMMAND
1u1zx7kaxqqy  nginx  2/2       docker.io/nginx  
[root@node1 ~]# docker service ps nginx
ID                         NAME     IMAGE            NODE   DESIRED STATE  CURRENT STATE           ERROR
5et4bssqn7r1f4r20zbaishae  nginx.1  docker.io/nginx  node1  Running        Running 48 minutes ago  
ef2uqjk5ahni7vuzcsjnn0vxg  nginx.2  docker.io/nginx  node3  Running        Running 48 minutes ago  
[root@node1 ~]# docker service scale nginx=1
nginx scaled to 1
[root@node1 ~]# docker service ps nginx     
ID                         NAME     IMAGE            NODE   DESIRED STATE  CURRENT STATE           ERROR
5et4bssqn7r1f4r20zbaishae  nginx.1  docker.io/nginx  node1  Running        Running 49 minutes ago  
ef2uqjk5ahni7vuzcsjnn0vxg  nginx.2  docker.io/nginx  node3  Shutdown       Shutdown 6 seconds ago  
[root@node1 ~]# docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
0w6j0cdz5scm36xrnq380ymek *  node1     Ready   Active        Leader
72lkynzdke93zbz9r6wobvh7z    node3     Ready   Active        
9tkkcbrwustuqvibm3v9j8qbn    node2     Ready   Active

[root@node1 ~]# curl -I node1       #在集群中，访问任何一个成员节点均可访问到服务（轮询）
HTTP/1.1 200 OK
Server: nginx/1.13.8
Date: Sat, 30 Dec 2017 17:07:10 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 26 Dec 2017 11:11:22 GMT
Connection: keep-alive
ETag: "5a422e5a-264"
Accept-Ranges: bytes

[root@node1 ~]# curl -I node2
HTTP/1.1 200 OK
Server: nginx/1.13.8
Date: Sat, 30 Dec 2017 17:07:12 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 26 Dec 2017 11:11:22 GMT
Connection: keep-alive
ETag: "5a422e5a-264"
Accept-Ranges: bytes

[root@node1 ~]# curl -I node3
HTTP/1.1 200 OK
Server: nginx/1.13.8
Date: Sat, 30 Dec 2017 17:07:13 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 26 Dec 2017 11:11:22 GMT
Connection: keep-alive
ETag: "5a422e5a-264"
Accept-Ranges: bytes

# 注：
# swarm集群的service端口暴露有如下特性:
# 公共的端口会暴露在每个swarm集群的每个服务节点上，并且请求进入公共端口后会负载均衡到所有的sevice实例上
# 
# swarm集群负载均衡service有两种方式
# 	VIP： 每个service会得到一个virtual IP地址作为服务请求的入口。基于virtual IP进行负载均衡.
# 	DNSRR:  service利用DNS解析来进行负载均衡, 这种模式在旧的Docker Engine下, 经常行为诡异…所以不推荐
# 	
# 	指定一个service的模式, 可在创建service的时使用如下命令:
# 	docker service create --endpoint-mode [vip|dnssrr] <service name>
# 
# 	修改一个service的模式, 使用如下命令:
# 	docker service update --endpoint-mode [vip|dnssrr] <service name>
```
#### 查看服务使用的vip ( 摘 )
```bash
[root@swarm-manager ~]#  docker service inspect --format='{{.Endpoint.VirtualIPs}}'   my-web
[{aoqs3p835s5glx69hi46ou2dw 10.0.9.2/24}]
```
