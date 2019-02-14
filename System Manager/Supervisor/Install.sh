#!/bin/bash

set -ex

#依赖
[ -x /usr/bin/pip ] || exit 1

#更新pip
pip install --upgrade pip

#防止链接超时
while true
do
    pip install supervisor
    [[ "$?" == "0" ]] && {
    
        #输出默认配置项到配置文件
        echo_supervisord_conf > /etc/supervisord.conf
        #从/etc/supervisord/*.conf载入配置
        sed -i "s#^;files = relative/directory/\*\.ini#files = /etc/supervisord/*.conf#g" /etc/supervisord.conf
        break
        
    } 
done

#启动
supervisord -c /etc/supervisord.conf

exit 0
