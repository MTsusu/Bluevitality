#!/bin/bash

#用户自定义证书信息
countryName=CN
countryNameSub=$(hostname)
organizationServer=Server
organizationServer=Client
p12Passwd=12346567

#创建 root,server,client 证书文件夹
BASIC=`pwd .`
ROOT=$BASIC/private_ca/root
SERVER=$BASIC/private_ca/server
CLIENT=$BASIC/private_ca/client

OPENSSL_CONF=$BASIC/openssl.cnf
export OPENSSL_CONF

# clean first
if [ -e $BASIC/private_ca ];then
    rm -r $BASIC/private_ca
    echo "clean $BASIC/myca finished..."
fi

# root ca dir
mkdir -p $ROOT
cd $ROOT
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt

# server and client dir
mkdir -p {$SERVER,$CLIENT}

#生成CA证书
cd $ROOT
openssl req -x509  -newkey rsa:2048 -days 365 -out cacert.pem -outform PEM -subj /CN=$countryName/ -nodes
openssl x509 -in cacert.pem -out cacert.cer -outform DER

#生成Server证书
cd $SERVER
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$countryNameSub/O=$organizationServer/ -nodes

cd $ROOT
openssl ca  -in $SERVER/req.pem -out $SERVER/cert.pem -notext -batch -extensions server_ca_extensions    
    
cd $SERVER
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:$p12Passwd
    
#生成Client证书
cd $CLIENT
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$countryNameSub/O=$organizationClient/ -nodes

cd $ROOT
openssl ca  -in $CLIENT/req.pem -out $CLIENT/cert.pem -notext -batch -extensions client_ca_extensions

cd $CLIENT
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:$p12Passwd



