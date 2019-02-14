* **简介**

> ab是Apache超文本传输协议(HTTP)的性能测试工具。
> 其设计意图是描绘当前所安装的Apache的执行性能，主要是显示你安装的Apache每秒可以处理多少个请求。

* **安装ab工具**
```
## Centos
$ yum -y install apr-util

## Ubuntu
$ sudo apt-get install apache2-utils
```

* **ab命令常用参数**

> -n  在测试会话中所执行的请求个数。默认为1  
> -c  一次产生的请求个数(并发)。默认为1  
> -t  测试所进行的最大秒数。默认值为50000  
> -p  包含了需要的POST的数据文件  
> -k  使用http的keepalive特性  
> -T  POST数据所使用的Content-type头信息  

* **实例**
```
$ ab -n 1000 -kc 1000 http://localhost:8080/
This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        nginx
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        36 bytes

Concurrency Level:      1000
Time taken for tests:   0.340 seconds
Complete requests:      1000
Failed requests:        491
   (Connect: 0, Receive: 0, Length: 491, Exceptions: 0)
Write errors:           0
Keep-Alive requests:    509
Total transferred:      125764 bytes
HTML transferred:       20304 bytes
Requests per second:    2942.94 [#/sec] (mean)
Time per request:       339.796 [ms] (mean)
Time per request:       0.340 [ms] (mean, across all concurrent requests)
Transfer rate:          361.44 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   20  28.8      2      76
Processing:     0   27  55.5      8     245
Waiting:        0   38  72.2     13     245
Total:          0   47  76.9     17     317

Percentage of the requests served within a certain time (ms)
  50%     17
  66%     23
  75%     78
  80%     87
  90%    108
  95%    303
  98%    305
  99%    317
 100%    317 (longest request)
```

* **结果说明**
> * Requests per second:    2942.94 [#/sec] (mean)  
> 表示当前测试的服务器每秒可以处理2942.94个静态html的请求事务，mean表示平均，这个值表示当前机器的整体性能，值越大越好。
>
> * Time per request:       339.796 [ms] (mean)  
> 单个并发的延迟时间。
>
> * Time per request:       0.340 [ms] (mean, across all concurrent requests)  
> 隔离开当前并发，单独完成一个请求需要的平均时间。
>
> * 两个Time per request区别  
> 前一个衡量单个请求的延迟，cpu是分时间片轮流执行请求的，多并发的情况下，一个并发上的请求时需要等待这么长时间才能得到下一个时间片。  
> 后一个衡量性能的标准，它反映了完成一个请求需要的平均时间,在当前的并发情况下，增加一个请求需要的时间。  
> 计算方法 Time taken for tests: 0.340 seconds * 1000ms / Complete requests: 1000  
> 当以-c 10的并发下完成-n 1001个请求时，比完成-n1000个请求多花的时间
>
> 适当调节-c 和-n大小来测试服务器性能，借助htop指令来直观的查看机器的负载情况

* **ab的并发限制**
> * Linux 会提示 socket: Too many open files (24)  
> 原因： linux是通过文件来对设备进行管理，ulimit -n是设置同时打开文件的最大数值ab中每一个连接打开一个设备文件，所以设置这个值就可以解决了。  
> $ ulimit -n 1500

* **防止恶意压力测试**
> * 用户的 IP 地址 \$binary_remote_addr 作为 Key，每个 IP 地址最多有 20 个并发连接  
> 在 nginx.conf 的http字段添加 limit_conn_zone \$binary_remote_addr zone=one:20m;
> 然后在主机配置 server 字段添加 limit_conn one 20;
>
> * 重载Nginx  
> $ /usr/sbin/nginx -s reload
