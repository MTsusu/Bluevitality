#### 在各Tomcat主机中按如下流程设置
```bash
# 项目设置参考：
# https://github.com/magro/memcached-session-manager/wiki/SetupAndConfiguration
# 利用 Value（Tomcat 阀）对Request进行跟踪
# Request请求到来时，从memcached加载session
# Request请求结束时，将tomcat session更新至memcached，以达到session共享之目的
# 支持 sticky 和 non-sticky 模式

[root@localhost ~]# #将本目录的各jar文件放置 $CATALINA_HOME/lib/ 中（jar文件对应的版本为tomcat8）
[root@localhost ~]# cd /usr/local/tomcat/lib
[root@localhost lib]# mv ~/* .
[root@localhost lib]# ll
总用量 7932
-rwxrwxrwx. 1 root root   17353 12月  2 2015 annotations-api.jar
-rwxrwxrwx. 1 root root   53033 12月  2 2015 catalina-ant.jar
-rwxrwxrwx. 1 root root  120063 12月  2 2015 catalina-ha.jar
-rwxrwxrwx. 1 root root 1549955 12月  2 2015 catalina.jar
-rwxrwxrwx. 1 root root   74655 12月  2 2015 catalina-storeconfig.jar
-rwxrwxrwx. 1 root root  270671 12月  2 2015 catalina-tribes.jar
-rwxrwxrwx. 1 root root 2310271 12月  2 2015 ecj-4.4.2.jar
-rwxrwxrwx. 1 root root   81428 12月  2 2015 el-api.jar
-rwxrwxrwx. 1 root root  161367 12月  2 2015 jasper-el.jar
-rwxrwxrwx. 1 root root  586127 12月  2 2015 jasper.jar
-rwxrwxrwx. 1 root root  452748 12月 13 22:14 javolution-5.4.3.1.jar                     #
-rwxrwxrwx. 1 root root   61417 12月  2 2015 jsp-api.jar
-rwxrwxrwx. 1 root root  147025 12月 13 21:49 memcached-session-manager-1.8.3.jar        #
-rwxrwxrwx. 1 root root   10407 12月 13 21:52 memcached-session-manager-tc8-1.8.3.jar    #
-rwxrwxrwx. 1 root root   71051 12月 13 21:55 msm-javolution-serializer-1.8.3.jar        #
-rwxrwxrwx. 1 root root  244281 12月  2 2015 servlet-api.jar
-rwxrwxrwx. 1 root root  459447 12月 13 22:00 spymemcached-2.11.1.jar                    #
-rwxrwxrwx. 1 root root    9278 12月  2 2015 tomcat-api.jar
-rwxrwxrwx. 1 root root  709499 12月  2 2015 tomcat-coyote.jar
-rwxrwxrwx. 1 root root  244813 12月  2 2015 tomcat-dbcp.jar
-rwxrwxrwx. 1 root root   67841 12月  2 2015 tomcat-i18n-es.jar
-rwxrwxrwx. 1 root root   41471 12月  2 2015 tomcat-i18n-fr.jar
-rwxrwxrwx. 1 root root   43588 12月  2 2015 tomcat-i18n-ja.jar
-rwxrwxrwx. 1 root root  135946 12月  2 2015 tomcat-jdbc.jar
-rwxrwxrwx. 1 root root   31475 12月  2 2015 tomcat-jni.jar
-rwxrwxrwx. 1 root root  105125 12月  2 2015 tomcat-util.jar
-rwxrwxrwx. 1 root root  201024 12月  2 2015 tomcat-util-scan.jar
-rwxrwxrwx. 1 root root  214115 12月  2 2015 tomcat-websocket.jar
-rwxrwxrwx. 1 root root   36603 12月  2 2015 websocket-api.jar
[root@localhost lib]# chmod 777 *
# [root@localhost lib]# #指明webapps的应用程序当中使用哪种序列化工具 （此步骤跳过...）
# <dependency>
#     <groupId>de.javakaffee.msm</groupId>
#     <artifactId>msm-kryo-serializer</artifactId>
#     <version>1.9.7</version>
#     <scope>runtime</scope>
# </dependency>
[root@localhost lib]# 设置 context 中 manager 使用的类为：de.javakaffee.web.msm.MemcachedBackupSessionManager
[root@localhost lib]# vim /usr/local/tomcat/conf/server.xml
<Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">
    <!-- 在Host段或Context段内部增加如下 <Manage> 段的内容...(建议不要放在host段，经测试有问题!!...)  -->
    <!-- 若将其放在 <Context> 段中时，docbase="" 要使用绝对路径!  -->
    <Context path="/test" docBase="/usr/local/tomcat/webapps/test" reloadable="true">
      ...
      <!-- memcachedNodes 至少需要2个，另一个作为备机 -->
      <!-- memcachedNodes="memcached主机标识:memcahed主机地址,memcached主机标识:memcahed主机地址..." -->
      <!-- failoverNodes 指明哪个主机标识作为备机（提供故障转移） -->
      <!-- transcoderFactoryClass= 替换为：de.javakaffee.web.msm.serializer.javolution.JavolutionTranscoderFactory -->
      <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
        memcachedNodes="n1:192.168.0.6:11211,n2:192.168.0.7:11211"
        failoverNodes="n2"
        requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
        transcoderFactoryClass="de.javakaffee.web.msm.serializer.javolution.JavolutionTranscoderFactory"
        />
    </Context>
</Host>
[root@localhost bin]# ./catalina.sh configtest                  #测试server.xml配置正确性... 
[root@localhost bin]# mkdir -p /usr/local/tomcat/webapps/test/WEB-INF/{classes,lib} #此步骤不能省略
[root@localhost bin]# cd /usr/local/tomcat/webapps/test         #         
[root@localhost test]# cat index.jsp                            #编辑session测试页面：index.jsp
<%@  page language="java" %>
<html>
  <head><title>test.node1</title></head>
  <body>    <h1><font color="red">"此处替换为当前所在的主机名或域名"</font></h1>
    <table align="centre" border="1">
      <tr>
        <td>Session ID</td>
    <% session.setAttribute("test.org","test.org"); %>
        <td><%= session.getId() %></td>
      </tr>
      <tr>
        <td>Created on</td>
        <td><%= session.getCreationTime() %></td>
     </tr>
    </table>
</body>
</html>
[root@localhost test]# rm -rf /usr/local/tomcat/work/Catalina/localhost/* 
[root@localhost test]# /usr/local/tomcat/bin/startup.sh 
```
#### Testing....
```txt
在Tomcat前端设置Nginx对后端的Tomcat进行rr负载均衡，查看其session是否发生改变
```
