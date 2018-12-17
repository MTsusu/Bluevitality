#### 备忘
```txt
varnish：
    高性能且开源的反向代理服务器和 HTTP 加速器，其采用全新的软件体系机构与现在的硬件体系紧密配合。
    
VCL：
    全称："Varnish Configuration Language"
    是varnish配置缓存策略的工具,它是基于"域" (domain specific) 的简单编程语言
    支持有限的算术运算和逻辑运算操作、允许使用正则表达式进行字符串匹配、允许用户使用set自定义变量、支持if判断
    有内置的函数与变量等... 使用VCL编写的缓存策略通常保存至"xxx.vcl"文件并且需编译成二进制格式后才能由varnish调用

程序环境：
    /etc/varnish/varnish.params： 
        配置varnish服务进程的工作特性，如监听的地址和端口，缓存机制等...
    /etc/varnish/default.vcl：
        配置各由Management管理下的各Child/Cache线程的缓存策略...
    /usr/sbin/varnishd：
        主程序
    /usr/sbin/varnish_reload_vcl：
        VCL配置文件重载程序
    /usr/bin/varnishadm：
        CLI interface
    Shared Memory Log 交互工具：
        /usr/bin/varnishhist
        /usr/bin/varnishlog
        /usr/bin/varnishncsa
        /usr/bin/varnishstat
        /usr/bin/varnishtop
    Systemd Unit File：
        /usr/lib/systemd/system/varnish.service         服务 daemon
        /usr/lib/systemd/system/varnishlog.service      日志服务
        /usr/lib/systemd/system/varnishncsa.service     日志持久的服务

Varnish分为master和child进程：
    Master读配置文件调用合适的存储类型，创建/读入相应的缓存文件，接着初始化管理该存储空间的结构体并fork和监控child
    Child在初始化过程中将前面打开的存储文件整个mmap到内存中，此时创建并初始化空闲结构体挂到存储管理结构体以待分配
    Child进程分配若干线程进行工作，主要包括管理线程和很多worker线程，可分为：
        Accept： 接受请求，将请求挂在overflow队列上；
        Work：   有多个，负责从w队列上摘除请求，对请求进行处理，直到完成，然后处理下个请求
        Epoll：  一个请求处理称为一个session，在session周期内，处理完请求后会交给Epoll处理，监听是否还有事件发生
        Expire： 对于缓存的object，根据过期时间组织成二叉堆，该线程周期检查该堆的根，处理过期的文件
```
#### Varnish 处理 HTTP 请求的过程描述
```txt
1，Receive 状态（vcl_recv）：
    即请求处理的入口状态，依 VCL 规则判断该请求应 pass（vcl_pass） 或 pipe（vcl_pipe），还是进入 lookup（本地查询） 
2，Lookup 状态：
    进入该状态后会在 hash 表中查找数据，若找到则进入 hit（vcl_hit）状态否则进入 miss（vcl_miss）状态 
3，Pass（vcl_pass）状态：
    在此状态下会直接进入后端请求，即进入 fetch（vcl_fetch）状态 
4，Fetch（vcl_fetch）状态：
    在 fetch 状态下对请求进行后端获取，发送请求，获得数据，并根据设置是否进行本地存储... 
5，Deliver（vcl_deliver）状态：
    将获取到的数据发给客户端，而后完成本次请求
```
#### varnish.params
```txt
RELOAD_VCL=1                                    #自动重新装载缓存策略，1表示自动装载
VARNISH_VCL_CONF=/etc/varnish/default.vcl       #缓存策略文件路径 （默认的VCL配置文件路径）

VARNISH_LISTEN_ADDRESS=172.16.0.10              #服务监听地址与端口
VARNISH_LISTEN_PORT=80                          #

VARNISH_TTL=120                                 #与后端服务器连接的超时时间

VARNISH_ADMIN_LISTEN_ADDRESS=127.0.0.1          #管理员登录使用的主机与端口
VARNISH_ADMIN_LISTEN_PORT=6082
VARNISH_SECRET_FILE=/etc/varnish/secret         #管理员登录时使用的密钥文件

VARNISH_STORAGE="file,/etc/varnish/cachedir,1G" #缓存类型及对应大小（3种类型：malloc，file，...）
                                                #使用file类型缓存文件时属主/组应为：varnish（malloc类型使用内存）

#VARNISH_STORAGE="malloc,1G"                    #使用内存存储（注：VARNISH_STORAGE仅能定义一次）

VARNISH_USER=varnish                            #运行时的用户与组
VARNISH_GROUP=varnish

#运行时参数，线程池数量，每个线程池的线程数及最大请求处理数量（-p 可指定添加运行参数及对应值）
DAEMON_OPTS="-p thread_pools=3 -p thread_pool_min=50 -p thread_pool_max=2000"
```
#### VCL 内置的部分公共变量（不同的版本下名称有变化）
```txt
VCL内置的公共变量可用在不同的VCL函数中，下面根据使用的不同阶段进行介绍

请求/响应报文所在阶段对应的varnish变量：
            
                    -------req.xxx------>         -------breq.xxx------> 
            [clinet]                     [varnish]                     [backend server]
                    <------resp.xxx------         <-------bresp.xxx----- 
        
当请求到达时，可以使用以下公共变量：
    req.backend             指定对应的后端主机
    server.ip               服务器 IP
    client.ip               客户端 IP
    req.quest               请求类型，如 GET、HEAD 等...
    req.url                 请求的URL地址
    req.proto               客户端发起请求的 HTTP 协议版本
    req.http.header         表示对应请求中的 HTTP 头部信息
    req.restarts            表示重启次数，默认最大值为 4
    req.http.Cookie         客户端请求报文中Cookie首部的值
    req.http.User-Agent     客户端浏览器类型
    req.http.host           客户端主机名称

Varnish在向后端主机请求时，可使用以下公共变量:
    bereq.http.HEADERS      表示对应请求中 HTTP 头部信息
    bereq.request           请求方法
    bereq.url               请求的url
    bereq.proto             请求的协议版本
    bereq.backend           指明要调用的后端主机

Varnish在向后端主机请求返回响应时，可使用以下公共变量:
    beresp.requset          指定请求类型，例如 GET、HEAD 等
    beresp.url              表示请求地址
    beresp.backend          指明要调用的后端主机
    beresp.backend.name     BE主机的主机名；
    beresp.status           响应的状态码；
    beresp.proto            表示backend server HTTP 协议版本
    beresp.http. HEADERS    从backend server 响应报文指定首部
    beresp.ttl              表示缓存的生存周期，cache 保留时间（s）

从 cache 或后端主机获取内容后，可使用以下公共变量:
    obj.status              返回内容的请求状态码，例如 200、302、504 等
    obj.cacheable           返回的内容是否可以缓存
    obj.valid               是否有效的 HTTP 请求
    obj.response            返回内容的请求状态信息
    obj.proto               返回内容的 HTTP 版本
    obj.hits                此对象从缓存中命中的次数
    obj.ttl                 返回内容的生存周期，也就是缓存时间，单位秒
    obj.lastuse             返回上次请求到现在的时间间隔，单位秒

对客户端应答时，可使用以下公共变量:
    resp.status             返回给客户端的 HTTP 代码状态
    resp.proto              返回给客户端的 HTTP 协议版本
    resp.http.header        返回给客户端的 HTTP 头部消息
    resp.response           返回给客户端的 HTTP 头部状态
```
#### Cache-Control
```txt
Cache-Control   = "Cache-Control" ":" 1#cache-directive
    cache-directive = cache-request-directive
         | cache-response-directive
    cache-request-directive =
           "no-cache"                          
         | "no-store" (backup)                          
         | "max-age" "=" delta-seconds         
         | "max-stale" [ "=" delta-seconds ]  
         | "min-fresh" "=" delta-seconds      
         | "no-transform"                      
         | "only-if-cached"                   
         | cache-extension                   
     cache-response-directive =
           "public"                               
         | "private" [ "=" <"> 1#field-name <"> ] 
         | "no-cache" [ "=" <"> 1#field-name <"> ]
         | "no-store"                            
         | "no-transform"                         
         | "must-revalidate"                     
         | "proxy-revalidate"                    
         | "max-age" "=" delta-seconds            
         | "s-maxage" "=" delta-seconds           
         | cache-extension 
```
![varinish](http://img.blog.csdn.net/20170627200700477?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2FuZ3llMTk4OV8wMjI2/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
