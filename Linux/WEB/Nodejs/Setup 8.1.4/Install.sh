#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

#定义...
NODE_HOME_PATH="/usr/local/node"

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#depend
yum -y install epel-release gcc gcc-c++ cmake openssl openssl-devel bzip2 bzip2.x86_64 bzip2-devel 
rm -rf /usr/local/node /usr/local/node*

#二进制包
[ -s node-v8.1.4-linux-x64.tar.gz ] || exit 1
tar -zxvf node-v8.1.4-linux-x64.tar.gz -C /usr/local/
mv /usr/local/node-v8.1.4-linux-x64 ${NODE_HOME_PATH}

#环境变量(/etc/profile在某些场合不生效)
export NODE_HOME="${NODE_HOME_PATH}"
export PATH="${NODE_HOME}/bin:$PATH"

cat > /etc/profile.d/node.sh <<eof
export NODE_HOME="${NODE_HOME_PATH}"
export PATH="${NODE_HOME_PATH}/bin:$PATH"
eof

node -v #版本
npm -v  #包管理器（查看配置：npm config ls -l，包安装路径：npm config ls -l | grep prefix）

#使用阿里云的NPM源
function change_registry() {
    npm install -gd express --registry=http://registry.npm.taobao.org
    npm config set registry http://registry.npm.taobao.org
}

change_registry

npm install npm -g  #升级npm
npm install pm2 -g  #进程管理

#本地安装：      npm install express          
#全局安装：      npm install express -g  
#修改包路径：    npm config set prefix "your node_global path" 

#安装，运行，及模块的安装路径，状态查看..

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0
