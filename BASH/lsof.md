#### 说明
``` bash
# lsof（list open files）是一个列出当前系统打开文件的工具。
# 在linux下任何事物都以文件的形式存在!，通过文件不仅可访问常规数据，还可以访问网络连接和硬件。
# 如传输控制协议 (TCP) 和用户数据报协议 (UDP) 套接字等，系统在后台都为该应用程序分配了一个文件描述符。
# 无论这个文件的本质如何，该文件描述符为应用程序与基础操作系统之间的交互提供了通用接口。
# 因为应用程序打开文件的描述符列表提供了大量关于这个应用程序本身的信息，因此通过lsof能够查看，这个列表对系统监测以及排错将是很有帮助的。


[root@localhost ~]# lsof | head -n 5
COMMAND    PID  TID           USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
systemd      1                root  cwd       DIR              253,0      4096        128 /
systemd      1                root  rtd       DIR              253,0      4096        128 /
systemd      1                root  txt       REG              253,0   1482272  101411655 /usr/lib/systemd/systemd
systemd      1                root  mem       REG              253,0     20040   67257837 /usr/lib64/libuuid.so.1.3.0
[root@localhost ~]# lsof -i :22
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1043 root    3u  IPv4  20560      0t0  TCP *:ssh (LISTEN)
sshd    1043 root    4u  IPv6  20562      0t0  TCP *:ssh (LISTEN)
^C
[root@localhost ~]# lsof -u root | head -n 5
COMMAND    PID USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
systemd      1 root  cwd       DIR              253,0      4096        128 /
systemd      1 root  rtd       DIR              253,0      4096        128 /
systemd      1 root  txt       REG              253,0   1482272  101411655 /usr/lib/systemd/systemd
systemd      1 root  mem       REG              253,0     20040   67257837 /usr/lib64/libuuid.so.1.3.0

#COMMAND：进程名称
#PID：进程ID
#USER：所有者
#FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt等
#TYPE：文件类型，如DIR、REG等
#DEVICE：指定磁盘的名称
#SIZE：文件大小
#NODE：索引节点（文件在磁盘上的标识）
#NAME：打开文件的确切名称
```

#### Example
```bash
lsof filename         #显示开启filename文件的进程
lsof -c program       #显示program进程现在打开的文件
lsof -c -p 1234       #列出进程号为1234的进程所打开的文件
lsof -u 1000          #查看uid是100的用户的进程的文件使用情况
lsof -g gid           #显示归属gid的进程情况
lsof +d /usr/local/         #列出指定目录被进程开启的文件
lsof +D /usr/local/         #同上，但会搜索目录下的目录，时间较长（包括子目录）
lsof -c courier -u ^samba   #显示出那些文件被以courier打头的进程打开，但并不属于用户samba的
lsof -i           #显示所有打开的端口
lsof -i:80        #显示所有打开80端口的进程
lsof | grep -i DELETE       #查看已经被删除但文件句柄仍被应用打开的僵尸信息（常用）
```
```txt


Lsof是遵从Unix哲学的典范，它只完成一个功能，并且做的相当完美——它可以列出某个进程打开的所有文件信息。打开的文件可能是普通的文件、目录、NFS文件、块文件、字符文件、共享库、常规管道、命名管道、符号链接、Socket流、网络Socket、UNIX域Socket，以及其它更多类型。因为“一切皆文件”乃为Unix系统的重要哲学思想之一，因此可以想象lsof命令的重要地位。


lsof ［options］ filename

lsof  /path/to/somefile：显示打开指定文件的所有进程之列表
lsof -c string：显示其COMMAND列中包含指定字符(string)的进程所有打开的文件；此选项可以重复使用，以指定多个模式；
lsof -p PID：查看该进程打开了哪些文件；进程号前可以使用脱字符“^”取反；
lsof -u USERNAME：显示指定用户的进程打开的文件；用户名前可以使用脱字符“^”取反，如“lsof -u ^root”则用于显示非root用户打开的所有文件；
lsof -g GID：显示归属gid的进程情况
lsof +d /DIR/：显示指定目录下被进程打开的文件
lsof +D /DIR/：基本功能同上，但lsof会对指定目录进行递归查找，注意这个参数要比grep版本慢：
lsof -a：按“与”组合多个条件，如lsof -a -c apache -u apache
lsof -N：列出所有NFS（网络文件系统）文件
lsof -d FD：显示指定文件描述符的相关进程；也可以为描述符指定一个范围，如0-2表示0,1,2三个文件描述符；另外，-d还支持其它很多特殊值，如：
	mem: 列出所有内存映射文件；
	mmap：显示所有内存映射设备；
	txt：列出所有加载在内存中并正在执行的进程，包含code和data；
	cwd：正在访问当前目录的进程列表；
	
lsof -n：不反解IP至HOSTNAME
lsof -i：用以显示符合条件的进程情况
lsof -i[46] [protocol][@hostname|hostaddr][:service|port]
	46：IPv4或IPv6
	protocol：TCP or UDP
	hostname：Internet host name
	hostaddr：IPv4地址
	service：/etc/service中的服务名称(可以不只一个)
	port：端口号 (可以不只一个)

例如： 查看22端口现在运行的情况
[root@www ~]# lsof -i :22
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd     1390 root    3u  IPv4  13050      0t0  TCP *:ssh (LISTEN)
sshd     1390 root    4u  IPv6  13056      0t0  TCP *:ssh (LISTEN)
sshd    36454 root    3r  IPv4  94352      0t0  TCP www.magedu.com:ssh->172.16.0.1:50018 (ESTABLISHED)


上述命令中，每行显示一个打开的文件，若不指定条件默认将显示所有进程打开的所有文件。lsof输出各列信息的意义如下：
	COMMAND：进程的名称
	PID：进程标识符
	USER：进程所有者
	FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt等
	TYPE：文件类型，如DIR、REG等
	DEVICE：指定磁盘的名称
	SIZE：文件的大小
	NODE：索引节点（文件在磁盘上的标识）
	NAME：打开文件的确切名称
```
