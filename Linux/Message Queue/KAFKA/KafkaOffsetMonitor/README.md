```bash
#!/bin/bash

java -cp KafkaOffsetMonitor-assembly-0.2.0.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb \
--zk 10.0.0.50:12181,10.0.0.60:12181,10.0.0.70:12181 \
--port 8088 \
--refresh 5.seconds \
--retain 1.days  > /dev/null 2>&1;

# zk ：zookeeper主机地址，如果有多个，用逗号隔开
# port ：应用程序端口
# refresh ：应用程序在数据库中刷新和存储点的频率
# retain ：在db中保留多长时间
# dbName ：保存的数据库文件名，默认为offsetapp

#访问：curl `hostname -i`:8088/
```