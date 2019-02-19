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
