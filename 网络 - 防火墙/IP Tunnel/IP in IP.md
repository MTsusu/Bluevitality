#### 环境
```txt
A：
外网IP：   10.10.10.1
VPNIP：  192.168.1.1

B：
外网IP：   10.10.20.1
VPNIP：  192.168.1.2
```
#### 配置 Host A
```bash
cat /etc/sysconfig/network-scripts/ifcfg-tun0
DEVICE=tun0
ONBOOT=yes
TYPE=IPIP
MY_INNER_IPADDR=192.168.1.1
MY_OUTER_IPADDR=10.10.10.1
PEER_INNER_IPADDR=192.168.1.2
PEER_OUTER_IPADDR=10.10.20.1
TTL=64

/etc/init.d/network restart
```
#### 配置 Host B
```bash
cat /etc/sysconfig/network-scripts/ifcfg-tun0
DEVICE=tun0
ONBOOT=yes
TYPE=IPIP
MY_INNER_IPADDR=192.168.1.2
MY_OUTER_IPADDR=10.10.20.1
PEER_INNER_IPADDR=192.168.1.1
PEER_OUTER_IPADDR=10.10.10.1
TTL=64

/etc/init.d/network restart
```
#### 修改防火墙规则
```bash
iptables -I INPUT -s 10.10.10.1 -p ipencap -j ACCEPT

#目前只是隧道建立了，具体隧道里面跑哪些数据，如何开启本机的转发功能，参考其他文档
```
