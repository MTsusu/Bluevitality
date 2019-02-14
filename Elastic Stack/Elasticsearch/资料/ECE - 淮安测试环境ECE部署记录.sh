yum -y install docker
systemctl enable docker
systemctl start docker

systemctl stop firewalld
systemctl disable firewalld

setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux

sudo -i
chmod a+rwx /var/run/docker.sock

groupadd docker
usermod -aG docker $YOUR_USER
chmod 777 /usr/bin/docker
systemctl start docker

sysctl -w vm.max_map_count=655360
vim /etc/sysctl.conf ---> vm.max_map_count=262144
sysctl -p

vim /etc/security/limits.conf
* hard nofile 65536
* soft nofile 65536

su - devopses
#修改ECE执行脚本的路径，改为存储盘路径：Default host storage path
HOST_STORAGE_PATH=/mnt/data/elastic

chmod 777 -R /home/devopses/data/elastic

docker load < 'elastic-cloud-enterprise.img'    #事先翻墙下载的Docker镜像，本地执行需要能访问外网并绕过GFW

bash ECE.sh install  
#脚本即：bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install
#执行后访问: http://x.x.x.x:12400
#查找登陆的URL的账号(admin)/密码：
cat /home/devopses/data/elastic/  | grep -oP  'bootstrap_tokens_secret.*{50}'   #获取TOKEN


#以上操作在ECE集群的的每个机器都执行
#以下操作在ECE集群需要加入主节点的机器执行 Optional: Add more hosts to your Elastic Cloud Enterprise installation.

bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh)  \
install --coordinator-host <hostname of first host>  --roles-token 'TOKEN'

