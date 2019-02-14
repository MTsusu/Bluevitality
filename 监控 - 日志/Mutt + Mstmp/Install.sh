#!/bin/bash

set -e
set -x

MSMTP_HOME="/usr/local/msmtp"
SMTP_SERVER="smtp.163.com"
SMTP_PORT="25"
SEND_MAIL="inmoonlight@163.com"
MAILL_PASS="XXXXXXXXX"


#msmtp
yum -y install openssl-devel openssl
[ -e msmtp-1.4.31.tar.bz2 ] || exit 1
tar xvf msmtp-1.4.31.tar.bz2
cd msmtp-1.4.31
./configure --prefix=${MSMTP_HOME}
make
make install 
cd ${MSMTP_HOME}
#配置文件目录和配置文件都要自己建 
mkdir etc 
cd etc

cat > msmtprc <<eof
account default
#发件服务器
host ${SMTP_SERVER}
port ${SMTP_PORT}
#从哪个邮箱发出 
from ${SEND_MAIL}
#这里如果使用on的话会报 "msmtp: cannot use a secure authentication method"错误 
auth login 
tls off
#邮箱用户名 
user ${SEND_MAIL}
#邮箱密码，这里可是明文的，如果你觉得不安全可以把文件改为600属性 
password ${MAILL_PASS}
logfile /var/log/mmlog 
eof

# 测试
# /usr/local/msmtp/bin/msmtp xman@163.com 
# 随便输些内容用ctrl+d结束。到邮箱看看有没有收到,如果这里提示错误按照错误代码找原因或者看上面的日志

yum -y install mutt

cat > /etc/Muttrc <<eof
#msmtp路径
set sendmail="${MSMTP_HOME}/bin/msmtp"
set use_from=yes 
set realname="${SEND_MAIL}" 
set editor="vim" 
eof

exit 0

# 测试
# echo "testmail" | mutt -s "测试" -a /etc/hosts -- ufo@sina.com 
# -a 是指添加附件，如果是多个附件的话就多加几个 -a filename (注意收件箱左边的--符号!)


