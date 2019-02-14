#!/bin/bash

source ~/.bash_profile
#-------------------------------
#此脚本适用于"java -jar"方式的自动调起
#启动/关闭脚本内必须是1个节点对应1行命令的方式，用于"grep"匹配节点名对应的执行命令进行执行!!
#如需要修改启停脚本的绝对路径，请修改第34、35行，默认：$HOME/sbin/{start/stop}-${PROJECT_NAME}.sh
#-------------------------------

# #工程目录名字（第1参数）,ps工程名和在此目录下查找JAR包用
# PROJECT_NAME="iscadapi-core"
# #JAR包名字（第2参数）及节点数
# APPLICATION="logger-admin-service-impl-1.0.0-SNAPSHOT.jar"
# NODE_NUMBER=4

#若未定义则使用传参：脚本 工程名 JAR包名 启动脚本路径 停止脚本路径
[ -z $PROJECT_NAME ] && PROJECT_NAME=$1                     #工程名称
[ -z $APPLICATION ] && APPLICATION=$2                       #JAR包名称
[ -z $NODE_NUMBER ] && NODE_NUMBER=$3                       #JAR包节点数  
         
[ -z $PROJECT_NAME ] && exit 1
[ -z $APPLICATION ] &&  exit 1
[ -z $NODE_NUMBER ] &&  exit 1

#取当前时间和JAR包时间戳（yyyy-mm-dd HH）
DATATIME_NOW=$(date "+%F %H:%M")
JAR_TIME=$(find $HOME/app-share/ -name "$APPLICATION" | uniq | xargs stat | awk -F'[. :]' '/Modify/{print $3,$4}')

#取工程节点数、工程节点所在路径
RUN_NODE_NUMBER=$(ps -ef | grep -F "${PROJECT_NAME}" | grep -c 'Xmx')
NODE_HOME=$(find $HOME/$PROJECT_NAME -type 1 -name "$PROJECT_NAME.jar" | grep -oP ".*(?=/.*\.jar$)")

function START_STOP() {
    grep $i $HOME/sbin/start-${PROJECT_NAME}.sh > $HOME/sbin/Node_start.sh
    grep $i $HOME/sbin/stop-${PROJECT_NAME}.sh  > $HOME/sbin/Node_stop.sh
    
    sh $HOME/sbin/Node_stop.sh >> $HOME/sbin/node_pullup.log ; sleep 2
    nohup sh $HOME/sbin/Node_start.sh &> /dev/null &
    echo "${DATATIME_NOW} $i 节点不存在，正在启动" >> $HOME/sbin/node_pullup.log ; sleep 3
    rm $HOME/sbin/Node_start.sh $HOME/sbin/Node_stop.sh
}

#判断JAR包与当前时间是否在相同小时单位内
if [[ "$JAR_TIME" == "$DATATIME_NOW" ]];then
    exit 0
else 
    #当JAR包不在当前小时范围内，开始判断节点数量，数量不满足就开始执行不存在的节点重启操作
    if [ $NODE_NUMBER -lt $RUN_NODE_NUMBER ];then
        for i in ${NODE_HOME}
        {   #判断节点是否在运行
            NODE_PS_RUN=$(ps -ef|grep $i|grep -v grep|grep -c Xmx)
            if [ $NODE_PS_RUN -eq 1 ];then
                continue
            else    #启动缺失的节点
                START_STOP
            fi        
        }
    fi   
fi
