#### iSCSI 工作流程
```txt
当iSCSI主机应用程序发出数据读写请求后，操作系统会生成一个相应的SCSI命令
该SCSI命令在iSCSI Initiator层被封装成iSCSI消息包并通过TCP/IP传送到设备侧
设备侧的iSCSI Target层会解开iSCSI消息包，得到SCSI命令的内容，然后传送给SCSI设备执行
设备执行SCSI命令后的响应，在经过设备侧iSCSI Target层时被封装成iSCSI响应PDU，通过TCP/IP网络传送给主机的iSCSI Initiator层
Initiator会从iSCSI响应PDU里解析出SCSI响应并传送给操作系统
操作系统再响应给应用程序。
```
#### initiator 与 Target 间的交互
```txt
语法格式：
iscsiadm -m discovery [ -d debug_level ] [ -P printlevel ] [ -I iface -t type -p ip:port [ -l ] ]

在initiator端寻找target提供的信息：
iscsiadm -m discovery -t sendtargets -p 192.168.10.1:3260

在initiator端显示发现的target主机：   
iscsiadm -m node

在initiator端显示建立的target连接：  
iscsiadm -m session

在initiator端断开指定target的连接：   
iscsiadm -m node iqn.2013-09.com.inter.10.1:test-target  -u

在initiator端连接指定的target主机：   
iscsiadm -m node iqn.2013-09.com.inter.10.1:test-target  [-l/--login]

在initiator端退出所有登录的连接：     
iscsiadm -m node --logoutall=all
```
#### 关于验证（单向）
```txt
tgtadm常用于管理3类对象：
  target:    创建new，删除，查看
  lun：      创建，查看，删除
  account：  创建，绑定，解绑，删除，查看
  
在target端创建账号并在target端将账号绑定到指定的target：   
tgtadm --lld iscsi -m account -o new  --user <username> --password <password>
tgtadm --lld iscsi -m account -o bind --tid 1 --user <username>

在target端删除一个账号：             
tgtadm --lld iscsi -m account -o delete --user <username>
  
在initiator端命令方式连接/登录：       
iscsiadm -m node -T <target-name> -p <ip-address>:<port> --login

在initiator端命令方式验证登录：
iscsiadm -m node -T LUN_NAME -o update --name node.session.auth.authmethod --value=CHAP
iscsiadm -m node -T LUN_NAME -o update --name node.session.auth.username --value=<user>
iscsiadm -m node -T LUN_NAME -o update --name node.session.auth.password --value=<passwd>

在initiator端配置方式验证登录：
vim /etc/iscsi/iscsid.conf
node.session.auth.authmethod = CHAP
node.session.auth.username = username
node.session.auth.password = password

如果此前尚未登录过此target，接下来直接发现并登入即可。否则，则需要按照下面的第三步实现认证的启用
3、如果initiator端已经登录过此target，此时还需要先注销登录后重启iscsid服务，并在删除此前生成的database后重新发现target，并重新登入：
# iscsiadm -m session -r sid -u

# iscsiadm -m node -T iqn.2010-8.com.example.ts:disk1 -p 192.168.0.11:3260 -u
# iscsiadm -m node -T iqn.2010-8.com.example.ts:disk1 -p 192.168.0.11:3260 -o delete
# rm -rf /var/lib/iscsi/nodes/iqn.2010-08.com.example.tgt:disk1
# rm -rf -rf /var/lib/iscsi/send_targets/192.168.0.11,3260
# service iscsid restart

# iscsiadm -m discovery -t sendtargets -p 192.168.0.11
# iscsiadm -m node -T iqn.2010-8.com.example.ts:disk1 -p 192.168.0.11:3260 -l

说明：其中的target名字和target主机地址可能需要按照您的实际情况修改。 

iscsiadm是个模式化的工具，其模式可通过-m或--mode选项指定，常见的模式有discoverydb、node、fw、session、host、iface几个
```
#### tgtadm
```txt
tgtadm --lld [driver] --op [operation] --mode [mode] [OPTION]...

添加一个新的 target 且其ID为 [id]， 名字为 [name]：
tgtadm --lld [driver] --op new --mode target --tid=[id] --targetname [name]

在target端创建一个target：（同上）
tgtadm --lld iscsi --op new --mode target --tid 1 -T iqn.2013-05.com.xxxxx:tsan.disk1

向某ID为[id]的设备上添加一个新的LUN，其号码为[lun]，且此设备供给initiator。[path]是块设备路径，此设备也可以是raid或lvm。lun0被系统预留
tgtadm --lld [driver] --op new --mode=logicalunit --tid=[id] --lun=[lun] --backing-store [path]

目标接受任何发起者：
tgtadm --lld iscsi --op bind --mode target --tid 1 -I ALL

显示所有或某个特定的target:
tgtadm --lld [driver] --op show --mode target [--tid=[id]]

显示所有target：（同上）
tgtadm --lld iscsi --op show --mode target

删除ID为[id]的target:
tgtadm --lld [driver] --op delete --mode target --tid=[id]

删除target [id] 中的LUN [lun]：
tgtadm --lld [driver] --op delete --mode=logicalunit --tid=[id] --lun=[lun]

定义某target的基于主机的访问控制列表，其中，[address]表示允许访问此target的initiator客户端的列表：
tgtadm --lld [driver] --op bind --mode=target --tid=[id] --initiator-address=[address]

解除target [id]的访问控制列表中[address]的访问控制权限：
tgtadm --lld [driver] --op unbind --mode=target --tid=[id] --initiator-address=[address]

创建一个新账号:
tgtadm --lld iscsi --op new  --mode account --user christina --password 123456
tgtadm --lld iscsi --op show --mode account

绑定账号到target：
tgtadm --lld iscsi --op bind --mode account --tid 1 --user christina
tgtadm --lld iscsi --op show --mode target

Set up an outgoing account. First, you need to create a new account like the previous example：
tgtadm --lld iscsi --op new  --mode account --user christina --password 123456
tgtadm --lld iscsi --op show --mode account
tgtadm --lld iscsi --op bind --mode account --tid 1 --user christina --outgoing
tgtadm --lld iscsi --op show --mode target

生成服务器端的配置文件：
tgt-admin --dump > targets.conf
```

#### iscsiadm
```txt
格式：
iscsiadm -m discovery [ -d debug_level ] [ -P printlevel ] [ -I iface -t type -p ip:port [ -l ] ] 
iscsiadm -m node [ -d debug_level ] [ -P printlevel ] [ -L all,manual,automatic ] [ -U all,manual,automatic ] [ [ -T tar-getname -p ip:port -I iface ] [ -l | -u | -R | -s] ] [ [ -o operation ] 

-d, --debug=debug_level       显示debug信息，级别为0-8；
-l, --login
-t, --type=type  这里可以使用的类型为sendtargets(可简写为st)、slp、fw和 isns，
                 此选项仅用于discovery模式，且目前仅支持st、fw和isns；其中st表示允许每个iSCSI target发送一个可用target列表给initiator；
-p, --portal=ip[:port]        指定target服务的IP和端口；
-m, --mode op                 可用的mode有discovery, node, fw, host iface 和 session
-T, --targetname=targetname   用于指定target的名字
-u, --logout 
-o, --op=OPEARTION：          指定针对discoverydb数据库的操作，其仅能为new、delete、update、show和nonpersistent其中之一；
-I, --interface=[iface]：     指定执行操作的iSCSI接口，这些接口定义在/var/lib/iscsi/ifaces中；

# iscsiadm -m discovery -t sendtargets -p 192.168.0.11
# iscsiadm -m node -T iqn.2010-8.com.example.ts:disk1 -p 192.168.0.11:3260 -l

# iscsiadm -m node -T iqn.2010-8.com.example.ts:disk1 -p 192.168.0.11:3260 -u
# iscsiadm -m node -T iqn.2010-8.com.example.ts:disk1 -p 192.168.0.11:3260 -o delete
   
查看会话相关信息：
# iscsiadm -m session -s
```
