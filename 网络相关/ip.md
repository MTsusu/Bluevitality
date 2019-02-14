#### link
```bash
[root@localhost ~]# ip link set dev eno16777736 up                      #up/down特定链路接口
[root@localhost ~]# ip link show eno16777736                            #查看指定链路接口信息
2: eno16777736: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 00:0c:29:ad:ab:ae brd ff:ff:ff:ff:ff:ff
[root@localhost ~]# ip link set dev eno16777736 txqueuelen 1000         #改变传输队列长度
[root@localhost ~]# ip link help                                        #ip link set dev 参数汇总 ...
Usage: ip link add [link DEV] [ name ] NAME
                   [ txqueuelen PACKETS ]
                   [ address LLADDR ]
                   [ broadcast LLADDR ]
                   [ mtu MTU ]
                   [ numtxqueues QUEUE_COUNT ]
                   [ numrxqueues QUEUE_COUNT ]
                   type TYPE [ ARGS ]
       ip link delete DEV type TYPE [ ARGS ]

       ip link set { dev DEVICE | group DEVGROUP } [ { up | down } ]
                          [ arp { on | off } ]
                          [ dynamic { on | off } ]
                          [ multicast { on | off } ]
                          [ allmulticast { on | off } ]
                          [ promisc { on | off } ]
                          [ trailers { on | off } ]
                          [ txqueuelen PACKETS ]
                          [ name NEWNAME ]
                          [ address LLADDR ]
                          [ broadcast LLADDR ]
                          [ mtu MTU ]
                          [ netns PID ]
                          [ netns NAME ]
                          [ link-netnsid ID ]
                          [ alias NAME ]
                          [ vf NUM [ mac LLADDR ]
                                   [ vlan VLANID [ qos VLAN-QOS ] ]
                                   [ rate TXRATE ] ] 
                                   [ spoofchk { on | off} ] ] 
                                   [ query_rss { on | off} ] ] 
                                   [ state { auto | enable | disable} ] ]
                          [ master DEVICE ]
                          [ nomaster ]
                          [ addrgenmode { eui64 | none } ]
       ip link show [ DEVICE | group GROUP ] [up]

TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |
          bridge | ipoib | ip6tnl | ipip | sit | vxlan |
          gre | gretap | ip6gre | ip6gretap }
```
#### address
```bash
#为指定设备添加一个地址并采用标准的（计算得来：'brd +'）广播地址，并设置标签为：eno16777736:1
[root@localhost ~]# ip address add 192.168.0.5/24 brd + dev eno16777736 label eno16777736:1
[root@localhost ~]# ip address show eno16777736
2: eno16777736: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:ad:ab:ae brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.3/24 brd 192.168.0.255 scope global dynamic eno16777736
       valid_lft 2160950sec preferred_lft 2160950sec
    inet 192.168.0.5/24 brd 192.168.0.255 scope global secondary eno16777736:1
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fead:abae/64 scope link 
       valid_lft forever preferred_lft forever
[root@localhost ~]# ip address del 192.168.0.5/24 brd + dev eno16777736 label eno16777736:1 #删除地址
[root@localhost ~]# ip address flush to 192.168.0.5/24          #删除特定前缀的地址
[root@localhost ~]# ip address flush label "eno16777736:1"      #删除特定标签的地址
[root@localhost ~]# ip address help
Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]
                                                      [ CONFFLAG-LIST ]
       ip addr del IFADDR dev STRING [mngtmpaddr]
       ip addr {show|save|flush} [ dev STRING ] [ scope SCOPE-ID ]
                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ] [up]
       ip addr {showdump|restore}
IFADDR := PREFIX | ADDR peer PREFIX
          [ broadcast ADDR ] [ anycast ADDR ]
          [ label STRING ] [ scope SCOPE-ID ]
SCOPE-ID := [ host | link | global | NUMBER ]
FLAG-LIST := [ FLAG-LIST ] FLAG
FLAG  := [ permanent | dynamic | secondary | primary |
           tentative | deprecated | dadfailed | temporary |
           CONFFLAG-LIST ]
CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG
CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute ]
LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]
LFT := forever | SECONDS
```
#### route
```bash
#查询去往指定目的地址的路由表信息
[root@localhost ~]# ip route get 114.114.114.114
114.114.114.114 via 192.168.0.2 dev eno16777736  src 192.168.0.3 
    cache 
#设置NAT路由，将192.203.80.142转换为193.233.7.83
[root@localhost ~]# ip route add nat 192.203.80.142 via 193.233.7.83

#实现数据包级负载平衡，允许把数据包随机从多个路由发出。weight设置权重
[root@localhost ~]# ip route replace default equalize nexthop via 211.139.218.145 dev eth0 weight 1 nexthop \
via 211.139.218.145 dev eth1 weight 1

[root@localhost ~]# ip route add 10.1.0.0/24 via 192.168.0.1
[root@localhost ~]# ip route add 10.2.0.0/24 via 192.168.0.1 
[root@localhost ~]# ip route add default dev eno16777736

# 实现链路负载平衡.加入缺省多路径路由，让ppp0和ppp1分担负载（scope非必须的选项）
[root@localhost ~]# ip route add default scope global nexthop dev ppp0 nexthop dev ppp1
[root@localhost ~]# ip route replace default scope global nexthop dev ppp0 nexthop dev ppp1

[root@localhost ~]# ip route help
Usage: ip route { list | flush } SELECTOR
       ip route save SELECTOR
       ip route restore
       ip route showdump
       ip route get ADDRESS [ from ADDRESS iif STRING ]
                            [ oif STRING ]  [ tos TOS ]
                            [ mark NUMBER ]
       ip route { add | del | change | append | replace } ROUTE
SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]
            [ table TABLE_ID ] [ proto RTPROTO ]
            [ type TYPE ] [ scope SCOPE ]
ROUTE := NODE_SPEC [ INFO_SPEC ]
NODE_SPEC := [ TYPE ] PREFIX [ tos TOS ]
             [ table TABLE_ID ] [ proto RTPROTO ]
             [ scope SCOPE ] [ metric METRIC ]
INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...
NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS
OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]
           [ rtt TIME ] [ rttvar TIME ] [reordering NUMBER ]
           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]
           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]
           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]
           [ quickack BOOL ]
TYPE := [ unicast | local | broadcast | multicast | throw |
          unreachable | prohibit | blackhole | nat ]
TABLE_ID := [ local | main | default | all | NUMBER ]
SCOPE := [ host | link | global | NUMBER ]
NHFLAGS := [ onlink | pervasive ]
RTPROTO := [ kernel | boot | static | NUMBER ]
TIME := NUMBER[s|ms]
BOOL := [1|0]
```
#### neighbor
```bash
[root@localhost ~]# ip neighbour show                               #查看arp表
192.168.0.1 dev eno16777736 lladdr 00:50:56:c0:00:08 DELAY
192.168.0.2 dev eno16777736 lladdr 00:50:56:f1:58:d1 STALE
[root@localhost ~]# ip neighbour flush 192.168.0.2                  #删除特定条目
[root@localhost ~]# ip neighbour show                               #
192.168.0.1 dev eno16777736 lladdr 00:50:56:c0:00:08 REACHABLE
192.168.0.2 dev eno16777736  FAILED
[root@localhost ~]# ip neighbour del 10.0.0.3 dev eno16777736       #删除特定设备上的特定条目
[root@localhost ~]# ip neighbour help
Usage: ip neigh { add | del | change | replace } { ADDR [ lladdr LLADDR ]
          [ nud { permanent | noarp | stale | reachable } ]
          | proxy ADDR } [ dev DEV ]
       ip neigh {show|flush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]
```
#### rule
```bash
[root@localhost ~]# ip route add default gw 20.0.0.1
[root@localhost ~]# ip route add table  3  via 10.0.0.1 dev ethX
[root@localhost ~]# ip rule  add fwmark 3  table 3 （凡是标记了3的数据使用3路由表）
[root@localhost ~]# iptables -A PREROUTING -t mangle -i eth0 -s 192.168.0.1/24 -j MARK --set-mark 3

# 因为mangle的处理是优先于 nat 和 fiter 的，所以相依数据包到达之后先打上标记之后在通过 ip rule 规则
# 对应的数据包使用相应的路由表进行路由，最后读取路由表信息将数据包送出网关。

[root@localhost ~]# ip rule help
Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION
SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]
            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]
ACTION := [ table TABLE_ID ]
          [ prohibit | unreachable ]
          [ realms [SRCREALM/]DSTREALM ]
          [ goto NUMBER ]
TABLE_ID := [ local | main | default | NUMBER ]
```
