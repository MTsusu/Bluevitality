#!/usr/bin/env bash
#-------------------------------------
#  获取某个catalina日志中caused by的数目 ( 检查当天catalina.out日志中，Caused by日志统计和排序 )
#-------------------------------------

if [ $# -eq 0 ]; then
    echo "Note: Please input the characteristic to grep jvm"
    exit 1
fi

pid_characteristic=$1
pid=`ps aux|grep -v grep|grep tomcat|grep $pid_characteristic|grep java|awk '{print $2}'`

HOME_FOLDER=$1
LOG_FOLDER=$HOME_FOLDER"/logs/"
FILE_TO_CHECK="catalina"
suffix="."$(date +"%F")".out"
SENTENCE="Caused by"
ONE_GB_FILE_IN_BYTES=1000000000
ONE_MB_FILE_IN_BYTES=1000000
BIG_FILE_SIZE=$ONE_GB_FILE_IN_BYTES


get_file_name()
{
	file_name=$LOG_FOLDER$FILE_TO_CHECK$suffix
	echo $file_name
}

sort_caused_by()
{
	grep "$SENTENCE" $1 | sort | uniq -c | sort -nr | head -n 10
}

file_size_big()
{
	file_size_in_bytes=$(du -b $1 | awk '{print $1}')
	if (( $file_size_in_bytes > BIG_FILE_SIZE )); then
		echo true
	else
		echo false
	fi
}


today_file_name=$(get_file_name)
file_size_big_result=$(file_size_big $today_file_name)
if [ $file_size_big_result == "true" ]
then
	echo "File size greater than "$BIG_FILE_SIZE" bytes. Can not parse."
else
	sort_caused_by $today_file_name
fi
