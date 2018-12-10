#Tomcat启动: ~/[shell/sbin]/<project_name>-start.sh
#!/bin/bash

#工程名称
PROJECT_NAME="fupin"
#节点名称
NODE_NAME="tomcat_fupinbusi"
#TOMCAT节点数(从"1"开始)
NODE_NUMBERS=4

TOMCAT_HOME="/home/$(whoami)/${PROJECT_NAME}/${NODE_NAME}"


for i in `eval echo "{1..$NODE_NUMBERS}"`
{
    cd ${TOMCAT_HOME}${i}/bin && sh ./startup.sh
    [ $? -eq 0 ] && echo "${TOMCAT_HOME}${i} is running ..."
    sleep 2
}

#------------------------------------------------------------------------------------------------- 
#Tomcat关闭: ~/[shell/sbin]/<project_name>-stop.sh
#!/bin/bash

#工程名称
PROJECT_NAME="fupin"
#节点路径
PROJECT_NODE_FULL_PATH="/home/$(whoami)/${PROJECT_NAME}/release_tomcat_fupinbusi"

PID_LIST=$(ps -ef | grep ${PROJECT_NODE_FULL_PATH} | grep -v "grep|tail" | awk '{print $2}')

if [ "PID_LIST" = "" ]
then
    echo "tomcat service not running"
else
    echo "tomcat pid list : ${PID_LIST}"
    kill -9 ${PID_LIST}
    echo "tomcat pid kill : ${PID_LIST}"
    echo "${PROJECT_NAME} service is stop success!"
fi
