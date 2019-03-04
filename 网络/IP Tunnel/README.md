```txt
ipip 
需要内核模块 ipip.ko ，该方式最为简单！但是你不能通过IP-in-IP隧道转发广播或者IPv6数据包。
你只是连接了两个一般情况下无法直接通讯的IPv4网络而已。至于兼容性，这部分代码已有很长一段历史，其兼容性可上溯到1.3版的内核。
据网上查到信息，Linux的IP-in-IP隧道不能与其他操作系统或路由器互相通讯。它很简单，也很有效。

GRE
需要内核模块 ip_gre.ko ，GRE是最初由CISCO开发出来的隧道协议，能够做一些IP-in-IP隧道做不到的事情。
比如，你可以使用GRE隧道传输多播数据包和IPv6数据包。

sit
他的作用是连接 ipv4 与 ipv6 的网络。个人感觉不如gre使用广泛 。
```
#### 相关模块
```bash
# sit模块
[root@localhost ~]# modinfo sit
filename:       /lib/modules/2.6.32-642.el6.x86_64/kernel/net/ipv6/sit.ko
alias:          netdev-sit0
license:        GPL
srcversion:     AF73F62BA39C407E20C4F05
depends:        ipv6,tunnel4
vermagic:       2.6.32-642.el6.x86_64 SMP mod_unload modversions
# ipip模块
[root@localhost ~]# modinfo ipip
filename:       /lib/modules/2.6.32-642.el6.x86_64/kernel/net/ipv4/ipip.ko
alias:          netdev-tunl0
license:        GPL
srcversion:     AF7433BD67CBFC54C10C108
depends:        tunnel4
vermagic:       2.6.32-642.el6.x86_64 SMP mod_unload modversions
# ip_gre模块
[root@localhost ~]# modinfo ip_gre
filename:       /lib/modules/2.6.32-642.el6.x86_64/kernel/net/ipv4/ip_gre.ko
alias:          netdev-gretap0
alias:          netdev-gre0
alias:          rtnl-link-gretap
alias:          rtnl-link-gre
license:        GPL
srcversion:     163303A830259507CA00C15
depends:        ip_tunnel
vermagic:       2.6.32-642.el6.x86_64 SMP mod_unload modversions 
```
---
#### 环境
Host A : `121.207.22.123`  
Host B : `111.2.33.28`

#### Host A
> 创建GRE类型隧道设备"GRE1"并设置对端IP为111.2.33.28  
> 隧道数据包将被从121.207.22.123也就是本地IP地址发起，其TTL字段为255
> 隧道设备分配的IP地址为10.10.10.1 掩码 255.255.255.0
```Bash
ip tunnel add GRE1 mode gre remote 111.2.33.28 local 121.207.22.123 ttl 255 && ip link set GRE1 up
ip address add 10.10.10.1 peer 10.10.10.2 dev GRE1
ip route add 10.10.10.0/24 dev GRE1 
sysctl -w net.ipv4.ip_forward=1 && sysctl -p
iptables -F # 或 iptables -I INPUT -p gre -j ACCEPT
```
#### Host B
```Bash
ip tunnel add GRE1 mode gre remote 121.207.22.123 local 111.2.33.28 ttl 255 && ip link set GRE1 up
ip addr add 10.10.10.2 peer 10.10.10.1 dev GRE1
ip route add 10.10.10.0/24 dev GRE1
sysctl -w net.ipv4.ip_forward=1 && sysctl -p
iptables -F # 或 iptables -I INPUT -p gre -j ACCEPT
```

#### 检测连通性
```Bash
[root@wy ~]# ping 10.10.10.2 (host A)     # 注: gre tunnel 支持广播、多播
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_req=1 ttl=64 time=0.319 ms
64 bytes from 10.10.10.2: icmp_req=2 ttl=64 time=0.296 ms
```

#### 撤销隧道
```Bash
ip link set gre1 down
ip tunnel del gre1
```
---
#### 环境
                                                  |
            1.1.1.1               2.2.2.2         |
            +---------+  Public   +---------+     | Private
            | ServerA +-----------+ ServerB +-----+
            +---------+  Network  +---------+     | Network
                                                  |
                                                  | 192.168.1.0/24 


#### Server A
```Bash
ip tunnel add a2b mode ipip remote 2.2.2.2 local 1.1.1.1
ifconfig a2b 192.168.2.1 netmask 255.255.255.0
/sbin/route add -net 192.168.1.0/24 gw 192.168.2.2
```
#### Server B
```Bash
ip tunnel add a2b mode ipip remote 1.1.1.1 local 2.2.2.2
ifconfig a2b 192.168.2.2 netmask 255.255.255.0
iptables -t nat -A POSTROUTING -s 192.168.2.1 -d 192.168.1.0/24 -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
sed -i '/net.ipv4.ip_forward/ s/0/1/'  /etc/sysctl.conf
```
至此完成了两端的配置，ServerA可直接访问ServerB所接的私网了
