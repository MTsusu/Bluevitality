#### 说明
```txt
编译安装 zabbix server 时需要事先安装好JDK并在编译 zabbix 时加 "--enable-java" 参数来支持jmx监控!...

首先要了解一下对应关系：
  1. zabbix_server开启java poller
  2. zabbx_java开启JavaGateway，端口为10052
  3. Tomcat JMX默认开启12345提供性能数据

数据获取流程：
  java poller <--> JavaGateway:10052 <--> Tomcat:12345.
```
#### Zabbix Server端
```bash
#JavaGateway服务器地址，zabbix-server与zabbix_java_gateway在同台服务器
[root@localhost ~]# sed -i "s/# JavaGateway=/JavaGateway=192.168.0.3/g" /usr/local/zabbix_3.4/etc/zabbix_server.conf
[root@localhost ~]# sed -i "s/# JavaGatewayPort=.*/JavaGatewayPort=10052/g" /usr/local/zabbix_3.4/etc/zabbix_server.conf

#设置javaGateway抓取数据的进程数，当设置为0时表示不具有抓取java信息的能力
[root@localhost ~]# sed -i "s/# StartJavaPollers=.*/StartJavaPollers=6/g" /usr/local/zabbix_3.4/etc/zabbix_server.conf
[root@localhost ~]# /etc/init.d/zabbix_server restart

[root@localhost ~]# echo LISTEN_IP="0.0.0.0" >> /usr/local/zabbix_3.4/sbin/zabbix_java/settings.sh 
[root@localhost ~]# echo LISTEN_PORT=10052 >> /usr/local/zabbix_3.4/sbin/zabbix_java/settings.sh 
[root@localhost ~]# echo "START_POLLERS=5" >> /usr/local/zabbix_3.4/sbin/zabbix_java/settings.sh 
[root@localhost ~]# echo "TIMEOUT=3" >> /usr/local/zabbix_3.4/sbin/zabbix_java/settings.sh 
[root@localhost ~]# /usr/local/zabbix_3.4/sbin/zabbix_java/startup.sh       #启动zabbix端的Java-gateway
[root@localhost ~]# netstat -atupnl | grep 10052
tcp6       0      0 :::10052                :::*                    LISTEN      1734/java

[root@localhost ~]# #建议重启一下zabbix服务
```

#### 在Tomcat端开启JVM监控
```bash
# JMX的安装流程参考：
# https://github.com/bluevitality/Bluevitality/blob/master/Linux/Web%20Service/Tomcat/Setup%20JMX/Install.sh
# 测试：
[root@localhost ~]# java -jar cmdline-jmxclient.jar - 127.0.0.1:${PORT} java.lang:type=Memory NonHeapMemoryUsage
11/20/2017 20:29:25 +0800 de.layereight.jmxcmd.Client NonHeapMemoryUsage: 
committed: 41517056
init: 2555904
max: -1
used: 40136040
```

#### 修改Host监控配置，添加JMX地址和端口并套用自带的JMX模板
```bash
# 自带模板：
# Template App Apache Tomcat JMX
# Template App Generic Java JMX
```
