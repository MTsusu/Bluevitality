jstack -l pid >> pid.txt
jmap -dump:format=b,file=pid_dump.dat pid
netstat -anpt | grep port | awk '{print $6}' | sort -n | uniq -c
