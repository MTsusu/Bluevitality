#### 备忘
```txt
dig：
	-b		查询时使用的源地址
	-k 		指定TSIG密钥文档（事务签名）
	-p		DNS端口，默认53
	-t		设置查询类型 eg：dig sohu.com @202.102.134.68 -p 53 -t MX
	@		指定的DNS服务器(若不指定则其将尝试resolv.conf列出的DNS。不指定命令/选项将对"."执行NS查询)
	查询选项：			dig的查询选项需加关键字:"+"
		+[no]tcp		向DNS查询时使用或不使用TCP
		+domain=...		设定包含单个域...的搜索列表?
		+[no]nssearch		试图寻找指定域内的权威服务器，并显示每台服务器的SOA记录
		+[no]trace		从根名称服务器开始的代理路径跟踪（迭代查询）
		+[no]short		提供简要答复
		+[no]stats		显示统计信息：查询进行时，应答的大小等...
		+[no]answer		是否显示应答的回答部分，缺省显示
		+[no]authority		是否显示应答的权限部分，缺省显示
		+[no]additional		是否显示应答的附加部分，缺省显示
		+time=T			查询超时为T秒。缺省5秒
		+tries=A		向服务器查询的重试次数，默认3次

查询163.com域下所有记录：	dig -t ANY 163.com	即163.com下的所有主机
查询163.com主机的MX记录：	dig -t MX 163.com	参数+short快速返回，信息量少
根据查询的MX记录查询A记录：	dig -t A 163mx00.mxmail.netease.com.
仅查询163主机的A记录：	dig -t A 163 @8.8.8.8 +noall +answer
快速返回域名的NS服务器：	dig  +short -t NS www.baidu.com @8.8.8.8
反向解析：	dig -x 210.52.83.228
查找域的授权dns服务器：	dig 163.com. +nssearch
从根开始追踪域名解析过程：	dig 163.com +trace
完全区域传送：	dig -t axfr 163.com
增量区域传送：	dig -t ixfr 163.com
```
#### Demo
```bash
[root@test ~]# dig www.abc.com @192.168.10.1		#使用192.168.10.1这个DNS进行URL的查询
;; global options:  printcmd
;; Got answer:
;; ->>HEADER opcode: QUERY, status: NOERROR, id: 43071
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 3, ADDITIONAL: 3
;; QUESTION SECTION:											
;www.isc.org.           IN     	 A
;; ANSWER SECTION:                                                      	 	
www.isc.org.            600     	IN      A       	204.152.184.88 
;; AUTHORITY SECTION:                                                    		
isc.org.                2351    	IN      NS      	ns-int.isc.org.
isc.org.                2351    	IN      NS      	ns1.gnac.com.            		
isc.org.                2351    	IN      NS      	ns-ext.isc.org.          
;; ADDITIONAL SECTION:  
ns1.gnac.com.       	171551  	IN      A       	209.182.216.75 
ns-int.isc.org.         2351    	IN      A       	204.152.184.65           		
ns-int.isc.org.         2351    	IN      AAAA    	2001:4f8:0:2::15		 	
;; Query time: 2046 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Fri Aug 27 08:22:26 2004
;; MSG SIZE  rcvd: 173
```
