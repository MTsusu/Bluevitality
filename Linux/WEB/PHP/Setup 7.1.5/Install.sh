#!/bin/bash
# CentOS 7.3

PHP_HOME="/usr/local/php-7.1"
PHP_BIN_HOME="${PHP_HOME}/bin"
PHP_SBIN_HOME="${PHP_HOME}/sbin"
PHP_CONF_PATH="${PHP_HOME}/etc"
PHP_FPM_USERNAME="www"
ICONV_HOME="/usr/local/libiconv"
LIBMCRYPT_HOME="/usr/local/libmcrypt"
MCRYPT_HOME="/usr/local/mcrypt"
MHASH_HOME="/usr/local/mhash"

set -e
set -x

#php user
if ! id www 2> /dev/null; then
    useradd ${PHP_FPM_USERNAME} -M -s /sbin/nologin
fi 

#依赖
yum -y install epel-release 
yum -y install gd gd-devel php-gd zlib zlib-devel openssl openssl-devel libxml2 libxml2-devel libjpeg \
libjpeg-devel libpng libpng-devel php-mcrypt  curl-devel mhash mcrypt libmcrypt libmcrypt-devel \
libxslt-devel freetype-devel bzip2

#检查本地安装包
[[ -s php-7.1.5.tar.bz2 ]] || exit 1
[[ -s mhash-0.9.9.9.tar.gz && -s libmcrypt-2.5.8.tar.gz && -s libiconv-1.13.1.tar.gz && -s mcrypt-2.6.8.tar.gz ]]|| exit 1

rm -rf {php-7.1.5,libiconv-1.13.1,libmcrypt-2.5.8,mcrypt-2.6.8,mcrypt-2.6.8,mhash-0.9.9.9,${PHP_CONF_PATH},\
${PHP_HOME},${ICONV_HOME},${LIBMCRYPT_HOME},${MCRYPT_HOME,},${MHASH_HOME},\
/etc/php.ini,/etc/www.conf,/etc/php-fpm.conf,/var/log/php}

#iconv
p=$(pwd)
tar -zxvf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1
./configure --prefix=${ICONV_HOME}
make && make install

#libmcrypt
cd $p
tar -zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=${LIBMCRYPT_HOME}
make && make install

#mhash
cd $p
tar -zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure --prefix=${MHASH_HOME}
make && make install

#mcrypt
cd $p
tar -zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
export LD_LIBRARY_PATH=${LIBMCRYPT_HOME}/lib:${MHASH_HOME}/lib
export LDFLAGS="-L${MHASH_HOME}/lib -I${MHASH_HOME}/include/"
export CFLAGS="-I${MHASH_HOME}/include/"
./configure LD_LIBRARY_PATH=${LIBMCRYPT_HOME}/lib:${MHASH_HOME}/lib --prefix=${MCRYPT_HOME} \
--with-libmcrypt-prefix=${LIBMCRYPT_HOME}
make && make install

#php
cd $p
tar jxvf php-7.1.5.tar.bz2
cd php-7.1.5
mkdir -p {${PHP_BIN_HOME},${PHP_SBIN_HOME},${PHP_CONF_PATH}}
./configure \
--prefix="${PHP_HOME}" \
--bindir="${PHP_BIN_HOME}" \
--sbindir="${PHP_SBIN_HOME}" \
--with-config-file-path="${PHP_CONF_PATH}" \
--with-iconv="${ICONV_HOME}" \
--with-mcrypt="${MCRYPT_HOME}" \
--with-mhash="${MHASH_HOME}" \
--with-fpm-user=${PHP_FPM_USERNAME} \
--with-fpm-group=${PHP_FPM_USERNAME} \
--with-gd \
--with-openssl \
--with-pcre-regex \
--with-libdir=lib \
--with-libxml-dir \
--with-mysqli=shared,mysqlnd \
--with-pdo-mysql=shared,mysqlnd \
--with-pdo-sqlite \
--enable-gd-native-ttf \
--enable-mysqlnd \
--with-png-dir \
--with-jpeg-dir \
--with-zlib \
--enable-zip \
--enable-inline-optimization \
--with-xmlrpc \
--enable-shared \
--enable-libxml \
--enable-xml \
--enable-shmop \
--enable-sysvsem \
--enable-mbregex \
--enable-mbstring \
--enable-bcmath \
--enable-ftp \
--enable-pcntl \
--enable-soap \
--enable-session \
--enable-opcache \
--enable-maintainer-zts \
--enable-fileinfo \
--with-xsl \
--with-pear \
--with-openssl \
--enable-fpm \
--with-curl \
--enable-sockets
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install

#备份旧配置
[ -f /etc/php.ini ] && mv /etc/php.ini /etc/php.ini.bak
[ -f /etc/php-fpm.conf ] && mv /etc/php-fpm.conf /etc/php-fpm.conf.bak
[ -f /etc/www.conf ] && mv /etc/www.conf /etc/www.conf.bak

#adjust php.ini
cp -rf ./php.ini-production /etc/php.ini
sed -i "s#; extension_dir = \"\.\/\"#extension_dir = \"${PHP_HOME}/lib/php/extensions/no-debug-zts-20160303/\"#"  /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai /g' /etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini

#adjust php-fpm
mkdir -p /var/log/php
cp -rf  ${PHP_HOME}/etc/php-fpm.conf.default /etc/php-fpm.conf
cp -rf ./sapi/fpm/www.conf /etc/www.conf

#源码目录与/etc做硬链接
ln -sv /etc/php-fpm.conf ${PHP_HOME}/etc/php-fpm.conf
ln -sv /etc/www.conf ${PHP_HOME}/etc/php-fpm.d/www.conf

#PHP7中php-fpm.conf内引入了www.conf
sed -i "s/^pm.min_spare_servers.*/pm.min_spare_servers = 5/g" /etc/www.conf     
sed -i 's,^pm.max_spare_servers = 3,pm.max_spare_servers = 35,g'   /etc/www.conf
sed -i 's,^pm.max_children = 5,pm.max_children = 100,g'   /etc/www.conf
sed -i 's,^pm.start_servers = 2,pm.start_servers = 20,g'   /etc/www.conf
sed -i 's,;pid = run/php-fpm.pid,pid = run/php-fpm.pid,g'   /etc/php-fpm.conf
sed -i 's,;error_log = log/php-fpm.log,error_log = /var/log/php/php-fpm.log,g'  /etc/php-fpm.conf
sed -i "s,;slowlog = .*,slowlog = /var/log/php/php.log.slow,g"  /etc/www.conf
sed -i "s,user = nobody,user=${PHP_FPM_USERNAME},g" /etc/www.conf
sed -i "s,group = nobody,group=${PHP_FPM_USERNAME},g" /etc/www.conf 

#self start
install -v -m755 ./sapi/fpm/php-fpm  /etc/init.d/php-fpm

#环境变量
echo "export PATH=${PHP_BIN_HOME}:${PHP_SBIN_HOME}:$PATH" >> /etc/profile
source /etc/profile

#PHP-FPM
/etc/init.d/php-fpm
echo "/etc/init.d/php-fpm" >> /etc/rc.local

echo "Script Execution Time： $SECONDS"

exit 0
