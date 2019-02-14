#### 部署前提
- NTP 同步完成
- 在执行脚本前修改 HOSTNAME 变量，/etc/hosts ...
- SSH 公钥互信
#### 安装流程 ( 仅适用于 CentOS 7，但测试安装还未通过 )
```bash
# Download URL: http://linux-ha.org/wiki/Download 
# 参考： http://blog.csdn.net/shudaqi2010/article/details/77072589
# 所需要的软件在当前目录内....

[root@localhost ~]# yum install -y bzip2 gcc autoconf automake libtool libtool-ltdl-devel \
glib2-devel libxml2 libxml2-devel bzip2-devel e2fsprogs-devel libxslt-devel \
make wget docbook-dtds docbook-style-xsl asciidoc libuuid-devel

[root@localhost ~]# tar -jxf 0a7add1d9996.tar.bz2 && cd Reusable-Cluster-Components-glue--0a7add1d9996/
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# ./autogen.sh   #看到 Now run ./configure 表示自动生成完成
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# useradd ha
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# CLUSTER_USER="ha"
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# CLUSTER_GROUP=${CLUSTER_USER}
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# ./configure  --prefix=/usr/local/heartbeat \
--with-daemon-user=${CLUSTER_USER} \
--with-daemon-group=${CLUSTER_GROUP} \
--enable-fatal-warnings=no \
LIBS='/lib64/libuuid.so.1'
#必须将Cluster Glue和resource-agents和heartbeat都安装在同一目录，因为heartbeat需要依赖这些库
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# make 
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# make install
[root@localhost Reusable-Cluster-Components-glue--0a7add1d9996]# cd ~

[root@localhost ~]# tar -zxf resource-agents-3.9.6.tar.gz && cd resource-agents-3.9.6
[root@localhost resource-agents-3.9.6]# export CFLAGS="$CFLAGS -I/usr/local/heartbeat/include -L/usr/local/heartbeat/lib"
[root@localhost resource-agents-3.9.6]# ./autogen.sh
[root@localhost resource-agents-3.9.6]# ./configure --prefix=/usr/local/heartbeat
[root@localhost resource-agents-3.9.6]# ln -s  /usr/local/heartbeat/lib/* /lib/ 
[root@localhost resource-agents-3.9.6]# ln -s  /usr/local/heartbeat/lib/* /lib64/
[root@localhost resource-agents-3.9.6]# make 
[root@localhost resource-agents-3.9.6]# make install
[root@localhost resource-agents-3.9.6]# cd ~

[root@localhost ~]# tar -jxf 958e11be8686.tar.bz2 && cd Heartbeat-3-0-958e11be8686/
[root@localhost Heartbeat-3-0-958e11be8686]# ./bootstrap
[root@localhost Heartbeat-3-0-958e11be8686]# export CFLAGS="$CFLAGS -I/usr/local/heartbeat/include -L/usr/local/heartbeat/lib"
[root@localhost Heartbeat-3-0-958e11be8686]# ./configure --prefix=/usr/local/heartbeat --enable-fatal-warnings=no \
LIBS='/lib64/libuuid.so.1'
#若出现如下警告：
  CC_WARNINGS              = " -Wall -Wmissing-prototypes -Wmissing-declarations...........(略)
  Mangled CFLAGS           = " -I /usr/local/heartbeat/include -L /usr/local/hea...........(略)
  Libraries                = "-lbz2 -lz -lc -luuid -lrt -ldl  -lltdl"
  RPATH enabled            = ""
  Distro-style RPMs        = "no"
[root@localhost Heartbeat-3-0-958e11be8686]# vim /usr/local/heartbeat/include/heartbeat/glue_config.h
# 原因：   glue.config.h 中的宏 HA_HBCONF_DIR 被定义了多次
# 解决：   注释掉最后一行定义宏的代码
[root@localhost Heartbeat-3-0-958e11be8686]# make
# 若出现如下警告：
gmake[1]: *** [all-recursive] Error 1
gmake[1]: Leaving directory `/usr/local/src/Heartbeat-3-0-958e11be8686/lib‘
make: *** [all-recursive] Error 1
# 解决：在 configure 时加入：LIBS='/lib64/libuuid.so.1'
[root@localhost Heartbeat-3-0-958e11be8686]# make install
[root@localhost Heartbeat-3-0-958e11be8686]# #cp doc/{ha.cf,haresources,authkeys} /usr/local/heartbeat/etc/ha.d/
[root@localhost Heartbeat-3-0-958e11be8686]# #chmod 600 /usr/local/heartbeat/etc/ha.d/authkeys

```
