#### Demo
```txt
[root@localhost ~]# systemd-analyze 
Startup finished in 1.461s (kernel) + 1.637s (initrd) + 10.185s (userspace) = 13.284s
[root@localhost /]# tree /etc/systemd/ -L 2
/etc/systemd/
├── bootchart.conf
├── coredump.conf
├── journald.conf      # <--- 日志相关设置
├── logind.conf
├── system      # <--- 配置文件存放位置（/etc/systemd/system）
│   ├── basic.target.wants
│   ├── dbus-org.freedesktop.NetworkManager.service -> /usr/lib/systemd/system/NetworkManager.service
│   ├── dbus-org.freedesktop.nm-dispatcher.service -> /usr/lib/systemd/system/NetworkManager-dispatcher.service
│   ├── default.target -> /lib/systemd/system/multi-user.target      # <--- 启动级别
│   ├── default.target.wants
│   ├── getty.target.wants
│   ├── multi-user.target.wants      # <--- 
│   ├── sockets.target.wants
│   ├── sysinit.target.wants
│   └── system-update.target.wants
├── system.conf      # <--- 
├── user
└── user.conf
```
#### 备忘
```txt
CentOS 7 版本开始以后服务的管理是通过 systemd 进行的，它用来启动守护进程并且它已经成为大多数发行版的标准配置
它的设计目标是为系统的启动和管理提供一套完整的解决方案。（Systemd 取代了initd，成为OS的第1个进程，其PID为1）
Systemd默认从"/etc/systemd/system/*"读配置，但里面大部分都是软链接，指向了 "/usr/lib/systemd/system/" 真正的配置在这里
配置文件大部分位于于 /usr/lib/systemd/system/ 目录，但 Red Hat 官方指出该目录主要是原本软件提供的设置，不建议修改！
因此，要设置的配置文件位置应置于 /etc/systemd/system/

软件提供方释出的默认配置文件路径：
    /usr/lib/systemd/system/XXX.service

用户自定义的默认配置文件路径：
    /etc/systemd/system/XXX.service.d/custom.conf
    即在"/etc/systemd/system/"下创建与配置文件同名的目录，但其后缀要加".d"的扩展。然后在该目录下创建配置文件...
    在这个目录下的文件会"累加其他设置"进入 /usr/lib/systemd/system/XXX.service 内

相依服务的链接：（启动之前）
    /etc/systemd/system/XXX.service.requires/*
    即启动 XXX.service 之前需事先启动哪些服务
    
相依服务的链接：（启动之后）
    /etc/systemd/system/XXX.service.wants/*
    即启动 XXX.service 之后最好再加上这目录下面建议的服务

关于Target文件： 
    Target 就是一个 Unit 组，包含许多相关的 Unit 配置...
    启动某个 Target 时，Systemd 就会启动里面所有的 Unit。
    从这个意义上说，Target 类似于"状态点"，启动某个 Target 就好比启动到某种状态

启动脚本的位置：
    以前是/etc/init.d目录，符号链接到不同的 RunLevel 目录 （比如/etc/rc3.d、/etc/rc5.d等）
    现在则存放在/lib/systemd/system和/etc/systemd/system目录。
```
#### 重读systemd的配置文件
`systemctl daemon-reload`

#### 操作demo
```txt
Systemd 可以管理所有系统资源。不同的资源统称为 Unit（单位），下面是常见的 Unit：
    Service unit：   系统服务
    Target unit：    多个 Unit 构成的一个组
    Device Unit：    硬件设备
    Mount Unit：     文件系统的挂载点
    Automount Unit： 自动挂载点
    Path Unit：      文件或路径
    Scope Unit：     不是由 Systemd 启动的外部进程
    Slice Unit：     进程组
    Snapshot Unit：  Systemd 快照，可以切回某个快照
    Socket Unit：    进程间通信的 socket
    Swap Unit：      swap 文件
    Timer Unit：     定时器（常见于控制服务的工作时间段）

[root@study ~]# systemctl [command] [unit]
command 主要有：
start       ：立刻启动后面接的 unit
stop        ：立刻关闭后面接的 unit
restart     ：立刻关闭后启动后面接的 unit，亦即 stop 再 start
reload      ：不关闭后面接的 unit 的情况下重新载入配置文件，让设置生效
enable      ：设置开机时，后面接的 unit 会被启动
disable     ：设置开机时，后面接的 unit 不被启动
status      ：目前后面接的这个 unit 的状态，会列出有没有正在执行、开机默认执行否、登录等信息等！...
is-active   ：判断目前有没有正在运行
is-enable   ：判断开机时有没有默认要启用此 unit

范例一：查看目前 atd 服务的状态
[root@study ~]# systemctl status atd.service
atd.service - Job spooling tools
   Loaded: loaded （/usr/lib/systemd/system/atd.service; enabled）
   Active: active （running） since Mon 2015-08-10 19:17:09 CST; 5h 42min ago
 Main PID: 1350 （atd）
   CGroup: /system.slice/atd.service
           └─1350 /usr/sbin/atd -f

Aug 10 19:17:09 study.centos.vbird systemd[1]: Started Job spooling tools.
# Loaded：这行在说明，开机的时候这个 unit 会不会启动，enabled 为开机启动，disabled 开机不会启动
# Active：现在这个 unit 的状态是正在执行 （running） 或没有执行 （dead）
# 后面几行则是说明这个 unit 程序的 PID 状态以及最后一行显示这个服务的登录文件信息！
# 登录文件信息格式为：“时间” “讯息发送主机” “哪一个服务的讯息” “实际讯息内容”
# 所以上面的显示讯息是：这个 atd 默认开机就启动，而且现在正在运行的意思！

范例二：正常关闭这个 atd 服务
[root@study ~]# systemctl stop atd.service
[root@study ~]# systemctl status atd.service
atd.service - Job spooling tools
   Loaded: loaded （/usr/lib/systemd/system/atd.service; enabled）
   Active: inactive （dead） since Tue 2015-08-11 01:04:55 CST; 4s ago
  Process: 1350 ExecStart=/usr/sbin/atd -f $OPTS （code=exited, status=0/SUCCESS）
 Main PID: 1350 （code=exited, status=0/SUCCESS）

Aug 10 19:17:09 study.centos.vbird systemd[1]: Started Job spooling tools.
Aug 11 01:04:55 study.centos.vbird systemd[1]: Stopping Job spooling tools...
Aug 11 01:04:55 study.centos.vbird systemd[1]: Stopped Job spooling tools.
# 目前这个 unit 下次开机还是会启动，但是现在是没在运行的状态中！同时，
# 最后两行为新增加的登录讯息，告诉我们目前的系统状态喔！

[root@study ~]# systemctl [command] [--type=TYPE] [--all]
command:
    list-units      ：依据 unit 列出目前有启动的 unit。若加上 --all 才会列出没启动的。
    list-unit-files ：依据 /usr/lib/systemd/system/ 内的文件，将所有文件列表说明。
--type=TYPE：就是之前提到的 unit 类型，主要有 service, socket, target 等

范例一：列出系统上面有启动的 unit
[root@study ~]# systemctl
UNIT                      LOAD   ACTIVE SUB       DESCRIPTION
proc-sys-fs-binfmt_mis... loaded active waiting   Arbitrary Executable File Formats File System
sys-devices-pc...:0:1:... loaded active plugged   QEMU_HARDDISK
sys-devices-pc...0:1-0... loaded active plugged   QEMU_HARDDISK
sys-devices-pc...0:0-1... loaded active plugged   QEMU_DVD-ROM
.....（中间省略）.....
vsftpd.service            loaded active running   Vsftpd ftp daemon
.....（中间省略）.....
cups.socket               loaded failed failed    CUPS Printing Service Sockets
.....（中间省略）.....
LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

141 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
# 列出的项目中，主要的意义是：
# UNIT   ：项目的名称，包括各个 unit 的类别 （看扩展名）
# LOAD   ：开机时是否会被载入，默认 systemctl 显示的是有载入的项目而已喔！
# ACTIVE ：目前的状态，须与后续的 SUB 搭配！就是我们用 systemctl status 观察时，active 的项目！
# DESCRIPTION ：详细描述啰
# cups 比较有趣，因为刚刚被我们玩过，所以 ACTIVE 竟然是 failed 的喔！被玩死了！ ^_^
# 另外，systemctl 都不加参数，其实默认就是 list-units 的意思！

范例二：列出所有已经安装的 unit 有哪些？
[root@study ~]# systemctl list-unit-files
UNIT FILE                                   STATE
proc-sys-fs-binfmt_misc.automount           static
dev-hugepages.mount                         static
dev-mqueue.mount                            static
proc-fs-nfsd.mount                          static
.....（中间省略）.....
systemd-tmpfiles-clean.timer                static

336 unit files listed.

[root@study ~]# systemctl list-units --type=target --all
UNIT                   LOAD   ACTIVE   SUB    DESCRIPTION
basic.target           loaded active   active Basic System
cryptsetup.target      loaded active   active Encrypted Volumes
emergency.target       loaded inactive dead   Emergency Mode
final.target           loaded inactive dead   Final Step
getty.target           loaded active   active Login Prompts
graphical.target       loaded active   active Graphical Interface
local-fs-pre.target    loaded active   active Local File Systems （Pre）
local-fs.target        loaded active   active Local File Systems
multi-user.target      loaded active   active Multi-User System
network-online.target  loaded inactive dead   Network is Online
network.target         loaded active   active Network
nss-user-lookup.target loaded inactive dead   User and Group Name Lookups
paths.target           loaded active   active Paths
remote-fs-pre.target   loaded active   active Remote File Systems （Pre）
remote-fs.target       loaded active   active Remote File Systems
rescue.target          loaded inactive dead   Rescue Mode
shutdown.target        loaded inactive dead   Shutdown
slices.target          loaded active   active Slices
sockets.target         loaded active   active Sockets
sound.target           loaded active   active Sound Card
swap.target            loaded active   active Swap
sysinit.target         loaded active   active System Initialization
syslog.target          not-found inactive dead   syslog.target
time-sync.target       loaded inactive dead   System Time Synchronized
timers.target          loaded active   active Timers
umount.target          loaded inactive dead   Unmount All Filesystems

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

26 loaded units listed.
To show all installed unit files use 'systemctl list-unit-files'.

[root@study ~]# systemctl poweroff  系统关机
[root@study ~]# systemctl reboot    重新开机
[root@study ~]# systemctl suspend   进入暂停模式
[root@study ~]# systemctl hibernate 进入休眠模式
[root@study ~]# systemctl rescue    强制进入救援模式
[root@study ~]# systemctl emergency 强制进入紧急救援模式

查看相依性
[root@study ~]# systemctl list-dependencies [unit] [--reverse]
选项与参数：
--reverse ：反向追踪谁使用这个 unit 的意思！

查看特定target下的服务
[root@study ~]# systemctl list-dependencies graphical.target
graphical.target
├─accounts-daemon.service
├─gdm.service
├─network.service
├─rtkit-daemon.service
├─systemd-update-utmp-runlevel.service
└─multi-user.target
  ├─abrt-ccpp.service
  ├─abrt-oops.service
.....（下面省略）.....

查看特定服务的配置文件
[root@localhost /]# systemctl cat atd.service
# /usr/lib/systemd/system/atd.service
[Unit]
Description=Job spooling tools
After=syslog.target systemd-user-sessions.service

[Service]
EnvironmentFile=/etc/sysconfig/atd
ExecStart=/usr/sbin/atd -f $OPTS
IgnoreSIGPIPE=no

[Install]
WantedBy=multi-user.target

显示瀑布状的启动过程流：（不加 unit 参数则从 multi-user.target 开始）
[root@localhost system]#  systemd-analyze critical-chain atd.service
The time after the unit is active or started is printed after the "@" character.
The time the unit takes to start is printed after the "+" character.

atd.service @3.332s
└─systemd-user-sessions.service @3.251s +74ms
  └─basic.target @3.245s
    └─sockets.target @3.245s
      └─dbus.socket @3.245s
        └─sysinit.target @3.245s
          └─systemd-update-utmp.service @3.241s +3ms
            └─auditd.service @3.221s +19ms
              └─systemd-tmpfiles-setup.service @3.216s +3ms
                └─rhel-import-state.service @3.208s +7ms
                  └─local-fs.target @3.206s
                    └─boot.mount @312ms +373ms
                      └─local-fs-pre.target @311ms
                        └─lvm2-monitor.service @87ms +223ms
                          └─lvm2-lvmetad.service @100ms
                            └─lvm2-lvmetad.socket @86ms
                              └─-.slice

显示当前主机的信息：
[root@localhost system]#  hostnamectl
   Static hostname: localhost.localdomain
         Icon name: computer-vm
           Chassis: vm
        Machine ID: b8e1402695064c25b019e5bce00d3714
           Boot ID: bedf722bfbb14d48b4bd1f5d75fc8e18
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-514.26.2.el7.x86_64
      Architecture: x86-64

设置主机名：  hostnamectl set-hostname rhel7
查看启动耗时： systemd-analyze
查看每个服务的启动耗时：    systemd-analyze blame
查看本地化设置：    localectl
设置本地化参数：    localectl set-locale LANG=en_GB.utf8 && localectl set-keymap en_GB

查看当前时区设置：   timedatectl
显示所有可用的时区：  timedatectl list-timezones           
设置当前时区：     
    timedatectl set-timezone America/New_York
    timedatectl set-time YYYY-MM-DD
    timedatectl set-time HH:MM:SS

列出所有可用单元：   systemctl list-unit-files 
列出所有运行中单元：  systemctl list-units
检查某个单元（如 crond.service）是否启用：     systemctl is-enabled crond.service
列出所有服务：     systemctl list-unit-files –type=service
列出当前使用的运行等级：    systemctl get-default
设置多用户模式为默认等级：    systemctl set-default runlevel3.target
启动运行等级5，即图形模式：  systemctl isolate runlevel5.target 或： systemctl isolate graphical.target

重启、停止、挂起、休眠系统或使系统进入混合睡眠：
    systemctl reboot
    systemctl halt
    systemctl poweroff
    systemctl suspend
    systemctl hibernate
    systemctl hybrid-sleep

启动、重启、停止、重载服务以及检查服务（如 httpd.service）状态：
    systemctl start httpd.service
    systemctl stop httpd.service
    systemctl restart httpd.service
    systemctl reload httpd.service
    systemctl status httpd.service

激活服务并在开机时启用或禁用服务（即系统启动时自动启动mysql.service服务）：
    systemctl is-active mysql.service
    systemctl enable mysql.service
    systemctl disable mysql.service

使用systemctl命令杀死服务：
    systemctl kill crond

列出所有系统挂载点：
    systemctl list-unit-files –type=mount

挂载、卸载、重新挂载、重载系统挂载点并检查系统中挂载点状态：
    systemctl start tmp.mount
    systemctl stop tmp.mount
    systemctl restart tmp.mount
    systemctl reload tmp.mount
    systemctl status tmp.mount

列出所有可用系统套接口：
    systemctl list-unit-files –type=socket

检查某个服务的所有配置细节：
    systemctl show mysql

等级说明：
    Runlevel 0  : 关闭系统
    Runlevel 1  : 救援，维护模式
    Runlevel 2  : 多用户，无NFS
    Runlevel 3  : 多用户，无图形系统
    Runlevel 4  : 多用户，无图形系统
    Runlevel 5  : 多用户，图形化系统
    Runlevel 6  : 关闭并重启机器
```
#### hostnamectl
```bash
# hostnamectl：
#    status
#    set-hostname <name>

[root@localhost ~]# hostnamectl status
   Static hostname: localhost.localdomain
         Icon name: computer-vm
           Chassis: vm
        Machine ID: a0d4da63906a4a5f97671a27a749c0e3
           Boot ID: b9e60e318211441f9a77bfc17b9003e5
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-327.el7.x86_64
      Architecture: x86-64
[root@localhost ~]# cat /etc/centos-release
CentOS Linux release 7.2.1511 (Core) 
[root@localhost ~]# hostnamectl set-hostname test           #设置主机名
[root@localhost ~]# hostname
test
```
