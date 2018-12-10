#!/bin/bash
 
function printCount()
{
    echo "访问次数："
    awk '{print $1}' access.log|sort | uniq -c |sort -n -k 1 -r|more
    # echo "响应时间统计"
    # awk '$0 ~ /0.010' access.log | uniq -c

    # awk '{print $NF}' access.log | sort | sed 's/\"//g'
    #取响应时间字段，排序，去引号（sed 's/\"//g'）
    # awk '{print $NF}' access.log | sort | sed 's/\"//g'|awk '{if($0<0.01)a[$1]++}END{for (i in a) print i,a[i];}'

    echo "-------------------------------------"
    echo "<10ms："
    awk '{print $NF}' access.log | sort | sed 's/\"//g'|awk '{if($0<0.01) a+=1}END{print a;}'
    
    echo "10ms~20ms:"
    awk '{print $NF}' access.log | sort | sed 's/\"//g'|awk '{if($0>0.01 && $0<=0.02) a+=1}END{print a;}'

    echo ">20ms:"
    awk '{print $NF}' access.log | sort | sed 's/\"//g'|awk '{if($0>0.02) a+=1}END{print a;}'
}


 
function main()
{
    printCount
}
 
main
