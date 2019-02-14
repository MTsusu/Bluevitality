#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

#定义...
REDIS_HOME="/usr/local/redis"

set -ex

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#depend
yum -y install epel-release gcc gcc-c++ cmake openssl openssl-devel net-tools vim

#erase old file and config ...
rm -rf {/usr/local/tcl-8.6.1,${REDIS_HOME}}

#并行编译
function make_and_install () {
    NUM=$( awk '/processor/{N++};END{print N}' /proc/cpuinfo )
    if [ $NUM -gt 1 ];then
        make -j $NUM
    else
        make
    fi
    make install
}

p=$(pwd)
tar -zxf tcl8.6.1-src.tar.gz 
cd tcl8.6.1/unix
./configure  --prefix=/usr/local/tcl-8.6.1
make_and_install

cd $p
tar -zxf redis-3.2.11.tar.gz  
cd redis-3.2.11
NUM=$( awk '/processor/{N++};END{print N}' /proc/cpuinfo )
if [ $NUM -gt 1 ];then
    make -j $NUM
else
    make
fi
make PREFIX=${REDIS_HOME} install


mkdir -p ${REDIS_HOME}/etc/ 
cp redis.conf    ${REDIS_HOME}/etc/
cp sentinel.conf ${REDIS_HOME}/etc/

ln -sv ${REDIS_HOME}/bin/* /usr/bin/

#关闭SELINUX与防火墙
function disable_sec() {
    setenforce 0 ; sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
    if [ -x /usr/bin/systemctl ] ; then
        #CentOS 7.X
        systemctl disable firewalld #or firewall-cmd--permanent --add-port=XXX/tcp && firewall-cmd-reload
        systemctl stop firewalld
    else
        #CentOS 6.X
        chkconfig iptables off --level 235
        service iptables stop
    fi
} 2> /dev/null

disable_sec

isExists=`grep 'vm.overcommit_memory' /etc/sysctl.conf | wc -l`
if [ "$isExists" != "1" ]; then
	echo "vm.overcommit_memory = 1">>/etc/sysctl.conf
	sysctl -p
fi

echo 'redis-server ${REDIS_HOME}/etc/redis.conf' >> /etc/rc.local
chmod +x /etc/rc.d/rc.local

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0


#redis目录下会出现编译后的redis服务程序 redis-server 用于测试的客户端 redis-cli。位于安装目录：src