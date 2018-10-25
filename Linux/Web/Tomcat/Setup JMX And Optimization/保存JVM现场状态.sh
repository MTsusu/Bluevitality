

pid=$1
port=$2

path="."

jstack -l ${pid} >> ${path}/${pid}-$(date "+F_%H%M%S").txt
jmap -dump:format=b,file={path}/${pid}_dump.hprof.$(date "+F_%H%M%S") ${pid}
netstat -anpt | grep ${port} | awk '{print $6}' | sort -n | uniq -c > {path}/${pid}-netstat.$(date "+F_%H%M%S").txt
