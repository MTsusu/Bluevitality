~/[shell/sbin]/rocketmq-start.sh
#!/bin/bash

MQ_HOME=/home/$(whoami)/mq/alibaba-rocketmq-master1

echo "MQ NameServer Start Running!"
cd ${MQ_HOME}/bin/
nohup sh mqnamesrv -c ../conf/mqnamesrv.properties > /dev/null 2>&1 &
echo "MQ NameServer Start Success!"

sleep 2.5

echo "MQ Broker Start Running!"
cd ${MQ_HOME}/bin/
nohup sh mqbroker -c ../conf/2m-noslave/broker-a.properties > /dev/null 2>&1 &
echo "MQ Broker Start Success!"
#------------------------------------------------------------------------------------------------- #RocketMQ关闭: ~/[shell/sbin]/rocketmq-stop.sh
#!/bin/bash

MQ_HOME=/home/$(whoami)/mq/alibaba-rocketmq-master1

echo "MQ Broker Stop Running!"
cd ${MQ_HOME}/bin/
sh mqshutdown broker;
echo "MQ Broker Stop Success!"

sleep 2.5

echo "MQ NameServer Stop Running!"
cd ${MQ_HOME}/bin/
sh mqshutdown namesrv;
echo "MQ NameServer Stop Success!"