#!/bin/bash

#所属工程名称
product=$1

echo -e "IP,PORT,PRODUCT,REDIS_VERSION,CLUSTER_STATE,CLUSTER_NODES,NODE_PING,UPTIME_DAYS,CONNECT_CLIENTS,BLOCKED_CLIENTS,REJECTED_CONNECT,CPU_USE,USED_CPU_SYS,USED_CPU_USER,MEM_USE,MEM_RETIO,OPS_PER_SEC,SYNC_FULL,SYNC_PARTIAL_ERR,DB0_KEYS,KEY_HITS_NUMBER,KEY_MISS_NUMBER,SLOWLOG_NUMBER,GET_CMD_COUNTS,SET_CMD_COUNTS,DEL_CMD_COUNTS,AVERAGE_GET_USETIME,AVERAGE_SET_USETIME,AVERAGE_DEL_USETIME" > /tmp/redis.csv

ps -ef |grep redis-server | grep -v grep| grep -v check_redis.sh | while read line
do
IP=$(echo $line | grep -oE "[[:digit:]]{2,}\.[[:digit:]]{1,}\.[[:digit:]]{1,}\.[[:digit:]]{1,}" )
PORT=$(echo $line | awk '{print $(NF-1)}' | grep -oP "(?<=[[:digit:]]:).*" )

#获取Redis-cli客户端
BIN_BASE=$(pwdx $(ps -ef|grep -F 'redis-server'|awk '!/grep/{print $2}'|tail -n 1)|awk '{print $NF}')
REDISCLI=$(echo ${BIN_BASE}/redis-cli)

#创建临时文件保存数据
REDIS_INFO=`mktemp`
COMM="/tmp/redis_$(date "+%F_%H-%M-%S".txt)"

${REDISCLI} -c -h $IP -p $PORT cluster nodes | sed 's/\^\M\$//g' > /tmp/cluster_nodes.info
${REDISCLI} -c -h $IP -p $PORT <<EOF > ${REDIS_INFO}.txt
cluster info
cluster nodes 
info
info Commandstats
ping
slowlog len
EOF

cat -A ${REDIS_INFO}.txt | sed 's/\^\M\$//g' > ${COMM}

version=$(grep -oP "(?<=redis_version:).*" ${COMM})
cstat=$(grep -oP "(?<=cluster_state:).*" ${COMM})
nodes=$(grep -oP "(?<=cluster_known_nodes:).*" ${COMM})
pong=$(grep -o "PONG" ${COMM} || echo "FAIL!!")
updata=$(grep -oP "(?<=uptime_in_days:).*" ${COMM})
con=$(grep -oP "(?<=connected_clients:).*" ${COMM})
bolck=$(grep -oP "(?<=blocked_clients:).*" ${COMM})
reject=$(grep -oP "(?<=rejected_connections:).*" ${COMM})
cpusy=$(grep -oP "(?<=used_cpu_sys:).*" ${COMM})
cpuuser=$(grep -oP "(?<=used_cpu_user:).*" ${COMM})
cpuuse=`ps aux | grep redis |grep -w $PORT | grep -v grep | awk '{print $3}'`
mem=$(grep -oP "(?<=used_memory_human:).*" ${COMM})
ratio=$(grep -oP "(?<=mem_fragmentation_ratio:).*" ${COMM})
get_cmd_counts=$(grep -oP "(?<=cmdstat_get:calls=).*?(?=,)" ${COMM})
set_cmd_counts=$(grep -oP "(?<=cmdstat_set:calls=).*?(?=,)" ${COMM})
del_cmd_counts=$(grep -oP "(?<=cmdstat_del:calls=).*?(?=,)" ${COMM})
get_cmd_pertime=$(awk -F= '/^cmdstat_get:/{print $NF}' ${COMM})
set_cmd_pertime=$(awk -F= '/^cmdstat_set:/{print $NF}' ${COMM})
del_cmd_pertime=$(awk -F= '/^cmdstat_del:/{print $NF}' ${COMM})
persec=$(cat ${COMM}|grep 'instantaneous_ops_per_sec' |awk -F ':' '{print $2}')
syncfull=$(cat ${COMM}|grep 'sync_full'|awk -F ':' '{print $2}')
parerr=$(cat ${COMM}|grep 'sync_partial_err'|awk -F ':' '{print $2}')
keys=$(cat ${COMM}|grep -oP '(?<=:keys=)[[:digit:]]{1,}')
hits=$(cat ${COMM}|grep -oP '(?<=keyspace_hits:).*')
miss=$(cat ${COMM}|grep -oP '(?<=keyspace_misses:).*')
slowlogc=$(cat ${COMM}|tail -1)

echo -e "
\033[5m -------------------------------- \033[0m
\033[31mIP: \033[0m                $IP
\033[31mPORT: \033[0m              $PORT
\033[31mPRODUCT:\033[0m            ${product:="null"}
\033[31mREDIS_VERSION:\033[0m      $version
\033[31mCLUSTER_STATE:\033[0m      $cstat 
\033[31mCLUSTER_NODES:\033[0m      $nodes
\033[31mNODE_PING:\033[0m          $pong
\033[31mUPTIME_DAYS:\033[0m        $updata
\033[31mCONNECT_CLIENTS:\033[0m    $con
\033[31mBLOCKED_CLIENTS:\033[0m    $bolck
\033[31mREJECTED_CONNECT:\033[0m   $reject     #连接数达到maxclients的限制值之后拒绝新连接的个数
\033[31mCPU_USE:\033[0m            $cpuuse
\033[31mUSED_CPU_SYS:\033[0m       $cpusy
\033[31mUSED_CPU_USER:\033[0m      $cpuuser
\033[31mMEM_USE:\033[0m            $mem
\033[31mMEM_RETIO:\033[0m          $ratio
\033[31mOPS_PER_SEC:\033[0m        $persec
\033[31mSYNC_FULL:\033[0m          $syncfull
\033[31mSYNC_PARTIAL_ERR:\033[0m   $parerr
\033[31mDB0_KEYS:\033[0m           $keys
\033[31mKEY_HITS_NUMBER:\033[0m    $hits
\033[31mKEY_MISS_NUMBER:\033[0m    $miss
\033[31mSLOWLOG_NUMBER:\033[0m     $slowlogc
\033[31mGET_CMD_COUNTS:\033[0m     $get_cmd_counts 
\033[31mSET_CMD_COUNTS:\033[0m     $set_cmd_counts 
\033[31mDEL_CMD_COUNTS:\033[0m     $del_cmd_counts 
\033[31mAVERAGE_GET_USETIME:\033[0m ${get_cmd_pertime}ms
\033[31mAVERAGE_SET_USETIME:\033[0m ${set_cmd_pertime}ms
\033[31mAVERAGE_DEL_USETIME:\033[0m ${del_cmd_pertime}ms
"

echo "${IP},$PORT,${product:=null},$version,$cstat,$nodes,$pong,$updata,$con,$bolck,$reject,$cpuuse,$cpusy,$cpuuser,$mem,$ratio,$persec,$syncfull,$parerr,$keys,$hits,$miss,$slowlogc,$get_cmd_counts,$set_cmd_counts,$del_cmd_counts,${get_cmd_pertime}ms,${set_cmd_pertime}ms,${del_cmd_pertime}ms" >> /tmp/redis.csv
done

echo "------------------ cluster nodes: ------------------"
awk '{print $2,$3}' /tmp/cluster_nodes.info | sed 's/myself,//g'
echo -e "\n\n\033[31mredis巡检表格报告路径：\033[0m  /tmp/redis.csv"