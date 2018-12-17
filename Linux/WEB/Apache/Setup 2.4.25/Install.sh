#!/bin/bash
# Environment CentOS 7.3
# Author: inmoonlight@163.com

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#WEB PATH
mkdir -p /data/www

#depend
yum -y install epel-release gcc gcc-c++ cmake openssl openssl-devel httpd-tools httpd-devel mod_ssl

#erase old file and config ...
rm -rf /usr/local/{apr-*,pcre*,httpd*} /etc/profile.d/httpd24.sh /etc/httpd

#并行
function parallel() {
    NUM=$( awk '/processor/{N++};END{print N}' /proc/cpuinfo )
    if [ $NUM -gt 1 ];then
        make -j $NUM
    else
        make
    fi
    make install
}

#using local
[[ -s apr-util-1.5.4.tar.gz && -s apr-1.5.2.tar.gz && -s httpd-2.4.25.tar.gz ]] || exit 1
tar -zxvf apr-1.5.2.tar.gz -C /usr/local/
tar -zxvf apr-util-1.5.4.tar.gz -C /usr/local/
tar -zxvf pcre-8.40.tar.gz -C /usr/local/
tar -zxvf httpd-2.4.25.tar.gz -C /usr/local/

cd /usr/local/apr-1.5.2
./configure --prefix=/usr/local/apr
parallel

cd /usr/local/apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
parallel

cd /usr/local/pcre-8.40
./configure --prefix=/usr/local/pcre
parallel

cd /usr/local/httpd-2.4.25
./configure \
-prefix=/usr/local/apache2.4.25 \
-sysconfdir=/etc/httpd \
-enable-so \
--enable-ssl \
--enable-cgi \
--enable-zlib \
--enable-module=all \
--enable-mpms-shared=all \
--with-mpm=event \
--enable-cgid \
--enable-deflate \
--enable-rewrite \
--enable-deflate \
--enable-cache \
--enable-disk-cache \
--enable-mem-cache \
--enable-file-cache \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util \
--with-pcre=/usr/local/pcre
parallel

#导出头文件及环境变量
ln -sv /usr/local/apache2.4.25/include/ /usr/include/httpd
export PATH="/usr/local/apache2.4.25/bin:$PATH"
cat >  /etc/profile.d/httpd24.sh <<eof
export PATH=/usr/local/apache2.4.25/bin:$PATH
eof

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

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

#disable_sec

cp /etc/httpd/httpd.conf /etc/httpd/httpd.conf.bak
sed -i "s;#LoadModule rewrite_module modules/mod_rewrite.so;LoadModule rewrite_module modules/mod_rewrite.so\nLoadModule php5_module modules/libphp5.so;" /etc/httpd/httpd.conf
sed -i "s#User daemon#User www#" /etc/httpd/httpd.conf
sed -i "s#Group daemon#Group www#" /etc/httpd/httpd.conf
sed -i "s#<Directory />#<Directory \"/data/www\">#" /etc/httpd/httpd.conf
sed -i "s#AllowOverride None#AllowOverride all#" /etc/httpd/httpd.conf
sed -i "s;#Include /etc/httpd/extra/httpd-vhosts.conf;Include /etc/httpd/extra/httpd-vhosts.conf;" /etc/httpd/httpd.conf
sed -i "s#DirectoryIndex index.html#DirectoryIndex index.html index.htm index.php#" /etc/httpd/httpd.conf

#run
ln -sv /usr/sbin/apachectl /etc/init.d/httpd
apachectl start

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0