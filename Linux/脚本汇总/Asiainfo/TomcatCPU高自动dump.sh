#!/bin/bash
source ~/.bash_profile

#定义用于保存线程状态信息的路径
MONITOR_CPU_PATH=${HOME}/shell/monitor/cpu
MONITOR_RESULT_PATH=${HOME}/shell/monitor/cpu/result
JSTACK_CMD="${HOME}/jdk/bin/jstack"

[ ! -d ${MONITOR_CPU_PATH} ] && mkdir -p ${MONITOR_CPU_PATH}
[ ! -d ${MONITOR_RESULT_PATH} ] && mkdir -p ${MONITOR_RESULT_PATH}

#找出所有TOMCAT进程的PID
for i in `ps -ef | grep java | grep Xmx | awk '{print $2}'`
do
   {
    #获取此进程的TOMCAT节点路径
    INSTANCE=$(ps -ef | grep ${i} | grep -oP "(?<=catalina.base=).*?(?= )" | awk -F'/' '{print $NF}')
    if [ "${INSTANCE}" != "" ];then
        P_CPU_INT=$(ps -o pcpu ${i} | awk 'NR==2{print int($1)}')
        if [ ${P_CPU_INT} -gt 300 ];then
            DATE_TIME=`date +%Y%m%d%H%M%S`
            #保存此进程的CPU使用率
            echo "${DATE_TIME} ${INSTANCE} ${P_CPU_INT}" >> ${MONITOR_CPU_PATH}/${INSTANCE}_${i}_cpu.txt
            #保存此进程的线程状态
            ps -mp ${i} -o THREAD,tid,time > ${MONITOR_CPU_PATH}/${INSTANCE}_${i}_cpu_${P_CPU_INT}_ThreadID_${DATE_TIME}
            #保存进程现场状态
            ${JSTACK_CMD} ${i} > ${MONITOR_CPU_PATH}/${INSTANCE}_${i}_cpu_${P_CPU_INT}_jstack_${DATE_TIME}
            #获取此PID下CPU使用率最高的TID号
            P_TID=`sed 1,2d ${MONITOR_CPU_PATH}/${INSTANCE}_${i}_cpu_${P_CPU_INT}_ThreadID_${DATE_TIME} | sort -k 2 -rn | sed -n '1p;1q' | awk '{print $8}'`
            #获取此PID下TID的最高CPU使用率
            P_TID_CPU=`sed 1,2d ${MONITOR_CPU_PATH}/${INSTANCE}_${i}_cpu_${P_CPU_INT}_ThreadID_${DATE_TIME} | sort -k 2 -rn | sed -n '1p;1q' | awk '{print $2}'`
            #获取此PID下CPU使用率最高的TID的16进制字符
            P_NID=`printf "%x\n" ${P_TID}`
            #记录：时间 节点名称 使用率最高的TID号  16进制形式的TID号 TID的使用率
            echo ${DATE_TIME} ${INSTANCE} ${P_TID} ${P_NID} ${P_TID_CPU} >> ${MONITOR_RESULT_PATH}/short_result.all
            #保存CPU使用率最高的TID的Jstack输出中此十六进制TID关键字向下100行的记录
            grep ${P_NID} ${MONITOR_CPU_PATH}/${INSTANCE}_${i}_cpu_${P_CPU_INT}_jstack_${DATE_TIME} -A 100 > ${MONITOR_RESULT_PATH}/${INSTANCE}_${i}_cpu_${P_CPU_INT}_result_${DATE_TIME}
        fi
    fi
   } &
done