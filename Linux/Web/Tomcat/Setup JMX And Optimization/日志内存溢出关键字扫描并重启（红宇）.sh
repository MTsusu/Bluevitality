#!/bin/bash
#
# 本脚本用于搜索所有Tomcat当前日志，根据日志中的内存溢出关键字重启Tomcat服务并导出其溢出原因
# 本脚本加入crontab：
# */2 * * * * bash -x /home/zyzx/shell/fupin_gc.sh >> /home/zyzx/test000/cy/fupin_gc.log 2>&1

DATE=$(date +%Y-%m-%d)

#获取所有Tomcat当前产生的日志，这里是"/*/Tomcat/logs/catalina.yyyymmdd.out"的文件列表
TOMCAT_ALL_LOGS=$(find $HOME/fupin/ -name "*$DATE.out")

#内存溢出关键字
GC_ERROR='java.lang.OutOfMemoryError: Java heap space'

#存储扫描日志的行记录的路径，作为其下次扫描关键字的起使行
COUNT_LOG_PATH="$HOME/shell/monitor_gc"

mkdir -p $COUNT_LOG_PATH

#Find搜索到的Tom日志列表
echo $TOMCAT_ALL_LOGS

#根据项目编号关闭Tom
function server_stop() {
    FUPIN_PID=$(ps aux | grep release_tomcat_$1 | awk '!/grep/{print $2}')
    echo "tomcat_$1 Stop Running!"
    sleep 0.5
    kill -9 $FUPIN_PID
}

#根据项目编号开启Tom
function server_start() {
    export LANG=zh_CN.UTF-8
    echo "tomcat_$1 Start Running!"

    cd $HOME/fupin/tomcat_$1/bin/ && ./startup.sh
    if [[ "$?" == "0" ]];then
        echo "tomcat_$1 is Running!"
    else
        echo "tomcat_$1 start is fail"
    fi
}

#对所有Tom的Log进行GC关键字检索，若发现内存溢出问题则对其进行重启并导出其溢出原因
for log in $TOMCAT_ALL_LOGS
do
    #从路径获取Tomcat所属的项目编号，如："/home/zyzx/fupin/tomcat_fupin5/logs/XXX.out"中的：fupin5
    FUPIN_NUM=$(echo $log | awk -F"[_/]" '{print $6}')
    #若不存在上次扫描日志的行位置，则默认从第一行开始扫描
    [[ -f $COUNT_LOG_PATH/${FUPIN_NUM}.log-${DATE} ]] || echo 1 > $COUNT_LOG_PATH/${FUPIN_NUM}.log-${DATE}
    #读取上次扫描的日志文件位置
    LINE_NUM=$(cat $COUNT_LOG_PATH/${FUPIN_NUM}.log-${DATE})
    
    #获取日志当前的总行数
    ALL_LINE=$(wc -l $log | cut -d " " -f1)
    #输出日志文件名、总行数
    echo -e "$log\n$ALL_LINE"
    #从上次扫描的位置到最后的行末进行搜索，并统计GC关键词的次数
    GC_COUNT=$(sed -n "${LINE_NUM},${ALL_LINE}p" $log | grep -sc "$GC_ERROR")
    
    #记录此次扫描的位置
    echo $ALL_LINE > $COUNT_LOG_PATH/${FUPIN_NUM}.log-${DATE}
    
    #若出现GC错误，则重启对应的Tom服务
    if [ $GC_COUNT -gt 0 ]; then
        echo restart $FUPIN_NUM
        FUPIN_PID=$(ps aux | grep release_tomcat_$FUPIN_NUM | egrep -v "grep|tail" | awk '{print$2}')
        #导出内存溢出的heap信息
        $JAVA_HOME/bin/jmap -dump:format=b,file=$COUNT_LOG_PATH/${FUPIN_NUM}_${DATE}_hprof_$$  $FUPIN_PID
        server_stop $FUPIN_NUM
        server_start $FUPIN_NUM
    fi
    
done

echo "END:`date +"%Y-%m-%d %T"`"

exit 0
