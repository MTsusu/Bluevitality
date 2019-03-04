#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

#定义本地NTP服务器的上层NTP服务地址
SERVER1=0.cn.pool.ntp.org
SERVER2=0.asia.pool.ntp.org
SERVER3=2.asia.pool.ntp.org

set -ex

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#depend
yum -y install ntp

#配置前先同步服务器
ntpdate -u ${SERVER1}

#关闭SELINUX与防火墙
function Disable_sec() {
    if [ -x /usr/bin/systemctl ] ; then
        #CentOS 7.X
        setenforce 0 ; sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
        systemctl disable firewalld #or firewall-cmd--permanent --add-port=XXX/tcp && firewall-cmd-reload
        systemctl stop firewalld
    else
        #CentOS 6.X
        chkconfig iptables off --level 235
        service iptables stop
    fi
} 2> /dev/null

Disable_sec

cp /etc/ntp.conf /etc/ntp.conf.$(date "+%F").bak

sed -i "/server/d" /etc/ntp.conf
sed -i "/restrict/d" /etc/ntp.conf

cat >> /etc/ntp.conf <<eof
#上级NTP服务器的地址
server ${SERVER1}
server ${SERVER2}
server ${SERVER3}

restrict 192.168.0.0 mask 255.255.255.0 nomodify
# 允许特定网段的客户端到这台机器上更新时间
# 后缀参数：
# ignore：     关闭所有的 NTP 联机服务
# nomodify：  客户端不能更改服务端的时间参数，但是可通过服务端进行网络校时
# notrust：   客户端除非通过认证，否则该客户端来源将被视为不信任子网
# noquery：   不提供客户端的时间查询

restrict 127.0.0.1 
restrict ::1

#对默认的client拒绝所有的操作
restrict default nomodify notrap nopeer noquery
eof

#设置硬件时钟同步
echo "SYNC_HWCLOCK=yes" >> /etc/sysconfig/ntpd

systemctl enable ntpd
systemctl start ntpd

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0

# 客户端：
# 只要将/etc/ntpd.conf设置ntpd服务器地址即可
# server +server的地址 （内网地址）
# PS：防火墙需要开放123端口
