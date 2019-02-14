#!/bin/sh

#Jenkins启动时读取此环境变量作为其工作空间路径
export JENKINS_HOME="/home/zyzx/jenkins/tomcat_jenkins2/jenkins"

#JVM优化部分
export JAVA_OPTS="${JAVA_OPTS}"" -Xms512m -Xmx2048m -XX:PermSize=64m -XX:MaxPermSize=512m -Dfile.encoding=UTF-8 -Dhudson.util.ProcessTree.disable=true -Doracle.jdbc
.V8Compatible=true -Dappframe.server.name=release_tomcat_jenkins -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/zyzx/jenkins/tomcat_jenkins/logs/oom.hprof"
echo "JAVA_OPTS=${JAVA_OPTS}"

JAVA_HOME=/home/zyzx/jdk1.8.0_60

