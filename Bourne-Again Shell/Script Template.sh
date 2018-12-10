#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

#定义...
USERNAME="string"

set -ex


#depend
yum -y install epel-release gcc gcc-c++ cmake openssl openssl-devel net-tools vim

#目录
mkdir -p $..../etc

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

echo '.................................' >> /etc/rc.local
chmod +x /etc/rc.d/rc.local

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0
