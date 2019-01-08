#!/bin/sh

#安装时将本目录所有文件先放在"$HOME/software/nginx"下
#默认依赖：yum -y install gcc gcc-c++ autoconf automake unzip

usr=`whoami`
SERVERNAME='nginx'
SOFTWAREPATH="/home/`whoami`/software/$SERVERNAME"

[[ -d $SOFTWAREPATH ]] || mkdir -p $SOFTWAREPATH
cd $SOFTWAREPATH

if [ -e $SOFTWAREPATH/nginx_upstream_check_module-master.zip ];then
    rm -rf nginx_upstream_check_module
    unzip nginx_upstream_check_module-master.zip 
    mv nginx_upstream_check_module-master nginx_upstream_check_module
fi

cd $SOFTWAREPATH
tar -xf zlib-1.2.11.tar.gz 
tar -zxf pcre-8.39.tar.gz       
tar -zxf openssl-OpenSSL_1_0_2i.tar.gz
tar -zxf LuaJIT-2.0.5.tar.gz
cd ./LuaJIT-2.0.5
sed -i "s@/usr/local@${SOFTWAREPATH}/luajit@g" Makefile
make
make install

cd $SOFTWAREPATH
ngxkit='ngx_devel_kit-0.3.0'
rm -rf lua-nginx-module-0.10.9rc9
tar -zxf lua-nginx-module-0.10.9rc9.tar.gz && mv lua-nginx-module-0.10.9rc9 lua-nginx-module

rm -rf ngx_devel_kit-0.3.0
tar -zxf ngx_devel_kit-0.3.0.tar.gz && mv ngx_devel_kit-0.3.0 ngx_devel_kit

export LUAJIT_LIB=$SOFTWAREPATH/luajit/lib
export LUAJIT_INC=$SOFTWAREPATH/luajit/include/luajit-2.0

tar -zxvf nginx-1.14.2.tar.gz
cd nginx-1.14.2
patch -p1 < ../nginx_upstream_check_module/check_1.14.0+.patch
sed -i 's/#define NGINX_VERSION.*/#define NGINX_VERSION      "6.6.6"/'  src/core/nginx.h
sed -i "14s/nginx/cmos/"  src/core/nginx.h
./configure --prefix=$HOME/nginx \
--with-pcre=${SOFTWAREPATH}/pcre-8.39 \
--with-zlib=${SOFTWAREPATH}/zlib-1.2.11 \
--with-stream --with-http_ssl_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-http_gunzip_module \
--add-module=${SOFTWAREPATH}/nginx_upstream_check_module \
--add-module=${SOFTWAREPATH}/lua-nginx-module \
--add-module=${SOFTWAREPATH}/ngx_devel_kit \
--with-openssl=${SOFTWAREPATH}/openssl-OpenSSL_1_0_2i
make -j2
make install

echo "before start nginx add this path to r ENV"
grep "LUAJIT_LIB" -r ~/.bash_profile >> /dev/null
if [[ $? -ne 0 ]];then
echo "export LUAJIT_LIB=$LUAJIT_LIB 
export LUAJIT_INC=$LUAJIT_INC 
export LD_LIBRARY_PATH=\$LUAJIT_LIB:\$LD_LIBRARY_PATH 
PATH=\$PATH:\$HOME/software/nginx/luajit/bin:\$HOME/nginx/sbin" >> ~/.bash_profile
fi

source ~/.bash_profile
