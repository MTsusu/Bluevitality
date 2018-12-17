## 0x01 关于Nginx
> Nginx("engine x") 作为Web服务器软件，是一个轻量级、高性能的HTTP和反向代理服务器，负载均衡服务器，及电子邮件IMAP/POP3/SMTP 服务器。  
> Nginx性能稳定、功能丰富、维护简单、效率高、并发能力强、处理静态文件速度快且消耗系统资源极少。  
> 更多请直接参考百科或[官方文档](http://nginx.org/docs) ...

## 0x02 演示环境
> CentOS 7.2 x86_64 - 最小化安装，带基础库。  
> nginx-1.12.2 - 编译安装，这是当前最新稳定版本（实际生产环境中版本可稍微降低一些，稳定为主；选择版本时应尽量避开一些已知的高危漏洞版本）

## 0x03 Nginx依赖库
> zlib - 用于支持gzip模块  
> pcre - 用于支持rewrite模块  
> openssl - 用于支持ssl功能  

* 直接使用Yum安装Nginx所需依赖库和编译器

> yum源建议使用[阿里源](http://mirrors.aliyun.com/repo/Centos-6.repo)，并保持缓存是最新的；

```
# yum install pcre pcre-devel openssl openssl-devel zlib zlib-devel gcc gcc-c++ automake -y
```

## 0x04 Nginx安装

* 下载并解压，源码级修改Nginx默认版本号

> 隐藏或者修改版本号的目得是扰乱入侵者的视线，因为有些漏洞只针对特定版本和类型。
> 虽然可以在后续配置文件中隐藏版本号，但隐藏不彻底，只是简单的去掉了版本号，Nginx的字样还有保留，但对于类型还是处于暴露目标状态。
> 因为通过在url中转换大小写请求依然是可以试出来目标机器到底是linux还是windows平台，所以我们可以修改成Apache字样，也许会更具有迷惑性。
> 入侵者，可能就会去尝试一些和Apache相关的漏洞，也就是说，把入侵者引向了一条根本不通的路。另外，有很多获取web服务器banner的扫描工具，基本也都是靠截取的http响应头中server字段的内容。
> 这样一来，也顺便把别人的工具都蒙骗了。

```
# cd /usr/local/src/
# wget http://nginx.org/download/nginx-1.12.2.tar.gz
# tar zxf nginx-1.12.2.tar.gz
# cd nginx-1.12.2
# sed -i 's/1.12.2/2.4.29/;s/nginx\//Apache\//g' src/core/nginx.h  # 修改版本号和名称
```

* 创建Nginx运行账户

> 尽量以伪用户身份来运行Nginx服务，切记，千万不要直接用root权限来运行Nginx，否则别人拿到的webshell权限很可能直接是root权限的。
> 如果fastcgi服务端 [php-fpm] 和 Nginx使用的是同一用户身份来运行，就很容造成这种情况。

```
# mkdir -p /opt/WebSite		# 创建Web站点目录
# useradd -d /opt/WebSite -s /sbin/nologin -M nginx
```

* 编译安装，编译参数如下

> `./configure --help` 查看Nginx支持的所有模块，可根据自己的实际需求选择性的启用，对于一些曾经爆过严重漏洞的模块，
> 要格外仔细小心，每个功能模块在其官方文档中都有详细说明及使用样例，具体可参考 http://nginx.org/en/docs/

```
# ./configure \
--user=nginx \				# 指定启动程序所属用户
--group=nginx \				# 指定组
--prefix=/usr/local/nginx \		# 指定安装路径
--sbin-path=/usr/sbin/nginx \		# 指定存放Nginx管理工具二进制文件的路径
--conf-path=/etc/nginx/nginx.conf \	# 指定配置文件路径
--pid-path=/var/run/nginx.pid \		# 指定nginx.pid文件路径
--lock-path=/var/lock/subsys/nginx \	# 指定nginx.lock文件路径（安装文件锁定，防止安装文件被别人利用）
--error-log-path=/var/log/nginx/error.log \	# 指定错误日志文件路径
--http-log-path=/var/log/nginx/access.log \	# 指定访问日志文件路径
--with-http_stub_status_module \	# 监控Nginx状态
--with-http_gzip_static_module \	# 启用gzip压缩
--with-http_realip_module \		# 获取真实IP模块
--with-http_ssl_module \		# 启用SSL支持
--with-pcre				# 启用正则表达式

# make && make install
```

* make安装完成后， 可通过`nginx -V` 查看版本号
```
# /usr/sbin/nginx -V	# 可以看到，我们修改后的版本号和名称，此时已经生效了
nginx version: Apache/2.4.29
	...
```

* Nginx的基本目录结构
```
# tree -L 2 /etc/nginx/		# Nginx配置文件目录
/etc/nginx/
├── conf.d
	└── default.conf	# 虚拟主机默认配置文件
├── fastcgi.conf		# 后端动态脚本接口配置；如：PHP、Python、Java
├── fastcgi.conf.default    
├── fastcgi_params
├── fastcgi_params.default
├── koi-utf
├── koi-win
├── mime.types
├── mime.types.default
├── nginx.conf			# Nginx主配置文件
├── nginx.conf.default
├── scgi_params
├── scgi_params.default
├── uwsgi_params
├── uwsgi_params.default
└── win-utf

# tree -L 2 /usr/local/nginx/	# Nginx安装目录
/usr/local/nginx/
├── client_body_temp
├── fastcgi_temp
├── html			# Nginx默认站点目录
│   ├── 50x.html		# 大于500的错误页
│   └── index.html		# 首页
├── proxy_temp
├── scgi_temp
└── uwsgi_temp

# tree -L 2 /var/log/nginx/	# Nginx自身日志目录
/var/log/nginx/
├── access.log		# 访问日志
└── error.log		# 错误日志

# tree -L 2 /usr/sbin/
├── nginx		# Nginx服务管理工具
└── ...		
```

* Nginx服务管理工具用法
```
# cd /usr/sbin/
# ./nginx			# 启动
# ./nginx -s stop		# 停止
# ./nginx -s quit		# 退出
# ./nginx -s reopen		# 重启
# ./nginx -s reload		# 重载
# kill -HUP $(cat /var/run/nginx.pid)	# 平滑启动
```

* 配置Nginx管理脚本，并设置开机启动
```
# wget https://raw.githubusercontent.com/vforbox/Note/master/System/Linux/ShellScript/nginx_server_manage.sh -O /etc/init.d/nginx
# chmod 755 /etc/init.d/nginx
# chkconfig --add nginx
# chkconfig nginx on
# service nginx restart
Stopping nginx (via systemctl):                            [  OK  ]
Starting nginx (via systemctl):                            [  OK  ]
```

* 设置防火墙规则，允许外部访问80端口
```
# firewall-cmd --permanent --add-port=80/tcp
# firewall-cmd --reload
```

* 通过内部curl测试访问，或者通过外部浏览器访问

> 注意观察版本号和名称是否为修改后的

```
# curl -v http://localhost/
* Connected to localhost (127.0.0.1) port 80 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: localhost
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: Apache/2.4.29
< Date: Mon, 18 Dec 2017 13:59:01 GMT
< Content-Type: text/html
< Content-Length: 612
< Last-Modified: Mon, 18 Dec 2017 13:32:06 GMT
< Connection: keep-alive
< ETag: "5a37c356-264"
< Accept-Ranges: bytes
	...
```

## 0x05 总结
> Nginx的主要作用还是为了更好的提供web服务，一切还以满足实际业务需求和高性能为主。  
> 部署环境很简单，实际部署过程中做好这些最基本的防御措施即可。
