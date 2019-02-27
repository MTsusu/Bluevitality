[root@node1 ~]# docker images
REPOSITORY                             TAG                 IMAGE ID            CREATED             SIZE
docker.io/nginx                        latest              3f8a4339aadd        2 weeks ago         108.5 MB
gcr.io/google_containers/pause-amd64   3.0                 8d8e47347197        20 months ago       746.9 kB
[root@node1 ~]# kubectl run nginx --image=nginx:latest --replicas=1     #最简单的启动1个pod的方式
deployment "nginx" created
[root@node1 ~]# kubectl get rs                                          #查看ReplicaSets
NAME               DESIRED   CURRENT   READY     AGE
nginx-1984600839   1         1         1         7s
[root@node1 ~]# kubectl get pods -o wide --namespace=default            #查看Pod ( or : --all-namespaces)
NAME                     READY     STATUS    RESTARTS   AGE       IP              NODE
nginx-1984600839-d7s3t   1/1       Running   0          17m       192.168.0.130   node1
[root@node1 ~]# kubectl get pods -o yaml                                #以YAML格式输出Pod的详细信息
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      kubernetes.io/created-by: |
        {"kind":"SerializedReference","apiVersion":"v1","reference":{"kind":"ReplicaSet","namespace":"default",
        "name":"nginx-1984600839","uid":"bacd0be6-fa17-11e7-9d3b-000c29cdc3b7","apiVersion":
        "extensions","resourceVersion":"9119"}}
    creationTimestamp: 2018-01-15T17:15:48Z
    generateName: nginx-1984600839-
    labels:
      pod-template-hash: "1984600839"
      run: nginx
    name: nginx-1984600839-d7s3t
    namespace: default
    ownerReferences:
    .............................(略)
[root@node1 ~]# kubectl get pods -o=custom-columns=LABELS:.metadata.creationTimestamp   #指定从Pod中获取的信息
LABELS
2018-01-15T17:15:48Z
[root@node1 ~]# kubectl get namespace                                   #获取Namespace信息
NAME          STATUS   AGE
default       Active    18d
kube-system   Active    18d
[root@node1 ~]# kubectl get service                                     #查看service
NAME         CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes   192.168.0.1   <none>        443/TCP   18d
[root@node1 ~]# kubectl get nodes                                       #查看nodes
NAME      STATUS    AGE
node1     Ready     18d
node2     Ready     18d
[root@node1 ~]# kubectl describe pod nginx                              #查看pod详细信息（resource集群相关的信息）
Name:           nginx-1984600839-d7s3t
Namespace:      default
Node:           node1/192.168.0.3
Start Time:     Tue, 16 Jan 2018 01:15:48 +0800
Labels:         pod-template-hash=1984600839
                run=nginx
Status:         Running
IP:             192.168.0.130
Controllers:    ReplicaSet/nginx-1984600839
Containers:
  nginx:
    Container ID:               docker://f16329408b3026069a180bbaa9e505168b11cdc6fa2c830fac09533e9882c756
    Image:                      nginx:latest
    Image ID:                   dockerpullable://docker.io/nginx@sha256:285b49d42c70......(略)
    Port:
    State:                      Running
      Started:                  Tue, 16 Jan 2018 01:15:52 +0800
    Ready:                      True
    Restart Count:              0
    Volume Mounts:              <none>
    Environment Variables:      <none>
Conditions:
  Type          Status
  Initialized   True 
  Ready         True 
  PodScheduled  True 
No volumes.
QoS Class:      BestEffort
Tolerations:    <none>
Events:
  FirstSeen     LastSeen        Count   From                    SubObjectPath           Type            Reason                  Message
  ---------     --------        -----   ----                    -------------           --------        ------                  -------
  58s           58s             1       {default-scheduler }                            Normal          Scheduled               Successfully assigned nginx-1984600839-d7s3t to node1
  58s           58s             1       {kubelet node1}         spec.containers{nginx}  Normal          Pulling                 pulling image "nginx:latest"
  58s           54s             2       {kubelet node1}                                 Warning         MissingClusterDNS       kubelet does not have ClusterDNS IP configured and cannot create Pod using "ClusterFirst" policy. Falling back to DNSDefault policy.
  54s           54s             1       {kubelet node1}         spec.containers{nginx}  Normal          Pulled                  Successfully pulled image "nginx:latest"
  54s           54s             1       {kubelet node1}         spec.containers{nginx}  Normal          Created                 Created container with docker id f16329408b30; Security:[seccomp=unconfined]
  54s           54s             1       {kubelet node1}         spec.containers{nginx}  Normal          Started                 Started container with docker id f16329408b30
[root@node1 ~]# etcdctl ls /k8s/network/subnets #查看已分配的 Pod 子网段列表
/k8s/network/subnets/192.168.58.0-24
/k8s/network/subnets/192.168.76.0-24
