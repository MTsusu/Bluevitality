#### 使用 kubectl 配置 ~/.kube/config
```bash
kubectl config set-cluster development \
--server=https://1.2.3.4 --certificate-authority=fake-ca-file       #添加集群及其对应的公钥

kubectl config set-cluster scratch \
--server=https://5.6.7.8 --insecure-skip-tls-verify                 #

kubectl config set-credentials developer \
--client-certificate=fake-cert-file --client-key=fake-key-seefile   #将用户详细信息添加到配置文件

kubectl config set-credentials experimenter \
--username=exp --password=some-password                             #

#添加上下文信息
kubectl config set-context dev-frontend \
--cluster=development --namespace=frontend --user=developer         #上下文主要定义用户与集群及命名空间的绑定关系

kubectl config set-context dev-storage --cluster=development --namespace=storage --user=developer
kubectl config set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter

kubectl config use-context dev-frontend     #使用名为exp-scratch的上下文

kubectl config  view                        #查看 ~/.kube/config 信息
```
#### ~/.kube/config
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: fake-ca-file     #集群证书
    server: https://1.2.3.4                 #集群地址
  name: development                         #为集群定义的标识
- cluster:
    #insecure-skip-tls-verify: true         #是否跳过TLS认证
    server: https://5.6.7.8
  name: scratch
contexts:
- context:                                  #上下文
    cluster: development                    #与此上下文关联的集群名称
    namespace: frontend                     #与此上下文关联的集群命名空间
    user: developer                         #与此上下文关联的用户名
  name: dev-frontend                        #上下文标识
- context:
    cluster: development
    namespace: storage
    user: developer
  name: dev-storage
- context:
    cluster: scratch
    namespace: default
    user: experimenter
  name: exp-scratch
current-context: dev-frontend               #当前默认使用的上下文
kind: Config
preferences: {}
users:
- name: developer                           #用户名称
  user:
    client-certificate: fake-cert-file      #用户证书（此证书需要事先使用APIserver端的私钥对其进行签名后生成）
    client-key: fake-key-file               #用户私钥
- name: experimenter  
  user:
    password: some-password
    username: exp
```
#### 基于 "RBAC" 的: 认证 授权 准入控制
```bash
#RoleBinding 把角色映射到用户从而让这些用户继承角色在 namespace 中的权限
#ClusterRoleBinding 让用户继承 ClusterRole 在整个集群中的权限
#系统角色 "System Roles" 很容易识别，一般具有前缀 "system:"

➜  kubectl get clusterroles -n kube-system
NAME                    KIND
admin                   ClusterRole.v1beta1.rbac.authorization.k8s.io
cluster-admin           ClusterRole.v1beta1.rbac.authorization.k8s.io
edit                    ClusterRole.v1beta1.rbac.authorization.k8s.io
kubelet-api-admin       ClusterRole.v1beta1.rbac.authorization.k8s.io
system:auth-delegator   ClusterRole.v1beta1.rbac.authorization.k8s.io
system:basic-user       ClusterRole.v1beta1.rbac.authorization.k8s.io
system:controller:attachdetach-controller ClusterRole.v1beta1.rbac.authorization.k8s.io
system:controller:certificate-controller ClusterRole.v1beta1.rbac.authorization.k8s.io

#创建用户
[root@master1 ~]# ls /etc/kubernetes/pki/       #需要用到APIServer自有的CA私钥进行签名
apiserver.crt                 ca-config.json  devuser-csr.json    front-proxy-ca.key      sa.pub
apiserver.key                 ca.crt          devuser-key.pem     front-proxy-client.crt
apiserver-kubelet-client.crt  ca.key          devuser.pem         front-proxy-client.key
apiserver-kubelet-client.key  devuser.csr     front-proxy-ca.crt  sa.key

#创建ca-config.json文件
[root@master1 ~]# cat > ca-config.json <<EOF   
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

#用户名从CN上获取。 组从O上获取（用户或者组用于后面的角色绑定）
[root@master1 ~]# cat > devuser-csr.json <<EOF 
{
  "CN": "devuser",
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
EOF

#生成user的证书：( 将生成如下文件：devuser.csr devuser-key.pem devuser.pem )
[root@master1 ~]# cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json \
-profile=kubernetes devuser-csr.json | cfssljson -bare devuser
#校验证书：cfssl-certinfo -cert kubernetes.pem

#生成config文件（使用现成的admin.conf来进行部分的配置修改）
cp /etc/kubernetes/admin.conf devuser.kubeconfig
#设置客户端认证参数:
kubectl config set-credentials devuser \
--client-certificate=/etc/kubernetes/ssl/devuser.pem \
--client-key=/etc/kubernetes/ssl/devuser-key.pem \
--embed-certs=true --kubeconfig=devuser.kubeconfig
#设置上下文参数：
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=devuser \
--namespace=kube-system \
--kubeconfig=devuser.kubeconfig
#设置默认上下文：
kubectl config use-context kubernetes --kubeconfig=devuser.kubeconfig

#cluster:   集群信息，包含集群地址与公钥
#user:      用户信息，客户端证书与私钥，正真的信息是从证书里读取出来的，人能看到的只是给人看的。
#context:   维护三元组：namespace cluster 与 user

#创建一个标识为"pod-reader"的角色 ( 执行：kubectl create -f pod-reader.yaml )
[root@master1 ~]# cat pod-reader.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: kube-system
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

#创建角色绑定，将上面创建的pod-reader角色绑定到使用CFSSL生成的devuser用户上：
[root@master1 ~]# cat devuser-role-bind.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: kube-system
subjects:
- kind: User
  name: devuser   # 目标用户
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader  # 角色信息
  apiGroup: rbac.authorization.k8s.io
#执行：kubectl create -f devuser-role-bind.yaml

#使用新的config文件：
[root@master1 ~]# cp -f devuser.kubeconfig .kube/config

#效果, 已没有别的namespace的权限了，也不能访问node信息了：
[root@master1 ~]# kubectl get node
Error from server (Forbidden): nodes is forbidden: User "devuser" cannot list nodes at the cluster scope

[root@master1 ~]# kubectl get pod -n kube-system
NAME                                       READY     STATUS    RESTARTS   AGE
calico-kube-controllers-55449f8d88-74x8f   1/1       Running   0          8d
calico-node-clpqr                          2/2       Running   0          8d
kube-apiserver-master1                     1/1       Running   2          8d
kube-controller-manager-master1            1/1       Running   1          8d
kube-dns-545bc4bfd4-p6trj                  3/3       Running   0          8d
kube-proxy-tln54                           1/1       Running   0          8d
kube-scheduler-master1                     1/1       Running   1          8d
```
#### 使用 Secret 传递加密信息及私有仓库验证信息
```yaml
#方式一：
#定义私有仓库验证时使用的对象信息
kubectl create secret docker-registry kubesystemsecret -n kube-system \
--docker-server=1.2.3.4:8123 --docker-username=admin --docker-password=admin123 --docker-email=xx@xxx.com
################
apiVersion: v1
kind: Pod
metadata:
  name: secret-envars-test-pod
spec:
  containers:
  - name: envars-test-container
    image: 10.30.30.126:8123/library/nginx:latest
    env:
    - name: SECRET_USERNAME         #变量名称
      valueFrom:
        secretKeyRef:
          name: opaque              #opaque即进行模糊处理
          key: username             #值
    - name: SECRET_PASSWORD         #
      valueFrom:
        secretKeyRef:
          name: opaque              #
          key: password             #
  imagePullSecrets:
  - name: kubesystemsecret          #拉取时携带的认证信息 (调用 docker-registry 资源的 kubesystemsecret 对象)

#查看环境变量信息：kubectl exec -it secret-envars-test-pod -- /bin/bash -c "printenv"
SECRET_USERNAME=admin
SECRET_PASSWORD=admin123

#方式二：
#先将变量使用Base64进行编码方式的加密:
echo -n admin| base64  >> YWRtaW4=
echo -n admin123 | base64  >> YWRtaW4xMjM=
#以上操作可以改为如下的命令行方式进行：
kubectl create secret generic mysecret --from-literal=username=admin --from-literal=password=admin123

#将编码信息写入 "secret.yaml" 并执行 kubectl create -f secret.yaml ( 使用 kubectl create secret 则直接忽略此步骤)
apiVersion: v1
kind: Secret
metadata:
    name: mysecret
type: Opaque
data:
    password: YWRtaW4xMjM=
    username: YWRtaW4=

#cat nginx-mount.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
spec:
  containers:
    - name: test-container
      image: 10.30.30.126:8123/library/nginx:latest
      volumeMounts:
          - name: secret-volume             #调用volumes中定义的secret-volume标识
            mountPath: /etc/secret-volume   #Secret资源中的值会以文件形式存在于/etc/secret-volume下 (文件名是key)
  imagePullSecrets:
    - name: kubesystemsecret                #拉取镜像时携带的认证信息
  volumes:
    - name: secret-volume                   #对volumes资源定义的secret-volume标识
      secret:
        secretName: mysecret                #调用secret资源下的mysecret对象，其携带了username/password变量

#验证执行：kubectl exec secret-test-pod cat /etc/secret-volume/password  -->>  将输出： admin123
```
#### 创建私有仓库
```bash
#第一种方式：
#创建secret的docker-registry对象
kubectl create secret docker-registry myregistrykey --docker-server=DOCKER_REGISTRY_SERVER \
--docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
#查看信息是否生成
kubectl get secrets myregistrykey
#Pod.yaml中：
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: myregistrykey

#第二种方式：
创建secret的docker-registry对象
kubectl create secret docker-registry myregistrykey --docker-server=DOCKER_REGISTRY_SERVER \
--docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
#查看信息是否生成
kubectl get secrets myregistrykey
#为访问kubernetes.api创建Pod使用的ServiceAccount用户
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
automountServiceAccountToken: false
#通过 kubectl create -f file.yaml 生成用户 build-robot
#通过 kubectl get serviceaccount build-robot -o yaml 查看用户信息
#在ServiceAccount对象中加入imagePullSecrets字段的定义：myregistrykey
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2018-04-03T22:02:39Z
  name: build-robot
  namespace: default
  selfLink: /api/v1/namespaces/default/serviceaccounts/default
  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6
secrets:
- name: build-robot-token
imagePullSecrets:
- name: myregistrykey
```
