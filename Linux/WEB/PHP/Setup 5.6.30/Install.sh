#!/bin/bash

PHP_HOME="/usr/local/php-5.6"
PHP_BIN_HOME="${PHP_HOME}/bin"
PHP_SBIN_HOME="${PHP_HOME}/sbin"
PHP_CONF_PATH="${PHP_HOME}/etc"
ICONV_HOME="/usr/local/libiconv"

set -e
set -x

#php user
if ! id www 2> /dev/null; then
    useradd www -M -s /sbin/nologin
fi 

#依赖
yum -y install epel-release 
yum -y install gd gd-devel php-gd zlib zlib-devel openssl openssl-devel libxml2 libxml2-devel libjpeg \
libjpeg-devel libpng libpng-devel libmcrypt php-mcrypt libmcrypt libmcrypt-devel curl-devel mhash mcrypt \
libxslt-devel freetype-devel bzip2

#检查本地安装包
[[ -s php-5.6.30.tar.bz2 && -s libiconv-1.13.1.tar.gz ]] || exit 1
rm -rf {php-5.6.30,libiconv-1.13.1,$PHP_HOME,$ICONV_HOME,/etc/php.ini,/etc/php-fpm.conf,/var/log/php}

#iconv
p=$(pwd)
tar -zxvf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1
./configure --prefix=${ICONV_HOME}
make
make install

#php
cd $p
tar jxvf php-5.6.30.tar.bz2
cd php-5.6.30
./configure \
--prefix="${PHP_HOME}" \
--bindir="${PHP_BIN_HOME}" \
--sbindir="${PHP_SBIN_HOME}" \
--with-config-file-path="${PHP_CONF_PATH}" \
--with-iconv="${ICONV_HOME}" \
--with-xsl \
--with-pear \
--with-mcrypt \
--with-curl \
--with-gd \
--with-mysql=mysqlnd \
--with-openssl \
--with-pcre-regex \
--with-libdir=lib \
--with-libxml-dir \
--with-mysqli=shared,mysqlnd \
--with-pdo-mysql=shared,mysqlnd \
--with-pdo-sqlite \
--with-png-dir \
--with-jpeg-dir \
--with-zlib \
--with-xmlrpc \
--enable-ftp \
--enable-gd-native-ttf \
--enable-mysqlnd \
--enable-bcmath \
--enable-mbstring \
--enable-fpm \
--enable-sockets \
--enable-zip \
--enable-inline-optimization \
--enable-shared \
--enable-libxml \
--enable-xml \
--enable-shmop \
--enable-sysvsem \
--enable-mbregex \
--enable-pcntl \
--enable-soap \
--enable-session \
--enable-opcache \
--enable-maintainer-zts \
--enable-fileinfo \
--enable-fpm \
--enable-sockets
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install

#配置文件
[ -f /etc/php.ini ] && mv /etc/php.ini /etc/php.ini.bak
[ -f /etc/php-fpm.conf ] && mv /etc/php-fpm.conf /etc/php-fpm.conf.bak

#adjust php.ini
cp -rf ./php.ini-production /etc/php.ini
sed -i "s#; extension_dir = \"\.\/\"#extension_dir = \"${PHP_HOME}/lib/php/extensions/no-debug-non-zts-20131226/\"#"  /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai /g' /etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini

#adjust php-fpm 
mkdir -p /var/log/php
cp -rf  ${PHP_HOME}/etc/php-fpm.conf.default /etc/php-fpm.conf
sed -i 's,user = nobody,user=www,g'   /etc/php-fpm.conf
sed -i 's,group = nobody,group=www,g'   /etc/php-fpm.conf
sed -i 's,^pm.min_spare_servers = 1,pm.min_spare_servers = 5,g'   /etc/php-fpm.conf
sed -i 's,^pm.max_spare_servers = 3,pm.max_spare_servers = 35,g'   /etc/php-fpm.conf
sed -i 's,^pm.max_children = 5,pm.max_children = 100,g'   /etc/php-fpm.conf
sed -i 's,^pm.start_servers = 2,pm.start_servers = 20,g'   /etc/php-fpm.conf
sed -i 's,;pid = run/php-fpm.pid,pid = run/php-fpm.pid,g'   /etc/php-fpm.conf
sed -i 's,;error_log = log/php-fpm.log,error_log = /var/log/php/php-fpm.log,g'   /etc/php-fpm.conf
sed -i "s,;slowlog = .*,slowlog = /var/log/php/php.log.slow,g"  /etc/php-fpm.conf

ln -sv /etc/php-fpm.conf ${PHP_HOME}/etc/php-fpm.conf

#self start
install -v -m755 ./sapi/fpm/php-fpm  /etc/init.d/php-fpm

#环境变量
echo "export PATH=${PHP_BIN_HOME}:${PHP_SBIN_HOME}:$PATH" >> /etc/profile
source /etc/profile

#PHP-FPM
/etc/init.d/php-fpm -c /etc/php.ini -y /etc/php-fpm.conf
echo "/etc/init.d/php-fpm -c /etc/php.ini -y /etc/php-fpm.conf" >> /etc/rc.local

echo "Script Execution Time： $SECONDS"

exit 0
