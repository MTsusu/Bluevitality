#!/bin/bash


#定义...
PPTP_USERNAME="test"
PPTP_PASSWORD="123456"
PPTP_ALLOW_SRC="*"

VPN_ADDRESS='192.168.139.132'
VPN_ADDRESS_MASK='24'
VPN_USE_INTERFACE='eno16777736'
CLIENT_VPN_USEADDR='192.168.139.1-254'  #分配的ip地址，如果IP为*，则表示随机分配，分配范围采用pptp.conf中的设置

PPTP_TOKEN_NAME="PPTP"
PPTP_LOG_PATH="/var/log/pptpd.log"
PPTP_DNS1='114.114.114.114'
PPTP_DNS2='8.8.8.8'

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#依赖
yum -y install epel-release 
yum -y install ppp iptables-services pptpd make libpcap

function env_check() {
    #检查系统内核是否支持MPPE
    modprobe ppp-compress-18 ||  exit 1
    #检查PPP是否支持MPPE
    strings '/usr/sbin/pppd' | grep -i mppe | wc -l || exit 1
    modprobe ip_nat_pptp     
    modprobe ip_conntrack_pptp
}

env_check

cat > /etc/ppp/options.pptpd <<EOF
name ${PPTP_TOKEN_NAME}     #自行设定的VPN服务器的名字，可任意
#refuse-pap                 #拒绝pap身份验证
#refuse-chap                #拒绝chap身份验证
#refuse-mschap              #拒绝mschap身份验证
require-mschap-v2           #为了最高的安全性，使用mschap-v2身份验证
require-mppe-128            #使用128位MPPE加密
ms-dns ${PPTP_DNS1}         #设置DNS
ms-dns ${PPTP_DNS2}
proxyarp                    #启用ARP代理，如果分配给客户端的IP与内网卡同一个子网
debug                      #关闭debug
nologfd                    #不输入运行信息到stderr
nobsdcomp 
novj
novjccomp
logfile ${PPTP_LOG_PATH}  #存放pptpd服务运行的的日志
EOF

cat >  /etc/ppp/chap-secrets <<EOF
${PPTP_USERNAME} ${PPTP_TOKEN_NAME} ${PPTP_PASSWORD} ${PPTP_ALLOW_SRC}  #账号 服务标记 密码 来源
EOF

cat > /etc/pptpd.conf <<EOF
option /etc/ppp/options.pptpd
logwtmp
#设置VPN服务器虚拟IP地址
localip ${VPN_ADDRESS}
#为拨入VPN的用户动态分配的IP
remoteip ${CLIENT_VPN_USEADDR}
EOF

#开启路由
echo 1 > /proc/sys/net/ipv4/ip_forward 
grep -q 'net.ipv4.ip_forward' /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1 ' >> /etc/sysctl.conf 
/sbin/sysctl -p

function net_wall() {
    #更换防火墙
    systemctl stop firewalld.service   
    systemctl disable firewalld.service
    yum -y erase firewalld
    
    systemctl enable iptables.service
    systemctl start iptables.service
    
    #开放端口
    iptables -A INPUT -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 1723 -j ACCEPT
    iptables -A INPUT -p gre -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
    
    #开启包转发
    iptables -t nat -A POSTROUTING -s ${VPN_ADDRESS%.*}.0/${VPN_ADDRESS_MASK} -o ${VPN_USE_INTERFACE} -j MASQUERADE
    
    return 0
}

net_wall && {
    systemctl enable pptpd
    systemctl start pptpd
}


exit 0
