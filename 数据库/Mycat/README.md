#### 备忘
```txt
Mycat使用Mysql的通讯协议将自身模拟为Mysql服务器并建立了完整的Schema、Table、User的逻辑模型
其将在自身定义逻辑模型映射到后端存储节点DataNode（MySQL Instance）的真实物理库中
这样所有能使用Mysql的C端及编程语言都能将Mycat认作是Mysql-Server来使用而不必开发新的客户端协议...

当Mycat收到客户端发送的SQL请求时会先对SQL进行语法分析和检查，并将结果用于SQL的路由：
    SQL路由策略支持传统的基于表格的分片字段方式进行分片，也支持独有的基于数据库E-R关系的分片策略
    对于路由到多个数据节点（DataNode）的SQL，则会对收到的数据集进行"归并"后输出到客户端...

DataNode是Mycat的逻辑数据节点，映射到后端的某个物理数据库的Database：
为了做到系统高可用每个DataNode可配置多个引用地址（DataSource）
当主DataSource被检测为不可用时系统会自动切换到下一个可用的DataSource，这里的DataSource可理解为Mysql的主从地址

与任何传统RDBMS相同，Mycat也提供了"数据库"的定义，并有用户授权的功能，下面是其逻辑库相关的概念：
schema:
    即逻辑库，它与后端Mysql中的Database对应，一个逻辑库中定义了其中所包括的Table
    
table：
    即逻辑库中的表，即物理数据库中存储的某张表，与传统数据库不同的是这里的表格要声明其所存储的逻辑数据节点DataNode
    这是通过表格的分片规则定义来实现的，table可以定义其所属的"子表(childTable)"，子表的分片依赖于与"父表"的具体分片地址
    简单说就是属于父表里某一条记录A的子表的所有记录都与A存储在同一个分片上。
        分片规则：
            是一个字段与函数的捆绑定义，根据这个字段的取值来返回所在存储的分片（DataNode）的序号
            每个表格可以定义一个分片规则，分片规则可以灵活扩展，默认提供了基于数字的分片规则，字符串的分片规则等。
dataNode: 
    Mycat的逻辑数据节点，是存放table的具体物理节点，也称之为分片节点
    通过DataSource来关联到后端某个具体数据库上，一般来说，为了高可用性，每个DataNode都设置两个DataSource，一主一从
    当主节点宕机，系统自动切换到从节点。

dataHost：
    定义某个物理库的访问地址，用于捆绑到dataNode上。
    
Mycat目前通过配置文件的方式来定义逻辑库和相关配置：
    MYCAT_HOME/conf/schema.xml  定义逻辑库，表、分片节点等内容
    MYCAT_HOME/conf/rule.xml    定义分片规则
    MYCAT_HOME/conf/server.xml  定义用户以及应用相关的配置，如访问权限及端口等
```
#### 部署 Mycat
```bash
[root@localhost ~]# mysql_install_db            #数据库初始化
[root@localhost ~]# systemctl start mariadb     #启动数据库服务
[root@localhost ~]# cat /etc/my.cnf             #修改配置，加入参数：lower_case_table_names = 1  
[mysqld]
.......(略)                                     #注意! 远程 mysql 必须允许 mycat主机进行远程连接
lower_case_table_names = 1                      #表存储在磁盘是小写的，但比较时不区分大小写，使用Mycat时需要此设置

[root@localhost ~]# mysql -u <username> -p<password>                        #创建测试数据库
MariaDB [(none)]> CREATE database db1;
MariaDB [(none)]> CREATE database db2;
MariaDB [(none)]> CREATE database db3;

[root@localhost ~]# tar -zxf jdk-8u91-linux-x64.tar.gz -C /usr/local        #安装JDK
[root@localhost ~]# cat /etc/profile.d/java.sh                              #设置环境变量
export JAVA_HOME=/usr/java/jdk1.8.0_91   
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar  
export PATH=$PATH:$JAVA_HOME/bin
[root@localhost ~]# source /etc/profile
[root@localhost ~]# java -version                                           #测试安装是否正确
openjdk version "1.8.0_151"
OpenJDK Runtime Environment (build 1.8.0_151-b12)
OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)

[root@localhost ~]# tar -zxf Mycat-server-1.6-RELEASE-20161012170031-linux.tar.gz -C /usr/local/
[root@localhost ~]# groupadd mycat                                          #创建运行用户
[root@localhost ~]# adduser -r -g mycat mycat                               #
[root@localhost ~]# chown -R mycat.mycat /usr/local/mycat                   #
[root@localhost ~]# cd /usr/local/mycat/
[root@localhost ~]# vim /usr/local/mycat/conf/server.xml                    #修改 server.xml
......                                                                      #配置mycat的用户名密码
<user name="user">  
    <property name="password">password</property>  
    <property name="schemas">DBname</property>  
    <property name="readOnly">false</property>  
</user> 
[root@localhost ~]# vim /usr/local/mycat/conf/schema.xml                    #修改 schema.xml  
......                                                                      #设置读写分离及自动切换
</writeHost>
<?xml version="1.0"?>  
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">  
<mycat:schema xmlns:mycat="http://io.mycat/">  
    <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dn1"></schema>  
    <dataNode name="dn1" dataHost="localhost1" database="test" />  
    <dataHost name="localhost1" maxCon="1000" minCon="10" balance="1" writeType="0"  
             dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">  
        <heartbeat>show slave status</heartbeat>  
        <!-- can have multi write hosts -->  
        <writeHost host="hostM1" url="<address>:<port>" user="<user>" password="<password>">  
            <!-- can have multi read hosts -->  
            <readHost host="hostS1" url="<address>:<port>" user="<user>" password="<password>" />
        </writeHost>
        <writeHost host="hostM2" url="localhost:3307" user="root" password="123456"/>  
    </dataHost>  
</mycat:schema> 
.....
[root@localhost ~]# /usr/local/mycat/bin/mycat start                                #启动mycat
[root@localhost ~]# mysql -uroot -pMYCAT_PASSOWRD -h127.0.0.1 -P8066 -DTESTDB       #链接mycat
MariaDB [(none)]> use TESTDB;                                                       #创建测试数据
MariaDB [(none)]> create table company(id int not null primary key,name varchar(50),addr varchar(255));
MariaDB [(none)]> insert into company values(1,"facebook","usa");
[root@localhost ~]# #验证其他数据库是否存在相同数据...
```
