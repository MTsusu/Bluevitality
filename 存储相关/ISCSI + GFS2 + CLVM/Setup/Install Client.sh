#!/bin/bash
#Tutorial.....

#定义...
SERVER_ADDRESS="192.168.139.137"
SERVER_PORT="3260"

USE_AUTH=1                      #启用认证? 0 or 1
INITIATOR_USERNAME="yanfa"      #
INITIATOR_PASSWORD="123456"     #

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#删除旧数据
yum -y remove iscsi-initiator-utils

#依赖
yum -y install epel-release gcc gcc-c++ cmake kernel-devel openssl openssl-devel
yum -y install iscsi-initiator-utils    #客户端（服务端：yum -y install scsi-target-utils）

#说明：
# /etc/iscsi/iscsid.conf：	主配置文件 
# /usr/sbin/iscsid： 		initiator服务程序 
# /usr/sbin/iscsiadm： 		initiator管理程序 
# /usr/sbin/iscsid： 	    主服务进程 
#
# /usr/lib/systemd/system/iscsi.service： 		
# 该脚本可使发现的iscsi target生效，一般直接使用其即可
# initiator未执行的话会调用/etc/init.d/iscsid启动initiator

#关闭SELINUX及防火墙
function disable_sec() {
    setenforce 0
    sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
    systemctl disable firewalld #or firewall-cmd--permanent --add-port=3260/tcp && firewall-cmd-reload
    systemctl stop firewalld
    systemctl disable iptables
    systemctl stop iptables
} 2> /dev/null

disable_sec || :

#设置Initiator端的名字 
echo "InitiatorName=$(iscsi-iname -p iqn.2017.01.com.test)" > /etc/iscsi/initiatorname.iscsi  

#若启用认证则写入验证信息
[ ${USE_AUTH} -eq 1 ] && {
    [[ -f /etc/iscsi/iscsid.conf ]] || exit 1
    cp /etc/iscsi/iscsid.conf /etc/iscsi/iscsid.conf.$(date '+%Y-%m').${RANDOM}.bak
    cat >> /etc/iscsi/iscsid.conf <<eof
#针对discovery
discovery.sendtargets.auth.authmethod = CHAP	
discovery.sendtargets.auth.username = ${INITIATOR_USERNAME}
discovery.sendtargets.auth.password = ${INITIATOR_PASSWORD}

#针对login（S端的检查设置在指定的target上）
node.startup = automatic
node.session.auth.authmethod = CHAP				
node.session.auth.username = ${INITIATOR_USERNAME}
node.session.auth.password = ${INITIATOR_PASSWORD}
node.session.timeo.replacement_timeout = 20
eof
}

#输出Target端提供的设备：（将保存发现记录）
iscsiadm -m discovery -t sendtargets -p ${SERVER_ADDRESS}:${SERVER_PORT} --discover

#进行login操作
#iscsiadm -m node -l

#启动服务，依discovery模块发现的信息进行挂载
function start_serv() {
    systemctl enable iscsi.service
    systemctl start iscsi.service
    systemctl status iscsi.service
}

start_serv

echo "Script Execution Time： $SECONDS"

exit 0
