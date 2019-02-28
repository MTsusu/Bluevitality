#### 备忘
```txt
helm:
helm可以把安装chart请求发送给tiller

tiller:
相当于helm server，部署在集群内部，接收部署请求，调用apiserver完成部署

repo:
相当于rpm包的yum源，里面存放着一系列包，可以是远程的，也可以是本地目录

chart:
相当于rpm包，包含服务的一系列配置信息，可以通过远程获取，也可以本地创建
```
```bash
#下载Helm：
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar -zxvf helm-v2.9.1-linux-amd64.tar .gz
cp linux-amd64/helm /usr/local/bin/        #复制客户端执行文件到bin目录下

#初始化tiller: ( init将获取本地默认的kubeconfig文件，然后在k8s上面部署 deploy/tiller-deploy )
helm init
#使用阿里云镜像安装并​​把默认仓库设置为阿里云上的镜像仓库
$ helm init --upgrade --tiller-image registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1 、
--stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

#创建 Kubernetes 的服务帐号和绑定角色：
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

#查看是否授权成功
kubectl get deploy --namespace kube-system  tiller-deploy  --output yaml| grep  serviceAccount
# serviceAccount: tiller
# serviceAccountName: tiller

#验证 Tiller 是否安装成功  ( 卸载Helm服务器端Tiller: helm reset )
kubectl -n kube-system get pods | grep tiller
helm version

#从repo里面更新chart ( 相当于 yum update )
helm repo update 

# 安装Helm后，通过执行以下命令将service-catalog Helm存储库添加到本地计算机： ( 添加仓库 )
# 通过 helm repo list 命令可以看到目前 Helm 中已配置的 Repository 的信息。
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
repo helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/

#通过执行以下命令检查以确保安装成功：
helm search service-catalog
helm search incubator

#使用以下命令从Helm存储库的根目录安装Service Catalog： ( 指定名称空间和 )
helm install svc-cat/catalog --name catalog --namespace catalog

#删除已安装的服务
helm delete prometheus
```
```bash
#创建名为 mychart 的 Chart:
helm create mychart && tree mychart/
mychart/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── NOTES.txt
│   └── service.yaml
└── values.yaml

2 directories, 7 files

# Chart.yaml     用于描述这个 Chart的相关信息，包括名字、描述信息以及版本等。
# values.yaml    用于存储 templates 目录中模板文件中用到变量的值。
# NOTES.txt      用于介绍 Chart 部署后的一些信息，例如：如何使用这个 Chart、列出缺省的设置等。
# Templates      目录下是 YAML 文件的模板，该模板文件遵循 Go template 语法。

# Templates 目录下YAML模板的值默认都是在 values.yaml 里定义的，比如在 deployment.yaml 中定义的容器镜像。
# image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}" 
# 其中的 .Values.image.repository 的值就是在 values.yaml 里定义的 nginx，.Values.image.tag 的值就是 stable


#检查依赖和模板配置是否正确
$ helm lint mychart/
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, no failures

#将应用打包
$ helm package mychart
Successfully packaged chart and saved it to: /home/k8s/mychart-0.1.0.tgz
```