#!/bin/bash

#注意，此脚本与源码不要放在"/home/wangyu/nginx/"下!

NGINX_HOME="/home/aiuap/nginx"
NGINX_CONF="/home/aiuap/nginx/conf/nginx.conf"
LUA_HOME="/home/aiuap/nginx/depend/luajit"

set -e
set -x

# 软件：
# /home/aiuap/nginx-1.12.2  #nginx源码
# /home/aiuap/nginx-1.12.2/depend/lua-nginx-module.tar.gz
# /home/aiuap/nginx-1.12.2/depend/LuaJIT-2.0.4.tar.gz
# /home/aiuap/nginx-1.12.2/depend/nginx_upstream_check_module-master.zip
# /home/aiuap/nginx-1.12.2/depend/ngx_devel_kit.tar.gz
# /home/aiuap/nginx-1.12.2/depend/openssl-1.0.2l.tar.gz
# /home/aiuap/nginx-1.12.2/depend/pcre-8.41.tar.gz
# /home/aiuap/nginx-1.12.2/depend/zlib-1.2.8.tar.gz

p=$(pwd)    #nginx源码目录
tar zxf depend/openssl-1.0.2l.tar.gz
tar zxf depend/pcre-8.41.tar.gz
tar -xf depend/zlib-1.2.8.tar.gz 

#Lua，用来通过lua扩展nginx功能
tar -zxvf depend/LuaJIT-2.0.4.tar.gz -C depend/
cd depend/LuaJIT-2.0.4/
make && make install PREFIX=${LUA_HOME}
export LUAJIT_LIB=${LUA_HOME}/lib 
export LUAJIT_INC=${LUA_HOME}/include/luajit-2.0 
echo "LUAJIT_LIB=${LUA_HOME}/lib" >> ~/.bash_profile   
echo "LUAJIT_INC=${LUA_HOME}/include/luajit-2.0" >> ~/.bash_profile
export PATH=$PATH:${LUA_HOME}/bin:${NGINX_HOME}/sbin
echo "PATH=$PATH:${LUA_HOME}/bin:${NGINX_HOME}/sbin" >> ~/.bash_profile
source ~/.bash_profile

cd $p
#用来做后端服务器健康检查的第三方模块
unzip ./depend/nginx_upstream_check_module-master.zip -d ./depend/
patch -p1 < depend/nginx_upstream_check_module-master/check_1.12.1+.patch
mkdir -p ${NGINX_HOME}/logs
./configure \
--prefix=${NGINX_HOME} \
--conf-path=${NGINX_CONF} \
--pid-path=${NGINX_HOME}/nginx.pid \
--error-log-path=${NGINX_HOME}/logs/error.log \
--http-log-path=${NGINX_HOME}/logs/access.log \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-http_gunzip_module \
--with-http_realip_module \
--with-pcre=./depend/pcre-8.41 \
--with-zlib=./depend/zlib-1.2.8 \
--with-openssl=./depend/openssl-1.0.2l \
--add-module=./depend/nginx_upstream_check_module-master \
--with-http_ssl_module \
--with-stream

# --add-module=./depend/nginx_upstream_check_status \
# --add-module=./depend/lua-nginx-module \
# --add-module=./depend/ngx_devel_kit \

NUM=$( awk '/processor/{NUM++};END{print NUM}' /proc/cpuinfo )
if [ $NUM -gt 1 ] ;then
    make -j $NUM
else
    make
fi
make install

chmod u+s ${NGINX_HOME}/sbin/nginx

exit 0
