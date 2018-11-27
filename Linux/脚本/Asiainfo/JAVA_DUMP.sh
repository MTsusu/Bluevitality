#!/bin/bash
#
#用于保存java现场状态，执行时传1-2个参数：bash 脚本.sh <JAVA进程号> [保存路径]
#20181122


#JAVA进程号
PID=$1

#保存路径(不传参默认为当前路径)
DUMNP_PATH=$2

#若不存在JAVAHOME变量则从文件系统找
if [ -z $JAVA_HOME ]; then
    JSTACK_PATH=$(locate jstack | grep -E 'bin.*jstack$' | head -n 1)
    JMAP_PATH=$(locate jmap | grep -E 'bin.*jmap$'| head -n 1)
    JSTAT_PATH=$(locate jstat | grep -E 'bin.*jstat$'| head -n 1)
    
    ${JSTACK_PATH} ${PID} > ${DUMNP_PATH=./}jstack-${PID}-`date "+%F-%H%M%S"`
    ${JMAP_PATH} -dump:format=b,file=${DUMNP_PATH=./}jmap-${PID}-`date "+%F-%H%M%S"` ${PID}
    ${JSTAT_PATH} -gcutil ${PID} 1000 10 >> ${DUMNP_PATH=./}jstat-gcutil-${PID}-`date "+%F-%H%M%S"`
fi

jstack ${PID} > ${DUMNP_PATH=./}jstack-${PID}-`date "+%F-%H%M%S"`
jmap -dump:format=b,file=${DUMNP_PATH=./}jmap-${PID}-`date "+%F-%H%M%S"` ${PID}
jstat -gcutil ${PID} 1000 10 >> ${DUMNP_PATH=./}jstat-gcutil-${PID}-`date "+%F-%H%M%S"`

exit 0

