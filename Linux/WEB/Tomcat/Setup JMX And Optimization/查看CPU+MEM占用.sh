ps aux|grep -v grep|grep tomcat|grep {{%4%}}|grep java|awk '{print $2}'|xargs -i ps -p {} -o %cpu,%mem|awk '{if (NR>1) print $1}'
