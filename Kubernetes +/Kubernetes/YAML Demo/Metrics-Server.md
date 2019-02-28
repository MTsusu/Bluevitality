```txt
从 1.8 开始资源使用指标（如容器 CPU 和内存使用率）通过 Metrics API 在 Kubernetes 中获取
metrics-server替代了heapster。Metrics-Server实现了Resource Metrics API，是集群范围资源使用数据的聚合器
Metrics-Server从每个节点上的 Kubelet 公开的 Summary API 中采集指标信息
Metrics API 只可查询当前的度量数据，并不保存历史数据。URI为: /apis/metrics.k8s.io/，在 k8s.io/metrics 维护
```
#### 部署
```bash

[root@master ~]# vim metrics-server-csr.json   #创建 metrics-server 使用的证书
{
  "CN": "aggregator",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}

[root@master ~]# cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
 -ca-key=/etc/kubernetes/ssl/ca-key.pem \ 
 -config=/opt/ssl/config.json \
 -profile=kubernetes metrics-server-csr.json | cfssljson -bare metrics-server

#将生成的证书拷贝到所有node和master节点
[root@master ~]# cp metrics-server*.pem /etc/kubernetess/ssl/
[root@master ~]# scp metrics-server*.pem  192.168.1.8:/etc/kubernetess/ssl/

[root@master ~]# git clone https://github.com/kubernetes-incubator/metrics-server && cd metrics-server/deploy/1.8+
[root@master ~]# vim metrics-server-deployment.yaml   #此配置文件需要先修改后执行 ( 另外还有其他配置文件，暂时使用默认即可 )
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:  # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        image: mirrorgooglecontainers/metrics-server-amd64:v0.3.1
        imagePullPolicy: Always
        command:
        - /metrics-server
        - --kubelet-insecure-tls                #添加参数
        - --kubelet-preferred-address-types=InternalIP    #添加参数
        #- --tls-cert-file=
        #- --tls-private-key-file=
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
#注释：
# 1、metrics默认用hostname来通信，而且coredns中已经添加了宿主机的/etc/resolv.conf 
# 所以只需要添加一个内部的dns服务器或者在pod的deployment的yaml手动添加主机解析记录,再或者改变参数为InternalIP，直接用ip来连接
# 2、kubelet-insecure-tls: 跳过验证kubelet的ca证书，暂时开启。（不推荐用于生产环境）

#修改apiserver配置文件，加入如下启动参数来启用aggregation layer ( 修改 K8S 控制平面组件的配置以支持 metrics-server )
  --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --requestheader-extra-headers-prefix=X-Remote-Extra- \
  --requestheader-group-headers=X-Remote-Group \
  --requestheader-username-headers=X-Remote-User \
  --proxy-client-cert-file=/etc/kubernetes/ssl/metrics-server.pem \
  --proxy-client-key-file=/etc/kubernetes/ssl/metrics-server-key.pem \
  --runtime-config=api/all=true
#--requestheader-XXX、--proxy-client-XXX:
#     是 kube-apiserver 的 aggregator layer 相关的配置参数，metrics-server & HPA 需要使用；
#--requestheader-client-ca-file：
#     用于签名 --proxy-client-cert-file 和 --proxy-client-key-file 指定的证书；在启用了 metric aggregator 时使用；
#如果 kube-apiserver 机器没有运行 kube-proxy，则还需要添加 --enable-aggregator-routing=true 参数
#注意 requestheader-client-ca-file 指定的 CA 证书，必须具有 client auth and server auth

#对kube-controller-manager添加如下配置参数：
#--horizontal-pod-autoscaler-use-rest-clients=true   #用于配置 HPA 控制器使用 REST 客户端获取 metrics 数据

#执行
[root@master ~]# kubectl apply  .
```

#### 查看APIServer资源
```bash
[root@master metrics]# kubectl api-versions
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1
apiregistration.k8s.io/v1beta1
apps/v1 apps/v1beta1
apps/v1beta2 authentication.k8s.io/v1 
authentication.k8s.io/v1beta1 
authorization.k8s.io/v1 
authorization.k8s.io/v1beta1 
autoscaling/v1 
autoscaling/v2beta1 
batch/v1 
batch/v1beta1 
certificates.k8s.io/v1beta1 
crd.projectcalico.org/v1 
events.k8s.io/v1beta1 
extensions/v1beta1 
metrics.k8s.io/v1beta1  #metrics控制器，有说明成功 
networking.k8s.io/v1 
policy/v1beta1 
rbac.authorization.k8s.io/v1 
rbac.authorization.k8s.io/v1beta1 
scheduling.k8s.io/v1beta1 
storage.k8s.io/v1 
```

#### 查看
```bash
[root@master metrics]# kubectl get pods -n kube-system 
NAME                                    READY     STATUS    RESTARTS   AGE
coredns-78fcdf6894-cj6tn                1/1       Running   42         26d
coredns-78fcdf6894-wfvk8                1/1       Running   42         26d
elasticsearch-logging-0                 1/1       Running   45         4d
elasticsearch-logging-1                 1/1       Running   47         4d
etcd-master                             1/1       Running   42         26d
grafana-7f8bcdfbbf-qzln5                1/1       Running   4          13d
kibana-logging-7444956bf8-x8qqd         1/1       Running   2          4d
kube-apiserver-master                   1/1       Running   47         26d
kube-controller-manager-master          1/1       Running   43         26d
kube-flannel-ds-m4f4j                   1/1       Running   33         26d
kube-flannel-ds-xvssj                   1/1       Running   18         26d
kube-proxy-5lw6z                        1/1       Running   39         26d
kube-proxy-qlhg7                        1/1       Running   18         26d
kube-scheduler-master                   1/1       Running   39         26d
kubernetes-dashboard-767dc7d4d-4bt48    1/1       Running   5          5d
metrics-server-v0.2.1-84678c956-hbz2b   2/2       Running   0          2m   #<-----

#Master新开一个反向代理端口
[root@master ~]# kubectl proxy --port=8080
Starting to serve on 127.0.0.1:8080
[root@master ~]# curl http://localhost:8080/apis/metrics.k8s.io/v1beta1/nodes
{
  "kind": "NodeMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {
    "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes"
  },
  "items": [
    {
      "metadata": {
        "name": "master",
        "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/master",
        "creationTimestamp": "2018-09-25T09:48:21Z"
      },
      "timestamp": "2018-09-25T09:48:00Z",
      "window": "1m0s",
      "usage": {
        "cpu": "211m",
        "memory": "2905388Ki"
      }
    },
    {
      "metadata": {
        "name": "node01",
        "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/node01",
        "creationTimestamp": "2018-09-25T09:48:21Z"
      },
      "timestamp": "2018-09-25T09:48:00Z",
      "window": "1m0s",
      "usage": {
        "cpu": "150m",
        "memory": "3670276Ki"
      }
    }
  ]

#测试是否安装成功
[root@master metrics]# kubectl top nodes
error: metrics not available yet    #说明还未成功，需要等会

[root@master metrics]# kubectl top node
NAME      CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%   
master    207m         10%       2832Mi          76%       
node01    144m         4%        3619Mi          37%

[root@master metrics]# kubectl top pods -n kube-system
NAME                                    CPU(cores)   MEMORY(bytes)   
coredns-78fcdf6894-cj6tn                2m           11Mi            
coredns-78fcdf6894-wfvk8                1m           11Mi            
elasticsearch-logging-0                 6m           1347Mi          
elasticsearch-logging-1                 6m           1326Mi          
etcd-master                             17m          84Mi            
grafana-7f8bcdfbbf-qzln5                0m           21Mi            
kibana-logging-7444956bf8-x8qqd         4m           83Mi            
kube-apiserver-master                   89m          486Mi           
kube-controller-manager-master          19m          59Mi            
kube-flannel-ds-m4f4j                   5m           14Mi            
kube-flannel-ds-xvssj                   5m           12Mi            
kube-proxy-5lw6z                        3m           15Mi            
kube-proxy-qlhg7                        3m           16Mi            
kube-scheduler-master                   6m           13Mi            
kubernetes-dashboard-767dc7d4d-4bt48    0m           11Mi            
metrics-server-v0.2.1-84678c956-hbz2b   1m           24Mi 
```