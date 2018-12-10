#### Tomcat：/usr/local/tomcat/conf/server.xml
```xml
<!-- 以下代码加入到 Engine 容器中即针对所有 Host 主机生效，也可以单独定义在特定 Host 容器中 -->
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" 
        channelSendOptions="8"> <!-- 发送信道 -->
        <!-- 指明本集群使用的会话管理器 -->
        <Manager className="org.apache.catalina.ha.session.DeltaManager"    
                expireSessionsOnShutdown="false"
                notifyListenersOnReplication="true"/>
        <!-- 定义组信道，用于会话的传递 -->
        <Channel className="org.apache.catalina.tribes.group.GroupChannel"> 
                <!-- 集群成员节点（McastService 多播方式）-->
                <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="228.0.0.4"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>           <!-- 5s/次心跳，30s后剔除 -->
                <!-- 自身如何接受传递来的会话 (注意这里不要使用address=auto，要指定具体的网卡名字)-->
                <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                        address="auto"
                        port="4000"
                        autoBind="100"
                        selectorTimeout="5000"
                        maxThreads="8"/>
                <!-- 自身如何将会话发送给集群 -->
                <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
                        <!-- 如何进行传输（这里使用了并行方式发送） -->
                        <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
                </Sender>
                <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
                <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
        </Channel>
        <Valve className="org.apache.catalina.ha.tcp.ReplicationValve" filter=""/>
        <!-- 可实现基于JVMroute绑定后端tom实例（相当于标记1个会话创建者的标识） -->
        <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>
        <!-- 可实现新增的webapp在集群间的同步创建，自动部署，及会话同步（一般不开启）-->
        <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                tempDir="/tmp/war-temp/"
                deployDir="/tmp/war-deploy/"
                watchDir="/tmp/war-listen/"
                watchEnabled="false"/>
        <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
</Cluster>
<!-- 以上内容定义在Engine容器中，则表示对所有主机均启动用集群功能。如果定义在某Host容器中，则表示仅对此主机启用集群功能。
此外需要注意的是，Receiver中的address="auto"一项的值最好改为当前主机集群服务所对应的网络接口的IP地址。
注意还要在服务器上开启Membership和Receiver使用的端口，使数据可以传输...... -->
```
#### 在需会话同步的 webapps 的 war 内修改其 web.xml 新增 element （ eg: /tomcat/webapps/<*.War>/WEB-INF/web.xml ）
```xml
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                        http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
    version="3.1"
    metadata-complete="true">
    <display-name>Welcome to Tomcat</display-name>
    <description>
       Welcome to Tomcat
    </description>
    <distributable/> <!-- 在web-app容器中加入<distributable/>元素即可，表示其支持会话管理器进行分布式 -->
</web-app>
```
#### 检查运行状态
```bash
[root@localhost1 ~]# cat /usr/local/tomcat/logs/catalina.out
11-Oct-2017 10:24:39.368 INFO [main] org.apache.catalina.ha.tcp.SimpleTcpCluster.startInternal Cluster is about to start
11-Oct-2017 10:24:39.372 INFO [main] org.apache.catalina.tribes.transport.ReceiverBase.bind Receiver Server Socket bound to:/172.16.0.102:4000
11-Oct-2017 10:24:39.379 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.setupSocket Setting cluster mcast soTimeout to 500
11-Oct-2017 10:24:39.381 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Sleeping for 1000 milliseconds to establish cluster membership, start level:4
11-Oct-2017 10:24:40.382 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Done sleeping, membership established, start level:4
11-Oct-2017 10:24:40.383 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Sleeping for 1000 milliseconds to establish cluster membership, start level:8
11-Oct-2017 10:24:41.383 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Done sleeping, membership established, start level:8
11-Oct-2017 10:24:41.384 SEVERE [main] org.apache.catalina.ha.deploy.FarmWarDeployer.start FarmWarDeployer can only work as host cluster subelement!
[root@localhost2 ~]# cat /usr/local/tomcat/logs/catalina.out
11-Oct-2017 10:25:24.956 INFO [main] org.apache.catalina.ha.tcp.SimpleTcpCluster.startInternal Cluster is about to start
11-Oct-2017 10:25:24.960 INFO [main] org.apache.catalina.tribes.transport.ReceiverBase.bind Receiver Server Socket bound to:/172.16.0.104:4000
11-Oct-2017 10:25:24.967 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.setupSocket Setting cluster mcast soTimeout to 500
11-Oct-2017 10:25:24.970 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Sleeping for 1000 milliseconds to establish cluster membership, start level:4
11-Oct-2017 10:25:25.002 INFO [Membership-MemberAdded.] org.apache.catalina.ha.tcp.SimpleTcpCluster.memberAdded Replication member added:org.apache.catalina.tribes.membership.MemberImpl[tcp://{172, 16, 0, 102}:4000,{172, 16, 0, 102},4000, alive=45620, securePort=-1, UDP Port=-1, id={12 42 -64 76 118 -60 72 -75 -116 12 -52 74 71 -108 -100 23 }, payload={}, command={}, domain={}, ]
11-Oct-2017 10:25:25.970 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Done sleeping, membership established, start level:4
11-Oct-2017 10:25:25.971 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Sleeping for 1000 milliseconds to establish cluster membership, start level:8
11-Oct-2017 10:25:25.978 INFO [Tribes-Task-Receiver[Catalina-Channel]-1] org.apache.catalina.tribes.io.BufferPool.getBufferPool Created a buffer pool with max size:104857600 bytes of type: org.apache.catalina.tribes.io.BufferPool15Impl
11-Oct-2017 10:25:26.972 INFO [main] org.apache.catalina.tribes.membership.McastServiceImpl.waitForMembers Done sleeping, membership established, start level:8
11-Oct-2017 10:25:26.972 SEVERE [main] org.apache.catalina.ha.deploy.FarmWarDeployer.start FarmWarDeployer can only work as host cluster subelement!
#可以看出两台服务器已经联系上了，再回过头来看第一台服务器的日志
[root@localhost1 ~]# tail /usr/local/tomcat/logs/catalina.out
11-Oct-2017 10:25:25.007 INFO [Tribes-Task-Receiver[Catalina-Channel]-1] org.apache.catalina.tribes.io.BufferPool.getBufferPool Created a buffer pool with max size:104857600 bytes of type: org.apache.catalina.tribes.io.BufferPool15Impl
11-Oct-2017 10:25:25.974 INFO [Membership-MemberAdded.] org.apache.catalina.ha.tcp.SimpleTcpCluster.memberAdded Replication member added:org.apache.catalina.tribes.membership.MemberImpl[tcp://{172, 16, 0, 104}:4000,{172, 16, 0, 104},4000, alive=1006, securePort=-1, UDP Port=-1, id={5 52 67 -61 66 126 73 -8 -108 76 20 81 -92 58 27 108 }, payload={}, command={}, domain={}, ]
```
#### 创建输出会话用于测试的index.js页面到后端各tomcat的webapps下 （测试可用，前端 Nginx/httpd）
```bash
[root@localhost ~]# cat /usr/local/tomcat/webapps/index.jsp
<%@  page language="java" %>
<html>
  <head><title>test.node1</title></head>
  <body>    <h1><font color="red">"此处替换为当前所在的主机名或域名"</font></h1>
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
```
