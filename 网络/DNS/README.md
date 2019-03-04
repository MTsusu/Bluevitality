#### 区域数据文件： named.zwtzwt.com
```txt
$TTL  1h
$ORIGIN zwtzwt.com.
@	IN	SOA	ns.zwtzwt.com.	inmoonlight.163.com. (

; 上面的SOA记录指明zwtzwt.com.域（即"@"）的授权主机名（权威的）的FQDN是ns.zwtzwt.com. 每个区文件都需要一个SOA记录

                    2006102001  ; 版本号
                    28800       ; 主辅DNS周期同步的间隔，默认单位是秒，可用时间单位
                    14400       ; 辅助服务器重试时间间隔
                    720000      ; 辅助服务器解析库失效时长
                    86400       ; 最小默认TTL值，若第1行无$TTL则用该值
) 

@	IN	NS	www.zwtzwt.com.		; 符号'@'代表区域文件"named.conf"中定义的区域名称
www	IN	A	172.16.10.76
ftp     IN	CNAME	www
forum   IN	CNAME	www
	IN	mx 19	mail.zwtzwt.com.	; 数字越小邮件服务器的优先权越高。
pop3	IN	CNAME	mail.zwtzwt.com.
imap	IN	CNAME	mail.zwtzwt.com.
mail	IN	A	172.16.10.77
winxp   IN	A	172.16.10.48
@	IN	NS	slave1.zwtzwt.com.	; DNS从服务器信息（为了触发同步区域数据文件的需要）
slave1	IN	A	172.16.10.1		; 
sub	IN	NS	dns.sub.zwtzwt.com.	; 子域授权
dns.sub IN	A	172.16.20.1		; 

; 注: 区域数据文件默认在 /var/named 下，并且其文件权限要求为640、属主为named...
```
#### 配置检查
```txt
检查Bind配置：	named-checkconf
检查区域配置文件：	named-checkzone "www.zwtzwt.com." /var/named/named.zwtzwt.com.zone
```
#### 解析流程
```txt
1、在浏览器中输入www.qq.com域名，操作系统会先检查自己本地的hosts文件是否有这个网址映射关系
   如果有，就先调用这个IP地址映射，完成域名解析。 
2、如果hosts里没有这个域名的映射，则查找本地DNS解析器缓存，是否有这个网址映射关系，如果有，直接返回完成域名解析。 
3、如果hosts与本地DNS解析器缓存都没有相应的网址映射关系，首先会找TCP/ip参数中设置的首选DNS服务器
   在此叫它本地DNS服务器，其收到查询时如果要查询的域名包含在本地配置区域资源中则返回结果给客户完成解析。（具有权威性） 
4、如果要查询的域名不由本地DNS服务器区域解析，但其已缓存了此网址映射关系则调用这个IP地址映射完成解析。（不具有权威性） 
5、如果本地DNS服务器本地区域文件与缓存解析都失效，则根据本地DNS服务器的设置（是否设置转发器）进行查询
   如果未用转发模式，本地DNS就把请求发至13台根DNS，根DNS服务器收到请求后会判断这个域名(.com)是谁来授权管理
   并会返回一个负责该顶级域名服务器的一个IP。本地DNS服务器收到IP信息后，将会联系负责.com域的这台服务器。
   这台负责.com域的服务器收到请求后，如果自己无法解析，它就会找一个管理.com域的下一级DNS服务器地址(qq.com)给本地DNS
   当本地DNS服务器收到这个地址后，就会找qq.com域服务器，重复上面的动作，进行查询，直至找到www.qq.com主机。 
6、如果用的是转发模式，此DNS服务器就会把请求转发至上一级DNS服务器，由上一级服务器进行解析
   上一级服务器如果不能解析，或找根DNS或把转请求转至上上级，以此循环。
   不管是本地DNS服务器用是是转发，还是根提示，最后都是把结果返回给本地DNS服务器，由此DNS服务器再返回给客户机。 

注：从客户端到本地DNS服务器是属于递归查询，而DNS服务器之间就是的交互查询就是迭代查询。
```
