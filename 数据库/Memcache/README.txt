memcached是一种不互相通信的分布式，其协议简单，基于libevent的事件处理，内置内存存储方式，

/usr/local/memcached/bin/memcached -h 
选项：
-d 守护进程；
-m 分配给Memcache使用的内存，单位MB；           
-n 指定使用的最小内存空间
-u 运行身份；
-l 监听地址，可以有多个地址；                   
-p 监听端口，最好是1024以上的端口；
-c 最大并发，默认是1024；
-P 保存的pid文件。   

启动：/usr/bin/memcached -d -m 128 -n 20 -f 1.2 -l 172.16.0.1 -p 11211 -c 2048 -vv -u nobody -P /tmp/mem.pid
连接：telnet [IP] [Port]

例子：
set runoob 0 900 9   设置key为runoob | flag=0（flag用于存储关于键值对的额外信息）|此键值对的有效期为900秒|数据存储的字节数为9
memcached
STORED   

get runoob 查找runoob键的值"多个key使用空格隔开"，delete用于删除键值如：delete runoob
VALUE runoob 0 9
memcached
END

如果add的key已存在则不更新数据之前的值将仍然保持相同并且获得响应NOT_STORED。
add newkey 0 900 10  key为runoob|flag=0（flag用于存储关于键值对的额外信息）|此键值对的有效期为900秒（0表示永远）|数据存储的字节数为10
data_value
STORED

replace可替换已存在的key的value。若key不存在则替换失败并获得响应NOT_STORED。
replace mykey 0 900 16
some_other_value

append向已存在key的value后追加数据。prepend向已存在key的value前面追加数据。
append runoob 0 900 5
redis 后追加内容

prepend runoob 0 900 5
redis  前插入内容

incr与decr用于对已存在的key的数字值进行自增或自减。操作的数据必须是十进制的32位无符号整数。如果key不存在返回NOT_FOUND
set visitors 0 900 2
10
STORED
incr 键名 5  5是其增长因子 【incr是自增操作，decr是自减操作】
get visitors
VALUE visitors 0 2
15  
END

Memcached的stats命令返回统计信息：
pid：         服务进程ID
uptime：        已运行秒数
time：        当前Unix时间戳
version：        版本
pointer_size：    操作系统指针大小
rusage_user：    进程累计用户时间
rusage_system：    进程累计系统时间
curr_connections：    当前连接数量
total_connections：    运行以来连接总数
connection_structures：Memcached分配的连接结构数量
cmd_get：            get请求次数
cmd_set：            set请求次数
cmd_flush：        flush请求次数
get_hits：            get命中次数
get_misses：        get未命中次数
delete_misses：    delete未命中次数
delete_hits：        delete命中次数
incr_misses：        incr未命中次数
incr_hits：            incr命中次数
decr_misses：        decr未命中次数
decr_hits：        decr命中次数
cas_misses：        cas未命中次数
cas_hits：            cas命中次数
cas_badval：        使用擦拭次数
auth_cmds：        认证命令处理次数
auth_errors：        认证失败数目
bytes_read：        读取总字节数
bytes_written：        发送总字节数
limit_maxbytes：    分配的内存总大小（字节）
accepting_conns：    服务器是否达到过最大连接（0/1）
listen_disabled_num：失效的监听数
threads：            当前线程数
conn_yields：        连接操作主动放弃数目
bytes：            当前存储占用的字节数
curr_items：        当前存储的数据总数！！
total_items：        启动以来存储的数据总数
evictions：        LRU释放的对象数目
reclaimed：        已过期的数据条目来存储新数据的数目

Memcached stats items用于显示各个slab中item的数目和存储时长（最后一次访问距现在的秒数）。
flush_all 命令用于用于清理缓存中的所有key<=>value，键值对
