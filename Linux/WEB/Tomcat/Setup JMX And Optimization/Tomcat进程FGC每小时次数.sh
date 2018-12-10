#!/usr/bin/env bash
#-------------------------------------
#  获取FGC的总数，并且把总数和总体运行时间进行比较的脚本
#  最后得到某个Java进程每小时多少次FGC （ 检查Java进程监控，每小时的FGC次数不大于10次 ）
#-------------------------------------

if [ $# -eq 0 ]; then
    echo "Note: Please input the characteristic to grep jvm"
    exit 1
fi

pid_characteristic=$1
pid=`ps aux|grep -v grep|grep tomcat|grep $pid_characteristic|grep java|awk '{print $2}'`
# if there is no PID, should exit program
if [ "$pid" = "" ]
then
	echo "No PID found"
	exit 0
fi

return_column()
{
	# find the FGC column
	fgc_column=`jstat -gcutil $pid | head -n 1 | awk ' { for (i; i<=NF; i++) { if ($i=="FGC") {print i} } } '`
	echo $fgc_column
}

my_fgc_count()
{
	# 输出当前进程的FGC次数
	fgc_column=`jstat -gcutil $pid | head -n 1 | awk ' { for (i; i<=NF; i++) { if ($i=="FGC") {print i} } } '`
	# echo "fgc_column is: $fgc_column"
	
	fgc_count=$(jstat -gcutil $pid | awk '{if (NR>1) print}' | tr -s ' ' | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f$((fgc_column)))
	# fgc_count=$(jstat -gcutil $pid | tail -n 1 | awk '{print $(echo $fgc_column)}'
	echo $fgc_count
}

elapsed_time()
{
	# Output the total elapsed time(in minutes) of a process
	time_str=$(ps -o etime= -p $pid)
	# echo $time_str
	total_min=0
	num_of_field=$(echo $time_str|awk -F '-' '{print NF}')
	if [ $num_of_field -eq "1" ]
	then
		# echo "Just running for no more than 1 day"
		hour=`echo $time_str | awk -F ":" '{print $1}'`
		min=`echo $time_str | awk -F ":" '{print $2}'` 
		total_min=$(($hour*60 + $min))
	elif [ $num_of_field -eq "2" ]
	then
		# echo "Running for more than 1 day"
		day=`echo $time_str | awk -F '-' '{print $1}'`
		time_str=`echo $time_str | awk -F '-' '{print $2}'`
		hour=`echo $time_str | awk -F ":" '{print $1}'`
		min=`echo $time_str | awk -F ":" '{print $2}'` 
		total_min=$(($day*24*60 + $hour*60 + $min))
	else
		total_min="Something wrong with this shell script. Please check source"
	fi
	echo $total_min
}

divide_yield_result()
{
	# fgc_count / elapsed_time by min
	# 最终输出：某个Java进程每小时的FGC次数
	if [ $1 -eq 0 ]; then
		# "NO FGC at all"
		echo 0
	else
		#echo $1
		#echo $2
		fgc_per_min=`echo "scale=6;$1/$2" | bc`
		#fgc_per_min=`awk -v fgc_count="$1" -v process_elapsed_min="$2" 'BEGIN { print "scale=4;"fgc_count/process_elapsed_min}' | bc`
		fgc_per_hour=`echo "scale=6;$fgc_per_min*60" | bc`
		echo $fgc_per_hour
	fi
}

fgc_count=$(my_fgc_count)
elapsed_time=$(elapsed_time)
#echo $fgc_count, $elapsed_time
divide_yield_result $fgc_count $elapsed_time

