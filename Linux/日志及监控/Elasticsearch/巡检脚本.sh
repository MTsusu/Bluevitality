#!/bin/bash

IP_PORT="172.22.241.174:9200"
NODE_USER="zyzx_test"

TIME=$(date +%Y%m%d%H%M%S)
CLUSTER=$(curl -s "$IP_PORT" | awk -F':' '/cluster_name/{print $2}' | grep -o '".*"' | sed 's/"//g' )

#取集群节点所有IP地址
curl -s "$IP_PORT/_cat/nodes?v&h=ip" | sort -rn | uniq | sed '/ip/d' > /tmp/${CLUSTER}-temp.hosts

#取集群节点所有磁盘IO性能
ansible -i /tmp/${CLUSTER}-temp.hosts -u ${NODE_USER} all -m shell -a 'iostat -mx 1 1' \
| grep SUCCESS -A 5 | sed -nE '/^[[:digit:]]{2,}/p;n;n;n;n;p' \
| awk 'NR==1{printf $1"  IOWAIT:"};NR==2{print $4}' > /tmp/elasticsearch-${CLUSTER}-hosts.IOinfo

#取集群节点所有CPU核心数量
ansible -i /tmp/${CLUSTER}-temp.hosts -u ${NODE_USER} all -m shell -a 'lscpu' \
| grep SUCCESS -A 4 \
| sed -nE '/^[[:digit:]]{2,}/p;n;n;n;n;p' \
| awk 'NR==1{printf $1"  CPU_NUMBER:"};NR==2{print $2}' > /tmp/elasticsearch-${CLUSTER}-hosts.cpuinfo

ansible -i /tmp/${CLUSTER}-temp.hosts -u ${NODE_USER} all -m ping | grep -o .*UNREACHABLE \
| tee  /tmp/elasticsearch-${CLUSTER}-hosts.cpuinfo \
>> /tmp/elasticsearch-${CLUSTER}-hosts.IOinfo

#集群节点数
#curl -s "$IP_PORT/_cat/nodes" | wc -l 

#PID，地址，端口信息，剩余磁盘使用量，HEAP用量，内存，CPU和负载信息等....
curl -s "$IP_PORT/_cat/nodes?v&h=name,pid,ip,port,http_address,disk.avail,heap.current,heap.max,heap.percent,ram.current,ram.percent,ram.max,cpu,load_1m,load_5m,load_15m" > /tmp/elasticsearch-${CLUSTER}-${TIME}

#索引信息
curl -s "$IP_PORT/_cat/indices?v" \
> /tmp/elasticsearch-${CLUSTER}-indices-${TIME}.log

#不健康索引
curl -s "$IP_PORT/_cat/indices?v" \
| grep -E '^red|^yellow' \
> /tmp/elasticsearch-${CLUSTER}-bad-indices-${TIME}.log

#HEAP 90%
cat /tmp/elasticsearch-${CLUSTER}-${TIME} | awk '{if($9 > 90){print $0}}'  > /tmp/elasticsearch-${CLUSTER}-high.heap-${TIME}.log

#RAM  90%
cat /tmp/elasticsearch-${CLUSTER}-${TIME} | awk '{if($11 > 90){print $0}}' > /tmp/elasticsearch-${CLUSTER}-high.ram-${TIME}.log

#CPU  75%
cat /tmp/elasticsearch-${CLUSTER}-${TIME} | awk '{if($13 > 75){print $0}}' > /tmp/elasticsearch-${CLUSTER}-high.cpu-${TIME}.log


cat /tmp/elasticsearch-${CLUSTER}-${TIME}

