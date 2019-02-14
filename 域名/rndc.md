```bash
# 在使用rndc管理bind前需使用rndc-confgen生成一对密钥文件，一半保存于rndc的配置文件，另一半保存于bind主配置文件
# rndc的配置文件为/etc/rndc.conf，在CentOS中rndc的密钥保存在：/etc/rndc.key
# rndc默认监听在TCP/953，实际上在bind9中rndc默认就可以使用，不需要配置密钥文件。
# 可使用rndc-confgen命令产生密钥和相应的配置，再把这些配置分别放入named.conf和rndc的配置文件rndc.conf

# 生成密钥：
rndc-confgen -r/dev/urandom > /etc/rndc.conf
vim /etc/rndc.conf
key "ddns_key" {
        algorithm hmac-md5;
        secret  "ZQFSVQ9sMquZsdb3Twg9q231SwF1f1KBhG74JMlaiPaumD6NeOA626FQ1DOa";
};
options {
    default-key "ddns_key"
    default-server 127.0.0.1;
    default-port 953;
}

chown named:named /etc/rndc.key  
chown 644 /etc/rndc.key  

vim /etc/named.conf
key "ddns_key" {
        algorithm hmac-md5;
        secret  "ZQFSVQ9sMquZsdb3Twg9q231SwF1f1KBhG74JMlaiPaumD6NeOA626FQ1DOa";
};
controls {
	    inet 127.0.0.1 port 953
	    allow { 127.0.0.1; } keys { "ddns_key"; };
};
```
#### Example
```bash
rndc常用命令：
    status              #显示bind服务器的工作状态
    reload              #重新加载配置文件和区域文件
    reload zone_name    #重新加载指定区域
    reconfig            #重读配置文件并加载新增的区域
    querylog            #关闭或开启查询日志
    dumpdb              #将高速缓存转储到转储文件 (named_dump.db)
    freeze              #暂停更新所有动态zone
    freeze zone [class [view]]#暂停更新一个动态zone
    flush [view]        #刷新服务器的所有高速缓存
    flushname name      #为某一视图刷新服务器的高速缓存
    stats               #将服务器统计信息写入统计文件中
    stop                #将暂挂更新保存到主文件并停止服务器
    halt                #停止服务器，但不保存暂挂更新
    trace               #打开debug, debug有级别的概念，每执行一次提升一次级别
    trace LEVEL         #指定 debug 的级别, trace 0 表示关闭debug
    notrace             #将调试级别设置为 0
    restart             #重新启动服务器（尚未实现）
    
    addzone zone [class [view]] { zone-options }

#实例：
/home/slim/bind/sbin/rndc -c /home/slim/chroot/etc/rndc.conf -s 127.0.0.1 -p 953 dumpdb

$ /home/slim/bind/sbin/rndc -c /home/slim/chroot/etc/rndc.conf -s 127.0.0.1 -p 953 status  
version: 9.9.7 (vdns3.0) <id:e87fa9ae>  
CPUs found: 1  
worker threads: 1  
UDP listeners per interface: 1  
number of zones: 101  
debug level: 0  
xfers running: 0  
xfers deferred: 0  
soa queries in progress: 0  
query logging is ON  
recursive clients: 0/0/1000  
tcp clients: 0/100  
server is up and running  


#添加zone
/home/slim/bind/sbin/rndc -c /home/slim/chroot/etc/rndc.conf -s 127.0.0.1 -p 953 \
addzone abc.com '{ type master; file  "zone/abc.com.zone";};'

#清除缓存
rndc -c /etc/rndc.conf flush
```
