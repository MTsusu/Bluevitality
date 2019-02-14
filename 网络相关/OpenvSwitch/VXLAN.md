#### VXLAN
```txt
其自身就可以支持实现GRE隧道的功能，并且其对VLAN数量的支持达到4096*4096个~！。
VXLAN基于IP网络之上，采用的是MAC in UDP技术，从实现讲它是L2 over UDP
VXLAN是Virtual eXtensible LANs的缩写，它是对VLAN的扩展，是非常新的tunnel技术，在OpenvSwitch中应用也非常多。
相比GRE它有着很好的扩展性，同时解决了很多其它问题。从数量上讲它把12 bit的VLAN-tag扩展成24bit。
它利用了UDP同时也是IPv4的单播和多播，可跨L3边界，很巧妙地解决了GRE tunnel和VLAN存在的不足，让组网变得更加灵活。
```
#### Demo
```bash
[root@node2 ~]# ovs-vsctl add-br br1
[root@node2 ~]# ovs-vsctl add-port br1 vx1 -- set interface vx1 type=vxlan options:remote_ip=192.168.146.136

[root@node2 ~]# ovs-vsctl add-br br1
[root@node2 ~]# ovs-vsctl add-port br1 vx1 -- set interface vx1 type=vxlan options:remote_ip=192.168.146.131
[root@node2 ~]# ovs-vsctl show
1c2fa810-476c-48b0-a1e0-63e65cf939d0
    Bridge "br2"
        Port "br2"
            Interface "br2"
                type: internal
    Bridge "br3"
        Port "br3"
            Interface "br3"
                type: internal
    Bridge "br1"
        Port "vx1"
            Interface "vx1"
                type: vxlan
                options: {remote_ip="192.168.146.131"}
        Port "br1"
            Interface "br1"
                type: internal
    ovs_version: "2.7.0"
```
