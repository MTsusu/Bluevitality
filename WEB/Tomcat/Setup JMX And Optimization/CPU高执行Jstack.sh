#/bin/bash
#auth:macroon

if [ -f "$HOME/jdk/bin/jstack" ]
then
   jstack_cmd="$HOME/jdk/bin/jstack"
else
   jstack_cmd='jstack'
fi
max_num=300

log_path="$HOME/shell/high_cpu"
[[ -d $log_path ]] || mkdir -p $log_path

user=`whoami`
date_f=`date +%Y%m%d%H%M%S`
for key in `ps aux|grep $user|grep  java |grep -v grep |grep -o "instance.id=\S\{1,\}"|awk -F= '{print $2}'`
do
  pid=`ps aux|grep $user|grep -v grep|grep $key|awk '{print $2}'`
  cpu_num=`top -b -n 1 -p $pid | sed -n '8p;8q' | awk '{print $9}'`
  if [ $(echo "$max_num < $cpu_num"|bc) -eq 1 ]
  then
    ps -mp $pid -o THREAD,tid,time > $log_path/${key}_${date_f}_${pid}_tid.log
    $jstack_cmd $pid > $log_path/${key}_${date_f}_${pid}_stack.log
  fi
done   
find $log_path -mtime +30 -type f -name '*.log'  |xargs rm -f
