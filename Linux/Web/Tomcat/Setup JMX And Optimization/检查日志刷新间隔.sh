#!/usr/bin/env bash
#-------------------------------------
#  检查catalina日志Modify时间，
#  返回上次更新时间离现在的分钟数。 ( 日志刷新监控:日志在30min之内有更新 )
#-------------------------------------

if [ $# -eq 0 ]; then
    echo "Note: Please input home folder of tomcat as the first param."
    exit 1
fi

TIME_TO_MONITOR="Modify"

HOME_FOLDER=$1
LOG_FOLDER=$HOME_FOLDER"/logs/"
FILE_TO_CHECK="catalina"
suffix="."$(date +"%F")".out"

get_file_name()
{
	file_name=$LOG_FOLDER$FILE_TO_CHECK$suffix
	echo $file_name
}

judge_file_refresh_rate()
{
	tail $1 > /dev/null
	EXIT_STATUS=$?
	
	if [ "$EXIT_STATUS" -eq "0" ]
	then
		# echo "We have today's file"
		# judge if today's log file is refreshed regularly.
		# use stat
		last_modify_time=$(stat $1|grep $TIME_TO_MONITOR|awk '{print $3}'|awk -F "." '{print $1}')
		last_modify_hour=$(echo $last_modify_time | awk -F ":" '{print $1}')
		last_modify_min=$(echo $last_modify_time | awk -F ":" '{print $2}')
		last_modify_by_min=$(($last_modify_hour*60+$last_modify_min))
		# echo $last_modify_by_min

		now_time_by_min=$(($(date +"%H")*60+$(date +"%M")))
		# echo $now_time_by_min
		min_elapsed_since_last_modify=$(($now_time_by_min-$last_modify_by_min))
		echo $min_elapsed_since_last_modify
		
	else
		echo "Today's log file does not exist."
	fi
	exit 0
}

today_file_name=$(get_file_name)
judge_file_refresh_rate $today_file_name
