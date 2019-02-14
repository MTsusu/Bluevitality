###### kubectl --help 
```txt
kubectl annotate – 更新资源的注解。
kubectl api-versions – 以“组/版本”的格式输出服务端支持的API版本。
kubectl apply – 通过文件名或控制台输入，对资源进行配置。
kubectl attach – 连接到一个正在运行的容器。
kubectl autoscale – 对replication controller进行自动伸缩。
kubectl cluster-info – 输出集群信息。
kubectl config – 修改kubeconfig配置文件。
kubectl create – 通过文件名或控制台输入，创建资源。
kubectl delete – 通过文件名、控制台输入、资源名或者label selector删除资源。
kubectl describe – 输出指定的一个/多个资源的详细信息。
kubectl edit – 编辑服务端的资源。
kubectl exec – 在容器内部执行命令。
kubectl expose – 输入replication controller，service或者pod，并将其暴露为新的kubernetes service。
kubectl get – 输出一个/多个资源。
kubectl label – 更新资源的label。
kubectl logs – 输出pod中一个容器的日志。
kubectl namespace -（已停用）设置或查看当前使用的namespace。
kubectl patch – 通过控制台输入更新资源中的字段。
kubectl port-forward – 将本地端口转发到Pod。
kubectl proxy – 为Kubernetes API server启动代理服务器。
kubectl replace – 通过文件名或控制台输入替换资源。
kubectl rolling-update – 对指定的replication controller执行滚动升级。
kubectl run – 在集群中使用指定镜像启动容器。
kubectl scale – 为replication controller设置新的副本数。
kubectl stop – （已停用）通过资源名或控制台输入安全删除资源。
kubectl version – 输出服务端和客户端的版本信息。

kubectl get pods
kubectl get rc
kubectl get service
kubectl get componentstatuses
kubectl get endpoints
kubectl cluster-info
kubectl create -f redis-master-controller.yaml
kubectl delete -f redis-master-controller.yaml
kubectl delete pod nginx-772ai
kubectl logs -f pods/heapster-xxxxx -n kube-system #查看日志
kubectl scale rc redis-slave --replicas=3 #修改RC的副本数量，来实现Pod的动态缩放

etcdctl cluster-health #检查网络集群健康状态
etcdctl --endpoints=https://192.168.71.221:2379 cluster-health #带有安全认证检查网络集群健康状态
etcdctl member list
etcdctl set /k8s/network/config '{ "Network": "10.1.0.0/16" }'
etcdctl get /k8s/network/config

kubectl get services kubernetes-dashboard -n kube-system #查看所有service
kubectl get deployment kubernetes-dashboard -n kube-system #查看所有发布
kubectl get pods --all-namespaces #查看所有pod
kubectl get pods -o wide --all-namespaces #查看所有pod的IP及节点
kubectl get pods -n kube-system | grep dashboard
kubectl describe service/kubernetes-dashboard --namespace="kube-system"
kubectl describe pods/kubernetes-dashboard-349859023-g6q8c --namespace="kube-system" #指定类型查看
kubectl describe pod nginx-772ai #查看pod详细信息
kubectl scale rc nginx --replicas=5 # 动态伸缩
kubectl scale deployment redis-slave --replicas=5 #动态伸缩
kubectl scale --replicas=2 -f redis-slave-deployment.yaml #动态伸缩
kubectl exec -it redis-master-1033017107-q47hh /bin/bash #进入容器
kubectl label nodes node1 zone=north #增加节点lable值 spec.nodeSelector: zone: north #指定pod在哪个节点
kubectl get nodes -lzone #获取zone的节点
kubectl label pod redis-master-1033017107-q47hh role=master #增加lable值 [key]=[value]
kubectl label pod redis-master-1033017107-q47hh role- #删除lable值
kubectl label pod redis-master-1033017107-q47hh role=backend --overwrite #修改lable值
kubectl rolling-update redis-master -f redis-master-controller-v2.yaml #配置文件滚动升级
kubectl rolling-update redis-master --image=redis-master:2.0 #命令升级
kubectl rolling-update redis-master --image=redis-master:1.0 --rollback #pod版本回滚

--alsologtostderr[=false]: 同时输出日志到标准错误控制台和文件。
--api-version="": 和服务端交互使用的API版本。
--certificate-authority="": 用以进行认证授权的.cert文件路径。
--client-certificate="": TLS使用的客户端证书路径。
--client-key="": TLS使用的客户端密钥路径。
--cluster="": 指定使用的kubeconfig配置文件中的集群名。
--context="": 指定使用的kubeconfig配置文件中的环境名。
--insecure-skip-tls-verify[=false]: 如果为true，将不会检查服务器凭证的有效性，这会导致你的HTTPS链接变得不安全。
--kubeconfig="": 命令行请求使用的配置文件路径。
--log-backtrace-at=:0: 当日志长度超过定义的行数时，忽略堆栈信息。
--log-dir="": 如果不为空，将日志文件写入此目录。
--log-flush-frequency=5s: 刷新日志的最大时间间隔。
--logtostderr[=true]: 输出日志到标准错误控制台，不输出到文件。
--match-server-version[=false]: 要求服务端和客户端版本匹配。
--namespace="": 如果不为空，命令将使用此namespace。
--password="": API Server进行简单认证使用的密码。
-s, --server="": Kubernetes API Server的地址和端口号。
--stderrthreshold=2: 高于此级别的日志将被输出到错误控制台。
--token="": 认证到API Server使用的令牌。
--user="": 指定使用的kubeconfig配置文件中的用户名。
--username="": API Server进行简单认证使用的用户名。
--v=0: 指定输出日志的级别。
--vmodule=: 指定输出日志的模块，格式如下：pattern=N，使用逗号分隔。
```
```txt
# 查看集群信息
kubectl cluster-info

# 查看各组件信息
kubectl -s http://localhost:8080 get componentstatuses

# 查看pods所在的运行节点
kubectl get pods -o wide

# 创建带有端口映射的pod
kubectl run mynginx --image=nginx --port=80 --hostport=8000

# 创建带有终端的pod：
kubectl run -i --tty busybox --image=busybox

# 查看pods定义的详细信息
kubectl get pods -o yaml

# 查看Replication Controller信息
kubectl get rc

# 查看service的信息
kubectl get service

# 查看节点信息
kubectl get nodes

# 按selector名来查找pod
kubectl get pod --selector name=redis

# 查看运行的pod的环境变量
kubectl exec pod名 env

# 创建
kubectl create -f 文件名

# 重建
kubectl replace -f 文件名  [--force]

# 删除
kubectl delete -f  <文件名>
kubectl delete pod <pod名》
kubectl delete rc  <rc名>
kubectl delete service <service名>
kubectl delete pod --all
```
#### 部分子命令说明
```txt
replace：
    用于对已有资源进行更新、替换。如前面create中创建的nginx
    当需更新resource的属性时，如修改副本数，增加、修改label，更改image版本，端口等都可直接修改原yaml然后执行replace 
    需要注意的是名字不能被更新。另外若是更新label则原有标签的pod将会与更新label后的rc断开联系!
    有新label的rc将会创建指定副本数的新的pod但默认并不会删除原来的pod。所以此时如果使用get pods将会发现pod数翻倍
    进一步check会发现原来的pod已不会被新rc控制，此处只介绍命令不详谈此问题。 
    [root@node1 ~]# kubectl replace -f rc-nginx.yaml

patch：
    若1个容器已经在运行，此时需对一些容器属性进行修改又不想删除容器，或不方便通过replace的方式进行更新。
    k8s还提供了一种在容器运行时直接对容器进行修改的方式，就是patch... 
    假如创建pod的label是app=nginx-2，如果在运行过程中需要把其label改为app=nginx-3这patch命令如下： 
    [root@node1 ~]# kubectl patch pod nginx -p '{"metadata":{"labels":{"app":"nginx-3"}}}'  

edit：
    edit提供了另1种更新resource源的操作，通过edit能灵活的在1个common的resource基础上发展出更多的significant resource
    例如，使用edit直接更新前面创建的pod的命令为： 
    [root@node1 ~]# kubectl edit po rc-nginx-btv4j   
    上面命令的效果等效于： 
    [root@node1 ~]# kubectl get po rc-nginx-btv4j -o yaml >> /tmp/nginx-tmp.yaml   
    [root@node1 ~]# vim /tmp/nginx-tmp.yaml
    [root@node1 ~]# kubectl replace -f /tmp/nginx-tmp.yaml   
            
Delete：
    根据resource名或label删除resource
    [root@node1 ~]# kubectl delete -f rc-nginx.yaml   
    [root@node1 ~]# kubectl delete po rc-nginx-btv4j   
    [root@node1 ~]# kubectl delete po -lapp=nginx-2 

apply：
    apply命令提供了比patch，edit等更严格的更新resource的方式
    通过它可以将resource的configuration使用source control的方式维护在版本库中...
    每次有更新时，将配置文件push到server然后使用kubectl apply将更新应用到resource
    k8s在引用更新前将当前配置文件同已应用的配置比较并只更新更改的部分而不会主动更改任何用户未指定的部分 
    apply的使用方式同replace相同，不同的是apply不会删除原有resource然后创建新的
    apply直接在原有resource基础上进行更新，同时还会在resource中添加1条注释，标记当前的apply。类似于git操作

logs：
    用于显示pod运行中，容器内程序输出到标准输出的内容。与docker的logs类似。如果要获得tail -f的方式则也可以使用"-f" 
    [root@node1 ~]# kubectl logs nginx
        
rolling-update：
    是非常重要的命令，它对已经部署并正在运行的业务提供了不中断业务的更新方式。
    rolling-update每次起1个新的pod，等新pod完全起来后删除1个旧的pod，然后再起1个新的pod替换旧的，直到替换掉所有pod 
    需注意的是，rolling-update需确保新的版本有不同的name，Version和label，否则会报错
    rolling-update还有很多其他选项提供丰富的功能，如—update-period指定间隔周期，使用时可以使用-h查看help信息 
    [root@node1 ~]# kubectl rolling-update nginx-2 -f nginx.yaml   
    如果在升级过程中，发现有问题还可以中途停止update并回滚到之前的版本: 
    [root@node1 ~]# kubectl rolling-update nginx-2 —rollback   

scale：    
    用于程序在负载加重或缩小时副本进行扩容或缩小，如前面创建的nginx有两个副本，可轻松的使用其对副本数进行扩容/缩容 
    扩展副本数到4：
    [root@node1 ~]# kubectl scale rc nginx-3 —replicas=4  
    重新缩减副本数到2：
    [root@node1 ~]# kubectl scale rc rc-nginx-3 —replicas=2 

autoscale：
    scale虽然能够很方便的对副本数进行扩展或缩小，但仍然需人工介入。不能实时自动根据系统负载对副本数进行扩容/缩容
    autoscale提供了自动根据pod负载对其副本进行扩缩的功能。 
    autoscale会给1个rc指定1个副本数的范围，在实际运行中根据pod中运行程序的负载自动在指定的范围内对pod进行扩容/缩容
    如前面创建的nginx，可以用如下命令指定副本范围在1~4 
    [root@node1 ~]# kubectl autoscale rc nginx-3 —min=1 —max=4   

exec：
    类似于docker的exec命令，为在已经运行的容器中执行一条shell命令
    如果一个pod容器中有多个容器，需要使用-c选项指定容器 

port-forward：
    转发一个本地端口到容器端口，作者一般都是使用yaml方式编排容器，所以基本不使用此命令

label：
     为k8s集群的resource打标签，如前面实例中提到的为rc打标签对rc分组。还可对nodes打标签
     这样在编排容器时可以为容器指定nodeSelector将容器调度到指定lable的机器上
     如果集群中有IO密集型，计算密集型的机器分组，可以将不同的机器打上不同标签，然后将不同特征的容器调度到不同分组上
     在1.2之前的版本中，使用kubectl get nodes则可以列出所有节点的信息，包括节点标签
     在1.2版本之后不再列出节点的标签信息，如果需要查看节点被打了哪些标签，需要使用describe查看节点的信息
```
###### kubectl --help
```txt
[root@node1 ~]# kubectl --version
Kubernetes v1.5.2

[root@node1 ~]# kubectl
kubectl controls the Kubernetes cluster manager. 

Find more information at https://github.com/kubernetes/kubernetes.

Basic Commands (Beginner):
  create         Create a resource by filename or stdin
  expose         Take a replication controller, service, deployment or pod and expose it as a new Kubernetes Service
  run            Run a particular image on the cluster
  set            Set specific features on objects

Basic Commands (Intermediate):
  get            Display one or many resources
  explain        Documentation of resources
  edit           Edit a resource on the server
  delete         Delete resources by filenames, stdin, resources and names, or by resources and label selector

Deploy Commands:
  rollout        Manage a deployment rollout
  rolling-update Perform a rolling update of the given ReplicationController
  scale          Set a new size for a Deployment, ReplicaSet, Replication Controller, or Job
  autoscale      Auto-scale a Deployment, ReplicaSet, or ReplicationController

Cluster Management Commands:
  certificate    Modify certificate resources.
  cluster-info   Display cluster info
  top            Display Resource (CPU/Memory/Storage) usage
  cordon         Mark node as unschedulable
  uncordon       Mark node as schedulable
  drain          Drain node in preparation for maintenance
  taint          Update the taints on one or more nodes

Troubleshooting and Debugging Commands:
  describe       Show details of a specific resource or group of resources
  logs           Print the logs for a container in a pod
  attach         Attach to a running container
  exec           Execute a command in a container
  port-forward   Forward one or more local ports to a pod
  proxy          Run a proxy to the Kubernetes API server
  cp             Copy files and directories to and from containers.

Advanced Commands:
  apply          Apply a configuration to a resource by filename or stdin
  patch          Update field(s) of a resource using strategic merge patch
  replace        Replace a resource by filename or stdin
  convert        Convert config files between different API versions

Settings Commands:
  label          Update the labels on a resource
  annotate       Update the annotations on a resource
  completion     Output shell completion code for the given shell (bash or zsh)

Other Commands:
  api-versions   Print the supported API versions on the server, in the form of "group/version"
  config         Modify kubeconfig files
  help           Help about any command
  version        Print the client and server version information

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).

[root@node1 ~]# kubectl --help
Kubernetes command line client

Usage:
  Kubernetes command line client [flags]

Available Flags:
      --allow-verification-with-non-compliant-keys   Allow a SignatureVerifier to use keys which are technically non-compliant with RFC6962.
      --alsologtostderr                              log to standard error as well as files
      --application-metrics-count-limit int          Max number of application metrics to store (per container) (default 100)
      --as string                                    Username to impersonate for the operation
      --azure-container-registry-config string       Path to the file container Azure container registry configuration information.
      --boot-id-file string                          Comma-separated list of files to check for boot-id. Use the first one that exists. (default "/proc/sys/kernel/random/boot_id")
      --certificate-authority string                 Path to a cert. file for the certificate authority
      --client-certificate string                    Path to a client certificate file for TLS
      --client-key string                            Path to a client key file for TLS
      --cluster string                               The name of the kubeconfig cluster to use
      --container-hints string                       location of the container hints file (default "/etc/cadvisor/container_hints.json")
      --context string                               The name of the kubeconfig context to use
      --docker string                                docker endpoint (default "unix:///var/run/docker.sock")
      --docker-env-metadata-whitelist string         a comma-separated list of environment variable keys that needs to be collected for docker containers
      --docker-only                                  Only report docker containers in addition to root stats
      --docker-root string                           DEPRECATED: docker root is read from docker info (this is a fallback, default: /var/lib/docker) (default "/var/lib/docker")
      --enable-load-reader                           Whether to enable cpu load reader
      --event-storage-age-limit string               Max length of time for which to store events (per type). Value is a comma separated list of key values, where the keys are event types (e.g.: creation, oom) or "default" and the value is a duration. Default is applied to all non-specified event types (default "default=0")
      --event-storage-event-limit string             Max number of events to store (per type). Value is a comma separated list of key values, where the keys are event types (e.g.: creation, oom) or "default" and the value is an integer. Default is applied to all non-specified event types (default "default=0")
      --global-housekeeping-interval duration        Interval between global housekeepings (default 1m0s)
      --google-json-key string                       The Google Cloud Platform Service Account JSON Key to use for authentication.
  -h, --help                                         help for hyperkube
      --housekeeping-interval duration               Interval between container housekeepings (default 10s)
      --insecure-skip-tls-verify                     If true, the server's certificate will not be checked for validity. This will make your HTTPS connections insecure
      --ir-data-source string                        Data source used by InitialResources. Supported options: influxdb, gcm. (default "influxdb")
      --ir-dbname string                             InfluxDB database name which contains metrics required by InitialResources (default "k8s")
      --ir-hawkular string                           Hawkular configuration URL
      --ir-influxdb-host string                      Address of InfluxDB which contains metrics required by InitialResources (default "localhost:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:api")
      --ir-namespace-only                            Whether the estimation should be made only based on data from the same namespace.
      --ir-password string                           Password used for connecting to InfluxDB (default "root")
      --ir-percentile int                            Which percentile of samples should InitialResources use when estimating resources. For experiment purposes. (default 90)
      --ir-user string                               User used for connecting to InfluxDB (default "root")
      --kubeconfig string                            Path to the kubeconfig file to use for CLI requests.
      --log-backtrace-at traceLocation               when logging hits line file:N, emit a stack trace (default :0)
      --log-cadvisor-usage                           Whether to log the usage of the cAdvisor container
      --log-dir string                               If non-empty, write log files in this directory
      --log-flush-frequency duration                 Maximum number of seconds between log flushes (default 5s)
      --logtostderr                                  log to standard error instead of files (default true)
      --machine-id-file string                       Comma-separated list of files to check for machine-id. Use the first one that exists. (default "/etc/machine-id,/var/lib/dbus/machine-id")
      --match-server-version                         Require server version to match client version
  -n, --namespace string                             If present, the namespace scope for this CLI request
      --password string                              Password for basic authentication to the API server
      --request-timeout string                       The length of time to wait before giving up on a single server request. Non-zero values should contain a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means don't timeout requests. (default "0")
  -s, --server string                                The address and port of the Kubernetes API server
      --stderrthreshold severity                     logs at or above this threshold go to stderr (default 2)
      --storage-driver-buffer-duration duration      Writes in the storage driver will be buffered for this duration, and committed to the non memory backends as a single transaction (default 1m0s)
      --storage-driver-db string                     database name (default "cadvisor")
      --storage-driver-host string                   database host:port (default "localhost:8086")
      --storage-driver-password string               database password (default "root")
      --storage-driver-secure                        use secure connection with database
      --storage-driver-table string                  table name (default "stats")
      --storage-driver-user string                   database username (default "root")
      --token string                                 Bearer token for authentication to the API server
      --user string                                  The name of the kubeconfig user to use
      --username string                              Username for basic authentication to the API server
  -v, --v Level                                      log level for V logs
      --version version[=true]                       Print version information and quit
      --vmodule moduleSpec                           comma-separated list of pattern=N settings for file-filtered logging
```
