#!/bin/bash

# Nginx 日志格式：（使用此脚本分析日志需要使用使用如下的格式定义）
#    log_format main  '$time_local || $remote_addr || $upstream_addr ||  $status || $request_time '
#                     ' || $upstream_status || $upstream_response_time '
#                     ' || $upstream_cache_status || $body_bytes_sent || $http_referer'
#                     ' || $remote_user || $http_user_agent || $http_x_forwarded_for || $request';


#指定日志文件相对/绝对路径（执行脚本时需要传入日志文件名作为参数）
LOG=$1
[ -z $LOG ] && exit 1
#扫描>${ms_time}ms时间的URL的时间值定义...
ms_time=100

#输出当天URL访问量前30个的统计结果
function SCAN_LOGFILE_URL_SORT() {  #修改成通过管道将文件传输进来
    awk '{print $(NF-1)}' | sed -e 's/&.*//g' -e 's/?.*//g' \
    | awk '{s[$0]+=1}END{for(i in s){print s[i]"\t"i}}' \
    | sort -rn | head -n 30
}

#指定URL的统计
function SCAN_LOGFILE_URL() {
    read -p "please input URl:" sentence
    echo "该URL共出现:" $(grep -c "$sentence" ${LOG}) "次"
}

#大于'X'ms的URL统计
function SCAN_LOGFILE_LONGTIME() {      #修改成通过管道将文件传输进来
    awk -F'\\|\\|' -v x=$ms_time '{if($5 > x){print $1,$5,$NF}}' \
    | awk '{s[$(NF-1)]+=1}END{for(i in s){print s[i]"\t"i}}' \
    | sort -rn | head -n 30
}

#日志时间范围截取
function SCAN_LOGFILE_POSITION() {
    read -p "请输入扫描的日志开始时间,格式:yyyymmddHHMM: " S_TIME
    read -p "请输入扫描的日志结束时间,格式:yyyymmddHHMM: " E_TIME

    LOG_S_TIME=$(python -c "import time,sys;t=sys.argv[1];print(time.strftime('%d/%b/%Y:%H:%M', time.strptime(t,'%Y%m%d%H%M')))" ${S_TIME});
    LOG_E_TIME=$(python -c "import time,sys;t=sys.argv[1];print(time.strftime('%d/%b/%Y:%H:%M', time.strptime(t,'%Y%m%d%H%M')))" ${E_TIME})
    
    if grep -F '$LOG_S_TIME' ${LOG};then
        echo "没有匹配到开始时间关键字"
        exit 1
    fi
    if grep -F '$LOG_E_TIME' ${LOG};then
        echo "没有匹配到结束时间关键字"
        exit 1
    fi
    
    sed -n "/^`echo $LOG_S_TIME | sed 's@/@.@g'`/,/^`echo $LOG_E_TIME | sed 's@/@.@g'`/p" ${LOG}
}

#输出特定时间段内URL访问量前30个的统计结果
function SCAN_TIME_RANGE_URL_SORT() {
    SCAN_LOGFILE_POSITION | SCAN_LOGFILE_URL_SORT   
    echo -e "\033[31m扫描日志开始时间：$LOG_S_TIME \033[0m"
    echo -e "\033[31m扫描日志结束时间: $LOG_E_TIME \033[0m"
}

#输出特定时间段内URL的访问量统计
function SCAN_TIME_RANGE_URL() {
    read -p "please input URl:" sentence
    SCAN_LOGFILE_POSITION | grep -c "$sentence"
    echo -e "\033[31m扫描日志开始时间：$LOG_S_TIME \033[0m"
    echo -e "\033[31m扫描日志结束时间: $LOG_E_TIME \033[0m"
}

#输出特定时间段内URL返回超过指定时间的统计
function SCAN_TIME_RANGE_LONGTIME() {
    SCAN_LOGFILE_POSITION | SCAN_LOGFILE_LONGTIME
    echo -e "\033[31m扫描日志开始时间：$LOG_S_TIME \033[0m"
    echo -e "\033[31m扫描日志结束时间: $LOG_E_TIME \033[0m"
}


# SCAN_LOGFILE_POSITION               #日志时间范围截取
# cat $LOG | SCAN_LOGFILE_URL_SORT    #输出当天URL访问量前30个的统计结果
# SCAN_LOGFILE_URL                    #指定URL的统计
# cat $LOG | SCAN_LOGFILE_LONGTIME    #大于'X'ms的URL统计
# 
# SCAN_TIME_RANGE_URL_SORT            #输出特定时间段内URL访问量前30个的统计结果
# SCAN_TIME_RANGE_URL                 #输出特定时间段内URL的访问量统计
# SCAN_TIME_RANGE_LONGTIME            #输出特定时间段内URL返回超过指定时间的统计

echo -e "\033[31mTYPE:
1:  日志时间范围截取
2:  输出当天URL访问量前30个的统计结果
3:  指定URL的统计
4:  大于指定ms时间的URL统计
5:  输出特定时间段内URL访问量前30个的统计结果
6:  输出特定时间段内URL的访问量统计
7:  输出特定时间段内URL返回超过指定时间的统计
\033[0m
"

read -p "INPUT TYPE --> 1~7:" TYPE

case $TYPE in 
     1) 
        SCAN_LOGFILE_POSITION
     ;; 
     2) 
        cat $LOG | SCAN_LOGFILE_URL_SORT
     ;; 
     3) 
        SCAN_LOGFILE_URL
     ;; 
     4) 
        cat $LOG | SCAN_LOGFILE_LONGTIME
     ;; 
     5) 
        SCAN_TIME_RANGE_URL_SORT 
     ;; 
     6) 
        SCAN_TIME_RANGE_URL
     ;; 
     7) 
        SCAN_TIME_RANGE_LONGTIME
     ;; 
     *) 
        echo "please input 1~7"
        exit 1
     ;; 
esac
