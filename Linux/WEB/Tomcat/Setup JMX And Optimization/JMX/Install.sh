#!/bin/bash


TOMCAT_CONF_PATH="/usr/local/tomcat/conf"

#JMX密码（简单密码会报错）
MONITORROLE_PASSWORD="QAZzaq123"
CONTROLROLE_PASSWORD="QAZzaq456"

#JMX(监听在本机的哪个接口，用于配合Zabbix的JMX)
HOST="192.168.139.137"
PORT="6789"

JMXREMOTE_ACCESS_FILE=$(rpm -ql java-1.8.0-openjdk-headless-1.8.0.151-1.b12.el7_4.x86_64 | grep "jmxremote.access")
JMXREMOTE_PASS_FILE=$(rpm -ql java-1.8.0-openjdk-headless-1.8.0.151-1.b12.el7_4.x86_64 | grep "jmxremote.password")

echo "monitorRole ${MONITORROLE_PASSWORD:?Undefined}" >> ${JMXREMOTE_PASS_FILE}
echo "controlRole ${CONTROLROLE_PASSWORD:?Undefined}" >> ${JMXREMOTE_PASS_FILE}


#删除旧文件
rm -f ${JMXREMOTE_PASS_FILE%\.*}
rm -f ${TOMCAT_CONF_PATH}/jmxremote.*


cp -af ${JMXREMOTE_PASS_FILE} ${JMXREMOTE_PASS_FILE%\.*}    #移除tompalte后缀：
cp -af ${JMXREMOTE_PASS_FILE%\.*} ${JMXREMOTE_ACCESS_FILE}  ${TOMCAT_CONF_PATH}


chmod 600 ${TOMCAT_CONF_PATH}/jmxremote.*

x=`mktemp`
cat > $x <<eof
CATALINA_OPTS="
\$CATALINA_OPTS
-Dcom.sun.management.jmxremote
-Djava.rmi.server.hostname=${HOST}
-Dcom.sun.management.jmxremote.port=${PORT}
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=true
-Dcom.sun.management.jmxremote.password.file=${TOMCAT_CONF_PATH}/jmxremote.password
-Dcom.sun.management.jmxremote.access.file=${TOMCAT_CONF_PATH}/jmxremote.access" 
eof

sed -i "/Execute The Requested Command/r $x" ${TOMCAT_CONF_PATH/conf/bin/catalina.sh}

> $x

${TOMCAT_CONF_PATH/conf/bin/shutdown.sh}  && sleep 1

${TOMCAT_CONF_PATH/conf/bin/startup.sh}  

netstat -atupnl | grep ${PORT}

exit 0
