#### KAFKA
```bash
注！kafka的启动脚本需要开启JMX设置：
vi kafka-server-start.sh
if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-server -Xms2G -Xmx2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70"
    export JMX_PORT="9999"
fi
```
#### 部署
```bash
cat >  ~/.bash_profile <<'EOF'
export JAVA_HOME=$HOME/jdk8
export KE_HOME=/data/soft/new/kafka-eagle
export PATH=$PATH:$JAVA_HOME/bin:$KE_HOME/bin
EOF

cat > $KE_HOME/conf/system-config.properties <<'EOF'
######################################
# multi zookeeper&kafka cluster list
######################################
kafka.eagle.zk.cluster.alias=cluster1
cluster1.zk.list=172.22.241.37:2181,172.22.241.38:2181,172.22.241.39:2181
#cluster2.zk.list=..........
######################################
# zk client thread limit
######################################
kafka.zk.limit.size=25

######################################
# kafka eagle webui port
######################################
kafka.eagle.webui.port=8048

######################################
# kafka offset storage
######################################
cluster1.kafka.eagle.offset.storage=kafka

######################################
# enable kafka metrics
######################################
kafka.eagle.metrics.charts=true
kafka.eagle.sql.fix.error=false

######################################
# kafka sql topic records max
######################################
kafka.eagle.sql.topic.records.max=5000

######################################
# alarm email configure
######################################
kafka.eagle.mail.enable=false
kafka.eagle.mail.sa=alert_sa
kafka.eagle.mail.username=alert_sa@163.com
kafka.eagle.mail.password=mqslimczkdqabbbh
kafka.eagle.mail.server.host=smtp.163.com
kafka.eagle.mail.server.port=25

######################################
# alarm im configure
######################################
#kafka.eagle.im.dingding.enable=true
#kafka.eagle.im.dingding.url=https://oapi.dingtalk.com/robot/send?access_token=
#kafka.eagle.im.wechat.enable=true
#kafka.eagle.im.wechat.url=https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=
#kafka.eagle.im.wechat.touser=
#kafka.eagle.im.wechat.toparty=
#kafka.eagle.im.wechat.totag=
#kafka.eagle.im.wechat.agentid=

######################################
# delete kafka topic token
######################################
kafka.eagle.topic.token=keadmin

######################################
# kafka sasl authenticate
######################################
kafka.eagle.sasl.enable=false
kafka.eagle.sasl.protocol=SASL_PLAINTEXT
kafka.eagle.sasl.mechanism=PLAIN

######################################
# kafka jdbc driver address
######################################
kafka.eagle.driver=org.sqlite.JDBC
kafka.eagle.url=jdbc:sqlite:/tmp/ke.db
kafka.eagle.username=test
kafka.eagle.password=test
EOF

chmod +x $KE_HOME/bin/ke.sh
cd $KE_HOME
./ke.sh start

#ke.sh start	        启动Kafka Eagle系统
#ke.sh stop	            停止Kafka Eagle系统
#ke.sh restart	        重启Kafka Eagle系统
#ke.sh status	        查看Kafka Eagle系统运行状态
#ke.sh stats	        统计Kafka Eagle系统占用Linux资源情况
#ke.sh find [ClassName]	查看Kafka Eagle系统中的类是否存在
```


