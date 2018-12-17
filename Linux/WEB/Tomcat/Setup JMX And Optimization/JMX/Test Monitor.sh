#/bin/bash
#Test ...
#被监控端去要临时关闭 CATALINA_OPTS 中的 Dcom.sun.management.jmxremote.authenticate 设置

HOST="192.168.139.132"
PORT="6789"

[ -x cmdline-jmxclient.jar ] || echo "I Need jmxclient.jar~ :) "

java -jar cmdline-jmxclient.jar - ${HOST}:${PORT} java.lang:type=Memory NonHeapMemoryUsage

