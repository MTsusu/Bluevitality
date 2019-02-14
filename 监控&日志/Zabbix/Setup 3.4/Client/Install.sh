#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

USERNAME="zabbix"
AGENT_NAME="test server"
ZABBIX_SERVER_ADDRESS=192.168.0.3
ZABBIX_SERVER_PORT=10051
INSTALL_PATH="/usr/local/zabbix_agentd"

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#创建用户
if ! id ${USERNAME} &> /dev/null ; then
    groupadd ${USERNAME}
    useradd -M -g ${USERNAME} ${USERNAME:?'Undefined ...'} -s /sbin/nologin
fi

#依赖
yum -y install epel-release gcc gcc-c++ cmake openssl openssl-devel net-tools vim \
ntpdate wget unixODBC unixODBC-devel

#erase old file and config ...
rm -rf {/etc/init.d/zabbix_agentd,/usr/local/zabbix*}

#sync
ntpdate asia.pool.ntp.org

[ -s zabbix-3.4.4.tar.gz ] || exit 1
tar -zxf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4
./configure --prefix=${INSTALL_PATH} --enable-agent
make install

sed -i "s/Server=.*/Server=${ZABBIX_SERVER_ADDRESS}/g" ${INSTALL_PATH}/etc/zabbix_agentd.conf
sed -i "s/ServerActive=.*/ServerActive=${ZABBIX_SERVER_ADDRESS}/g" ${INSTALL_PATH}/etc/zabbix_agentd.conf
sed -i "s|# ListenIP=0.0.0.0|ListenIP=0.0.0.0|g" ${INSTALL_PATH}/etc/zabbix_agentd.conf
sed -i "s|# ListenPort=10050|ListenPort=10050|g" ${INSTALL_PATH}/etc/zabbix_agentd.conf
sed -i "s|Hostname=.*|Hostname=${AGENT_NAME}|g"  ${INSTALL_PATH}/etc/zabbix_agentd.conf

cp misc/init.d/tru64/zabbix_agentd /etc/init.d/
sed -i "s:DAEMON=/usr/local/sbin/zabbix_agentd:DAEMON=${INSTALL_PATH}/sbin/zabbix_agentd:g" /etc/init.d/zabbix_agentd

chmod +x /etc/init.d/zabbix_agentd

#启动
/etc/init.d/zabbix_agentd start
echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local

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

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0

