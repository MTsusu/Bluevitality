#!/bin/bash

#脚本所在位置 jenkins@192.168.151.62: ~/.es_alert/monitor.sh

IP_port='192.168.157.11:9213'

BASE_HOME=$HOME/.es_alert

#告警联系人
PHONE=(
手机号码1
手机号码2
手机号码3
手机号码4
)


cd $BASE_HOME

#短信接口
function alert() {
    ADMINISTRATOR=$1
    ALERTMESSAGES=$2
    curl -kd "Apikey=6fe47cdf4fcc9ed803fb55a249205b23&Username=zxzndtsub&Billid=${ADMINISTRATOR}&Rspid=7175" \
    --data-urlencode "InfoMap={\"info\":\"${ALERTMESSAGES}\"}" 'https://192.168.135.242:20080/sendtempsms'
}

#扫描并将进程DOWN信息调用短信接口
curl -s "http://192.168.157.11:9213/_cat/nodes" | awk '{print $1"\t"$NF}' | sort -n > alive-node-system
if diff alive-node-system all-node-system | grep -qE '<|>'; then
    MESSAGES="日志平台ES节点Down! -> $(diff alive-node-system all-node-system | grep -E '<|>')"
    for i in ${PHONE[@]}
    {
        alert $i "$MESSAGES"
    }
fi

#未完成，没有调用短信（调用有错）
ansible -i ./hosts-es-system -m shell -a 'df -h | grep dat' \
| sed -E '/^[[:digit:]]/{N;s/\n/\t/}' \
| awk '{print $1"\t 剩余:"$(NF-2)"\t 使用率:"$(NF-1)"\t"$(NF)}'
| sort -rn 
