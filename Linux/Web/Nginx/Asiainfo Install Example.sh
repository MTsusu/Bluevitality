#!/bin/sh
usr=`whoami`
serverName='nginx'
softwarePath="/home/`whoami`/software/$serverName"
srcFileUrl="http://192.168.123.135:8002/$serverName/"

[[ -d $softwarePath ]] || mkdir -p $softwarePath
cd $softwarePath

#if [ ! -d "~/nginx/zlib" ]; then
#  mkdir -p ~/nginx/zlib
#fi

#if [ ! -d "~/nginx/pcre" ]; then
#  mkdir -p ~/nginx/pcre
#fi

#if [ ! -d "~/nginx/openssl" ]; then
#  mkdir -p ~/nginx/openssl
#fi

#echo $? > log
#echo "the document is created!!!" >> log
cd $softwarePath
if [[ -e $softwarePath/nginx_upstream_check_module-master.zip ]]
then
rm -rf nginx_upstream_check_module
unzip nginx_upstream_check_module-master.zip 
mv nginx_upstream_check_module-master nginx_upstream_check_module
fi


cd $softwarePath
pakName='zlib-1.2.11'
[[ -e $softwarePath/$pakName.tar.gz ]] || curl -s "$srcFileUrl/$pakName.tar.gz" -o $softwarePath/$pakName.tar.gz

#echo "$srcFileUrl/$pakName.tar.gz" -o $softwarePath/$pakName.tar.gz

tar -xvf $pakName.tar.gz 
#cd $pakName
#./configure --prefix=$softwarePath/zlib
#make
echo $? >> ../log
#echo "the zlib  is maked!!" >> ../log
#make install
#echo $? >> ../log
echo "the zlib  is maked install!!" >> ../log

#cd ..



cd $softwarePath
pakName='pcre-8.39'
[[ -e $softwarePath/$pakName.tar.gz ]] || curl -s "$srcFileUrl/$pakName.tar.gz" -o $softwarePath/$pakName.tar.gz
tar zxvf $pakName.tar.gz
#cd $pakName         
#./configure --prefix=$softwarePath/pcre
#make         
echo $? >> ../log
echo "the pcre  is maked!!" >> ../log
#make install 
echo $? >> ../log
echo "the pcre  is maked install!!" >> ../log

#cd ..

pakName='openssl-1.0.1t'
[[ -e $softwarePath/$pakName.tar.gz ]] || curl -s "$srcFileUrl/$pakName.tar.gz" -o $softwarePath/$pakName.tar.gz
tar -zxvf $pakName.tar.gz
#cd $pakName
#./config  --prefix=$softwarePath/openssl
#make
echo $? >> ../log
echo "the openssl is maked!!" >> ../log
#make install
echo $? >> ../log
echo "the openssl  is maked install!!" >> ../log

#cd ..
cd $softwarePath

pakName='LuaJIT-2.0.5'
[[ -e $softwarePath/$pakName.tar.gz ]] ||curl -s "$srcFileUrl/$pakName.tar.gz" -o $softwarePath/$pakName.tar.gz
tar -zxvf $pakName.tar.gz
cd $pakName
   sed -i "s/\/usr\/local/\/home\/rhkf\/software\/nginx\/luajit/g" Makefile
if [ $? -eq 0 ]
then
make
echo $? >> ../log
echo "the luajit is maked!!" >> ../log
make install
echo $? >> ../log
echo "the luajit  is maked install!!" >> ../log
else
 echo "ERROR: install luajit failed"
 exit 1
fi
cd $softwarePath
luanginx='lua-nginx-module-0.10.9rc9'
ngxkit='ngx_devel_kit-0.3.0'
if [[ -e lua-nginx-module-0.10.9rc9.tar.gz  ]] 
then
   if [[ -d lua-nginx-module ]]
      then
           rm -rf lua-nginx-module
   fi
tar -xf lua-nginx-module-0.10.9rc9.tar.gz  
mv $luanginx  lua-nginx-module
if [[ -e ngx_devel_kit-0.3.0.tar.gz  ]]
then
   if [[ -d ngx_devel_kit  ]]
     then
       rm -rf ngx_devel_kit
   fi 
tar -xf ngx_devel_kit-0.3.0.tar.gz 
mv $ngxkit  ngx_devel_kit
else
echo "ERROR:ngx_devel_kit or lua-nginx-module not exits"
exit 1
fi
fi

export LUAJIT_LIB=$softwarePath/luajit/lib
export LUAJIT_INC=$softwarePath/luajit/include/luajit-2.0

pakName='nginx-1.14.0'
[[ -e $softwarePath/$pakName.tar.gz ]] ||curl -s "$srcFileUrl/$pakName.tar.gz" -o $softwarePath/$pakName.tar.gz
tar zxvf $pakName.tar.gz
cd $pakName
patch -p1 < ../nginx_upstream_check_module/check_1.14.0+.patch
sed -i "13s/1.0.1/6.0.6/"  src/core/nginx.h
sed -i "14s/nginx/cmos/"   src/core/nginx.h
./configure --prefix=$HOME/nginx   --with-pcre=$HOME/software/nginx/pcre-8.39 --with-zlib=$HOME/software/nginx/zlib-1.2.11 --with-stream --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_gunzip_module --add-module=$HOME/software/nginx/nginx_upstream_check_module --add-module=$HOME/software/nginx/lua-nginx-module --add-module=$HOME/software/nginx/ngx_devel_kit  --with-openssl=$HOME/software/nginx/openssl-1.0.1t 
make -j2
echo $? >> ../log
echo "the nginx  is maked!!" >> ../log
make install
echo $? >> ../log
echo "the nginx  is maked install!!" >> ../log

echo "before start nginx add this path to r ENV"
grep "LUAJIT_LIB" -r ~/.bash_profile >> /dev/null
if [[ $? -ne 0 ]]
then
echo "export LUAJIT_LIB=$LUAJIT_LIB 
export LUAJIT_INC=$LUAJIT_INC 
export LD_LIBRARY_PATH=\$LUAJIT_LIB:\$LD_LIBRARY_PATH 
PATH=\$PATH:\$HOME/software/nginx/luajit/bin:\$HOME/nginx/sbin" >>  ~/.bash_profile
fi

