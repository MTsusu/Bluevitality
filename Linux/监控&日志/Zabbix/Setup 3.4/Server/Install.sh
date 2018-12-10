#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

#数据库...
MYSQL_USERNAME="root"
MYSQL_PASSWORD="123456"     #注意！脚本中有未引用变量的部分
USERNAME="zabbix"

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#使用阿里源
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#依赖
yum -y install zlib-devel glibc-devel curl curl-devel gcc automake
yum -y install net-snmp net-snmp-devel php-common php-devel perl-DBI php-gd php-xml php-bcmath fping OpenIPMI-devel php-mbstring
yum -y install php-xmlrpc php-mhash patch unzip httpd mariadb mariadb-devel php php-mysql
yum -y install libidn-devel openssl-devel rpm-devel php-odbc php-pear unixODBC-devel
yum -y install httpd-devel mysql mysql-devel java-devel wget unzip libxml2 libxml2-devel ncurses-devel
yum -y install unixODBC* libssh2-devel libevent-devel java-1.7.0-openjdk-devel mariadb-server ntpdate 

#同步时间
ntpdate asia.pool.ntp.org

if ! id ${USERNAME} &> /dev/null ; then
    groupadd ${USERNAME}
    useradd -M -g ${USERNAME} ${USERNAME:?'Undefined ...'} -s /sbin/nologin
fi

systemctl enable mariadb
systemctl start  mariadb

mysqladmin  -u${MYSQL_USERNAME} password "${MYSQL_PASSWORD}"
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by '123456';"
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -e "grant all privileges on zabbix.* to 'zabbix'@'127.0.0.1' identified by '123456';"
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -e "flush privileges;"
        
#导入数据
tar -xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4 && zabbix_install_p=$(pwd)
cd database/mysql/
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} zabbix < ./schema.sql
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} zabbix < ./images.sql
mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} zabbix < ./data.sql

#安装zabbix
cd $zabbix_install_p
./configure \
--prefix=/usr/local/zabbix_3.4 \
--enable-server \
--enable-proxy \
--enable-agent \
--with-libcurl \
--with-ssh2 \
--enable-java \
--with-net-snmp \
--with-mysql \
--enable-ipv6 \
--with-libcurl \
--with-libxml2
make install

mkdir -p /usr/local/zabbix_3.4/AlertScripts
chown zabbix.zabbix -R /usr/local/zabbix_3.4/AlertScripts
cd /usr/local/zabbix_3.4/etc

#server
sed -i 's/# DBHost=.*/DBHost=localhost/g' zabbix_server.conf 
sed -i 's/^DBName=.*/DBName=zabbix/g' zabbix_server.conf
sed -i 's/^DBUser=.*/DBUser=zabbix/g' zabbix_server.conf
sed -i 's/# DBPassword=.*/DBPassword=123456/g' zabbix_server.conf
sed -i 's|# AlertScriptsPath=.*|AlertScriptsPath=/usr/local/zabbix_3.4/AlertScripts|g' zabbix_server.conf

#agent
sed -i "s/^Server=.*/Server=127.0.0.1/g" zabbix_agentd.conf
sed -i "s/^ServerActive=.*/Server=127.0.0.1/g" zabbix_agentd.conf
sed -i 's/^Hostname=.*/Hostname=Zabbix server/g' zabbix_agentd.conf

#php
sed -i 's/post_max_size = .*/post_max_size = 64M/g' /etc/php.ini  
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 50M/g' /etc/php.ini
sed -i '/;date.timezone .*/a\date.timezone = PRC' /etc/php.ini 
sed -i 's/max_execution_time = .*/max_execution_time = 600/g' /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 600/g' /etc/php.ini
sed -i 's/memory_limit = .*/memory_limit = 256M/g' /etc/php.ini
sed -i 's|;always_populate_raw_post_data = .*|always_populate_raw_post_data = -1|g' /etc/php.ini 

cd ${zabbix_install_p}/
cp misc/init.d/tru64/zabbix_server /etc/init.d/
cp misc/init.d/tru64/zabbix_agentd /etc/init.d/
chmod a+x /etc/init.d/zabbix_*

cp /usr/local/zabbix_3.4/sbin/{zabbix_agentd,zabbix_server} /usr/local/sbin

#拷贝Web到Web根目录
rm -rf /var/www/html/*
cp -rf frontends/php/* /var/www/html/
cd $zabbix_install_p
cp ../simkai.ttf /var/www/html/fonts/
sed -i "s/DejaVuSans/simkai/g" /var/www/html/include/defines.inc.php  
chmod a+x  /var/www/html/*.php

rm -rf /var/www/html/conf/zabbix.conf.php
cat > /var/www/html/conf/zabbix.conf.php <<END
<?php
// Zabbix GUI configuration file.
global \$DB;
\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = '123456';
// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';
\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = '';
\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
END

#启动
/etc/init.d/zabbix_server start
/etc/init.d/zabbix_agentd start
/usr/local/zabbix_3.4/sbin/zabbix_java/startup.sh

sed -i 's/DirectoryIndex.*/& index.php/g' /etc/httpd/conf/httpd.conf
systemctl start httpd.service
systemctl enable httpd.service
systemctl enable mariadb

#自启
echo "/etc/init.d/zabbix_server start" >> /etc/rc.local
echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
echo "/usr/local/zabbix_3.4/sbin/zabbix_java/startup.sh" >> /etc/rc.local
echo "setenforce 0" >> /etc/rc.local

#关闭SELINUX与防火墙
function disable_sec() {
    setenforce 0 ; sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
    if [ -x /usr/bin/systemctl ] ; then
        #CentOS 7.X
        systemctl disable firewalld #or firewall-cmd--permanent --add-port=XXX/tcp && firewall-cmd-reload
        systemctl stop firewalld
    else
        #CentOS 6.X
        chkconfig iptables off --level 235
        service iptables stop
    fi
} 2> /dev/null

disable_sec

chmod a+x /etc/rc.local

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

# 账号密码：
# Admin / zabbix

exit 0

