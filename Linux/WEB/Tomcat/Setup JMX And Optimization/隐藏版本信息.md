##### 首先备份tomcat
##### 首先找到这个jar包：$TOMCAT_HOME/lib/catalina.jar
##### 解压catalina.jar后按路径\org\apache\catalina\util\ServerInfo.properties找到文件
##### vim ServerInfo.properties 
```bash
#把 "server.number、server.built" 置空
server.info=Apache Tomcat
server.number=
server.built=
```
##### 重新打成jar包
```bash
cd  /tomcat/lib
jar uvf catalina.jar org/apache/catalina/util/ServerInfo.properties
```
##### 重启tomcat
