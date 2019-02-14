#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

#Target format：iqn.yyyy-mm.<reversed domain name>:identifier
TARGET_NAME="yanfa"
REVERSE_DOMAIN="com.yunwei"
TARGET_LUN_NAME="iqn.$(date '+%Y-%m').${REVERSE_DOMAIN}:server.${TARGET_NAME}"   
BACKING_STORE_FULLPATH="/dev/sdb"

#Authentication
INITIATOR_USERNAME="yanfa"
INITIATOR_PASSWORD="123456"
INITIATOR_ADDRESS_SRC="192.168.139.134/24"      #允许访问的的C端网段

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#启动tgtd
[[ -x /usr/sbin/tgtd ]]  && {
    systemctl start tgtd && systemctl status tgtd || exit 1
}

#写入Target
cp /etc/tgt/targets.conf /etc/tgt/targets.conf.$(date '+%F').${RANDOM}.bak
cat >> /etc/tgt/targets.conf <<eof
<target ${TARGET_LUN_NAME}>

    backing-store  ${BACKING_STORE_FULLPATH}        #设备地址(用 direct-store 报错..原因不清楚)
    write-cache on					                #默认开启缓存加速，在特殊情况有丢失数据的可能
    
    IncomingUser ${INITIATOR_USERNAME} ${INITIATOR_PASSWORD}
    # 命令方式：
    # tgtadm --lld iscsi --mode account --op new --user <USERNAME> --password <PASSWORD>
    # tgtadm --lld iscsi --mode account --op bind --tid 1 --user <USERNAME>
    # 删除账号：
    # tgtadm --lld iscsi --mode account --op delete --user <USERNAME>
    
    #initiator-address ${INITIATOR_ADDRESS_SRC}     #使用访问策略C端连接会有问题
</target>
eof

#reload and show
function reload_serv() {
    systemctl reload tgtd && systemctl status tgtd || exit 1
    clear ; tgt-admin --show
}

reload_serv

#注意！在ISCSI不使用gfs时：
#1个Target对多个initiator时iscsi不保证写操作一致，所以在1对多情况下1个initiator可rw其他initiator可r是可行方案

echo -e "\033[32m\n\nScript Execution Time： ${SECONDS}s\033[0m"

exit 0
