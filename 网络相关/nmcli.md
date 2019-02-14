#### 备忘
```txt
Network Manager command line tool ===> nmcli

是一个非常丰富和灵活的命令行工具。nmcli使用的情况有：
  设备 – 正在使用的网络接口
  连接 – 一组配置设置，对于一个单一的设备可以有多个连接，可以在连接之间切换

nmcli：
  device  网络接口，是物理设备，类似于：ip link
        nmcli dev参数：status | show | connect | disconnect | delete | wifi 
  connection  连接，偏重于逻辑设置，类似于：ip address
        nmcli connection参数： show | up | down | add | modify | edit | delete | reload | load
```

#### Example
```bash
[root@localhost rules.d]# tracepath www.baidu.com         #输出像traceroute但其更加完整
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.0.2                                           0.122ms 
 1:  192.168.0.2                                           0.200ms 
 2:  no reply
 3:  no reply
 4:  no reply
[root@localhost rules.d]# nmcli general status                  #查看对应的状态信息的显示
状态    CONNECTIVITY  WIFI-HW  WIFI    WWAN-HW  WWAN        
连接的  全部          已启用   已启用  已启用   已启用     
[root@localhost rules.d]# nmcli device status                   #得到网络设备状态
设备         类型      状态    CONNECTION  
eno16777736  ethernet  连接的  eno16777736 
lo           loopback  未管理  --         
[root@localhost rules.d]# nmcli device show eno16777736         #得到特定设备的详情（属性）
GENERAL.设备:                           eno16777736
GENERAL.类型:                           ethernet
GENERAL.硬盘:                           00:0C:29:AD:AB:AE
GENERAL.MTU:                            1500
GENERAL.状态:                           100 (连接的)
GENERAL.CONNECTION:                     eno16777736
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/0
WIRED-PROPERTIES.容器:                  开
IP4.地址[1]:                            192.168.0.3/24
IP4.网关:                               192.168.0.2
IP4.DNS[1]:                             192.168.0.2
IP4.域[1]:                              localdomain
IP6.地址[1]:                            fe80::20c:29ff:fead:abae/64
IP6.网关: 
[root@localhost rules.d]# nmcli connection show                 #找出有多少连接服务于多少设备
名称         UUID                                  类型            设备        
eno16777736  5630b9e3-7cd4-4488-8a42-d0c2c817f2ba  802-3-ethernet  eno16777736 
eno16777736  91fc2077-5bfe-445e-8b5e-8d939a966189  802-3-ethernet  -- 
[root@localhost rules.d]# nmcli connection show eno16777736     #得到特定连接的详情（属性）
connection.id:                          eno16777736
connection.uuid:                        5630b9e3-7cd4-4488-8a42-d0c2c817f2ba
connection.interface-name:              eno16777736
connection.type:                        802-3-ethernet
connection.autoconnect:                 no
.................略
connection.gateway-ping-timeout:        0
connection.metered:                     未知
802-3-ethernet.port:                    --
802-3-ethernet.speed:                   0
802-3-ethernet.duplex:                  --
802-3-ethernet.auto-negotiate:          yes
802-3-ethernet.mac-address:             00:0C:29:AD:AB:AE
802-3-ethernet.cloned-mac-address:      --
802-3-ethernet.mac-address-blacklist:   
802-3-ethernet.mtu:                     自动
802-3-ethernet.s390-subchannels:        
802-3-ethernet.s390-nettype:            --
802-3-ethernet.s390-options:            
802-3-ethernet.wake-on-lan:             1 (default)
802-3-ethernet.wake-on-lan-password:    --
ipv4.method:                            auto
ipv4.dns:                               192.168.0.2
ipv4.dns-search:                        
ipv4.addresses:                         
ipv4.gateway:                           --
ipv4.routes:                            
ipv4.route-metric:                      0
ipv4.ignore-auto-routes:                no
ipv4.ignore-auto-dns:                   no
ipv4.dhcp-client-id:                    --
ipv4.dhcp-send-hostname:                yes
ipv4.dhcp-hostname:                     --
ipv4.never-default:                     no
ipv4.may-fail:                          yes
ipv6.method:                            link-local
ipv6.dns:                               
ipv6.dns-search:                        
ipv6.addresses:                         
ipv6.gateway:                           --
ipv6.routes:                            
.................略
ipv6.dhcp-hostname:                     --
GENERAL.名称:                           eno16777736
GENERAL.UUID:                           5630b9e3-7cd4-4488-8a42-d0c2c817f2ba
GENERAL.设备:                           eno16777736
GENERAL.状态:                           已激活
GENERAL.默认:                           是
.................略
GENERAL.DBUS-PATH:                      /org/freedesktop/NetworkManager/ActiveConnection/0
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/Settings/1
GENERAL.SPEC 对象:                      /
GENERAL.MASTER-PATH:                    --
IP4.地址[1]:                            192.168.0.3/24
IP4.网关:                               192.168.0.2
IP4.DNS[1]:                             192.168.0.2
IP4.域[1]:                              localdomain
.................略
DHCP4.选项[8]:                          expiry = 1514572087
DHCP4.选项[9]:                          domain_name = localdomain
DHCP4.选项[10]:                         next_server = 192.168.0.254
DHCP4.选项[11]:                         broadcast_address = 192.168.0.255
DHCP4.选项[12]:                         dhcp_message_type = 5
DHCP4.选项[13]:                         requested_subnet_mask = 1
DHCP4.选项[14]:                         dhcp_lease_time = 2161800
DHCP4.选项[15]:                         routers = 192.168.0.2
DHCP4.选项[16]:                         ip_address = 192.168.0.3
.................略
DHCP4.选项[27]:                         network_number = 192.168.0.0
DHCP4.选项[28]:                         requested_host_name = 1
DHCP4.选项[29]:                         dhcp_server_identifier = 192.168.0.254
IP6.地址[1]:                            fe80::20c:29ff:fead:abae/64
IP6.网关:                               

connection.id:                          eno16777736
connection.uuid:                        91fc2077-5bfe-445e-8b5e-8d939a966189
connection.interface-name:              eno16777736
connection.type:                        802-3-ethernet
connection.autoconnect:                 no
.................略
connection.autoconnect-slaves:          -1 (default)
connection.secondaries:                 
connection.gateway-ping-timeout:        0
connection.metered:                     未知
802-3-ethernet.port:                    --
802-3-ethernet.speed:                   0
802-3-ethernet.duplex:                  --
802-3-ethernet.auto-negotiate:          yes
.................略
802-3-ethernet.mac-address-blacklist:   
802-3-ethernet.mtu:                     自动
802-3-ethernet.s390-subchannels:        
802-3-ethernet.s390-nettype:            --
802-3-ethernet.s390-options:            
802-3-ethernet.wake-on-lan:             1 (default)
802-3-ethernet.wake-on-lan-password:    --
ipv4.method:                            auto
ipv4.dns:                               
ipv4.dns-search:                        
ipv4.addresses:                         
ipv4.gateway:                           --
.................略
ipv4.dhcp-hostname:                     --
ipv4.never-default:                     no
ipv4.may-fail:                          yes
ipv6.method:                            auto
ipv6.dns:                               
ipv6.dns-search:                        
ipv6.addresses:                         
ipv6.gateway:                           --
ipv6.routes:                            
ipv6.route-metric:                      -1
.................略
ipv6.ip6-privacy:                       -1 (未知)
ipv6.dhcp-send-hostname:                yes
ipv6.dhcp-hostname:                     --
[root@localhost rules.d]# nmcli device wifi list                    #WIFI list
*  SSID              MODE    CHAN  RATE    SIGNAL  BARS  SECURITY
    netdatacomm_local  Infra  6    54 MB/s  37      ▂▄__  WEP
*  F1                Infra  11    54 MB/s  98      ▂▄▆█  WPA1
    LoremCorp          Infra  1    54 MB/s  62      ▂▄▆_  WPA2 802.1X
    Internet          Infra  6    54 MB/s  29      ▂___  WPA1
    HPB110a.F2672A    Ad-Hoc  6    54 MB/s  22      ▂___  -- 
```

#### connection
```bash
[root@localhost ~]# localectl set-locale LANG=en_US.utf8            #改为英文CLI环境
[root@localhost ~]#  nmcli device show eno16777736                  #查看接口详细信息（查看接口属性）
GENERAL.DEVICE:                         eno16777736
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         00:0C:29:AD:AB:AE
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     eno16777736
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/0
WIRED-PROPERTIES.CARRIER:               on
IP4.ADDRESS[1]:                         192.168.0.3/24
IP4.GATEWAY:                            192.168.0.2
IP4.DNS[1]:                             192.168.0.2
IP4.DOMAIN[1]:                          localdomain
IP6.ADDRESS[1]:                         fe80::20c:29ff:fead:abae/64
IP6.GATEWAY:       
[root@localhost ~]# nmcli connection modify eno16777736 +ipv4.addresses 172.16.100.1/26   #修改接口属性(+|-| )
[root@localhost ~]# nmcli connection up eno16777736                                       #刷新设置
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/1)
[root@localhost ~]# nmcli device show eno16777736 | grep IP4.ADDRESS                      #查看
IP4.ADDRESS[1]:                         192.168.0.3/24
IP4.ADDRESS[2]:                         172.16.100.1/26

[root@localhost ~]# nmcli connection down eno1677736      #禁用与启用设备地址
[root@localhost ~]# nmcli connection up eno1677736 

#添加更多的DNS，注意：要使用额外的+符号，并且要是+ipv4.dns，而不是ip4.dns。
[root@localhost ~]# nmcli connection modify "static" +ipv4.dns 8.8.8.8

#总结
[root@localhost ~]# nmcli connection modify <interface> [+|-] setting.property value      #设置链接属性

```
