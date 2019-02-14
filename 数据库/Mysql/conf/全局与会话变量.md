```txt
获取Mysql的相关可执行命令默认使用的配置：
  [root@localhost ~]# mysql --print-defaults      #客户端
  [root@localhost ~]# mysqld --print-defaults     #服务端

修改全局级别变量：
  mysql > show global variables;
  mysql > set global system_var_name=value;       #方式1
  mysql > set @@global.system_var_name=value;     #方式2

修改会话级别变量：
  mysql > show session variables;                 #默认情况下session关键字可省略...
  mysql > set [session] system_var_name=value;    #方式1
  mysql > set @@[session].system_var_name=value;  #方式2
  
查看服务器状态相关的变量：
  mysql > show global status;
  mysql > show [session] status;                  #查看会话级别的状态变量，默认情况下session关键字可省略...
  mysql > show status like "var_name%";           #Example
```
