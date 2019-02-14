#!/bin/bash

# Demo: ---------------------------------------------------
#
#                                           |
#        121.207.22.1          111.2.33.28  |
#        +---------+  Public   +---------+  | Private
#        | ServerA +-----------+ ServerB +--+
#        +---------+  Network  +---------+  | Network
#                                           |
#                                           | 10.10.10.2/24 
#----------------------------------------------------------

TUNNEL_NAME="GRE1"
HOST_A_PUBLIC_ADDRESS=192.168.139.132       #A主机公网地址
HOST_A_PRIVATA_ADDRESS=192.168.20.1         #A主机GRE内网地址
HOST_B_PUBLIC_ADDRESS=192.168.139.134       #B主机公网地址
HOST_B_PRIVATE_ADDRESS=192.168.20.2         #B主机GR内网E地址


set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#HOST_A
function A() {
    
    #添加GRE隧道
    exec_str="
    ip tunnel add ${TUNNEL_NAME} mode gre remote ${HOST_B_PUBLIC_ADDRESS} local ${HOST_A_PUBLIC_ADDRESS} ttl 255 ;
    ip link set ${TUNNEL_NAME} up ;
    ip address add ${HOST_A_PRIVATA_ADDRESS} peer ${HOST_B_PRIVATE_ADDRESS} dev ${TUNNEL_NAME}
    "
    
    #执行并写入开机自启
    eval $exec_str && echo "$exec_str" >> /etc/rc.local || exit 0
    chmod a+x /etc/rc.d/rc.local
    
    #开启路由
    sysctl -w net.ipv4.ip_forward=1
    ! grep -q 'ip_forward' /etc/sysctl.conf && echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf \
    || sed -i 's/net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/g' /etc/sysctl.conf 
    sysctl -p
    
}

#HOST_B
function B() {
    
    #添加GRE隧道
    exec_str="
    ip tunnel add ${TUNNEL_NAME} mode gre remote ${HOST_A_PUBLIC_ADDRESS} local ${HOST_B_PUBLIC_ADDRESS} ttl 255 ;
    ip link set ${TUNNEL_NAME} up ;
    ip address add ${HOST_B_PRIVATE_ADDRESS} peer ${HOST_A_PRIVATA_ADDRESS} dev ${TUNNEL_NAME}
    "
    #执行并写入开机自启
    eval $exec_str && echo "$exec_str" >> /etc/rc.local || exit 0
    chmod a+x /etc/rc.d/rc.local
    
    #开启路由
    sysctl -w net.ipv4.ip_forward=1
    ! grep -q 'ip_forward' /etc/sysctl.conf && echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf \
    || sed -i 's/net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/g' /etc/sysctl.conf 
    sysctl -p
}

case $1 in
    "a"|"A")
        A
        ;;
    "b"|"B")
        B
        ;;
    *)
        echo -e "this is HOST(A) or HOST(B) ?"
        echo -e "remove:\n ip link set ${TUNNEL_NAME} down && ip tunnel del ${TUNNEL_NAME}"
        ;;
esac

#若需指定去往对面主机的其他网段，需在本主机添加路由：ip route add 192.168.XX.0/24  via $HOST_(A|B)_PRIVATE_ADDRESS

exit 0


