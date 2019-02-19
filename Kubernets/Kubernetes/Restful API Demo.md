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
