#!/bin/bash


#根据时间段 eg:10.20 10.25
#指定的URL
#所有的URL的统计
#大于3s的URL、时间段内的共多少条

#指定日志文件相对/绝对路径
LOG=$1
[ -Z $LOG ] && exit 1

#输出当天URL访问量前30个的统计结果
awk '{print $(NF-1)}' ${LOG}  | sed -e 's/&.*//g' -e 's/?.*//g' | awk '{s[$0]+=1}END{for(i in s){print s[i],i}}' \
| sort -rn | head -n 30


#开始时间
S_TIME="201811071130"
#结束时间
E_TIME="201811071331"

LOG_S_TIME=$(python -c "import time,sys;t=sys.argv[1]
print(time.strftime('%d/%b/%Y:%H:%M', time.strptime(t,'%Y%m%d%H%M')))" ${S_TIME})
LOG_E_TIME=$(python -c "import time,sys;t=sys.argv[1]
print(time.strftime('%d/%b/%Y:%H:%M', time.strptime(t,'%Y%m%d%H%M')))" ${E_TIME})

sed -n "/^`echo $LOG_S_TIME | sed 's@/@.@g'`/,/^`echo $LOG_E_TIME | sed 's@/@.@g'`/p" ${LOG}

