#!/bin/bash

#路径格式为：$HOME/<工程名>/<节点名_>编号/

DATE=`date +%Y-%m-%d`
PROJECTNAME="ecpcore_new"                                     #此处替换为工程名
LOGS=`find $HOME/${PROJECTNAME}/ -name "*$DATE.out"`        #搜索指定路径下以日期结尾的的日志文件
COUNT_LOG_PATH="$HOME/shell/monitor_gc"                         #此目录用于记录上次执行的状态
GC_ERROR='GC overhead limit exceeded'                           #内存溢出关键字
NODE_NAME='release_tomcat_'                                     #写入工程目录下去掉编号后缀的节点名称部分

[[ -d $COUNT_LOG_PATH ]]||mkdir -p $COUNT_LOG_PATH
echo $LOGS

function server_stop() {
    ECPCORE_NEW_PID=`ps aux | grep $1 | egrep -v "grep|tail" | awk '{print$2}'`
    echo "tomcat: ${NODE_NAME} $1 Stop  Running!"
    sleep 0.5
    kill -9 $ECPCORE_NEW_PID                    #通过节点名执行Kill
}

function server_start() {
    #export LANG=zh_CN.UTF-8
    echo "tomcat: ${NODE_NAME} $1 Start Running!"
    cd $HOME/${PROJECTNAME}/$1/bin/             #此处注意工程名和节点名的替换...
    ./startup.sh
    if [ $? = 0 ];then
        echo "tomcat: $1 is Running!"
    else
        echo "tomcat: $1 start is fail"
    fi
}

for log in $LOGS
{
    NODE_NAME=`echo $log | grep -oP '.*(?=/logs)' | awk -F'/' '{print $NF}'`    #从日志路径截取出节点名部分    #替换了旧的：| awk -F"[_/]" '{print $7"_"$8}'
    [[ -f $COUNT_LOG_PATH/${NODE_NAME}.log-${DATE} ]] || echo 1 > $COUNT_LOG_PATH/${NODE_NAME}.log-${DATE} 
    
    LINE_NUM=`cat $COUNT_LOG_PATH/${NODE_NAME}.log-${DATE}`   #取出扫描的上次结束行位置
    ALL_LINE=`wc -l $log | awk '{print $1}'`                        #取出日志文件总行数
    
    echo $log
    echo $ALL_LINE
    GC_COUNT=`sed -n "$LINE_NUM,${ALL_LINE}p" $log |grep -sc "${GC_ERROR}"`   #从特定日志行范围内扫描内存溢出关键字的次数
    echo $ALL_LINE > $COUNT_LOG_PATH/${NODE_NAME}.log-${DATE}         #记录本次执行扫描时结束的行数
    
    if [ $GC_COUNT -gt 0 ]; then
        echo "restart $NODE_NAME"
        ECPCORE_NEW_PID=`ps aux | grep $NODE_NAME | egrep -v "grep|tail" | awk '{print$2}'`
        $HOME/jdk7/bin/jmap -dump:format=b,file=$COUNT_LOG_PATH/${NODE_NAME}_$(date "+%F_%H%M%S")_hprof  $ECPCORE_NEW_PID
        server_stop $NODE_NAME
        server_start $NODE_NAME
    fi
} 

echo "END:`date +"%Y-%m-%d %T"`"
