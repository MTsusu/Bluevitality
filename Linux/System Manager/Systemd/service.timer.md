#### /etc/systemd/system/*.service
```bash
#创建需要执行的脚本
[root@node1 ~]# chmod a+x /usr/bin/myscript
[root@node1 ~]# cat /usr/bin/myscript          
#!/bin/bash
echo "This is a test..." >> /root/log

#创建service Unit
[root@node1 ~]# cd /etc/systemd/system
[root@node1 system]# chmod a+x test.service 
[root@node1 system]# cat test.service 
[Unit]
Description=MyScript
 
[Service]
Type=simple
ExecStart=/usr/bin/myscript
```
#### /etc/systemd/system/*.Timer
```bash
#创建Timer
[root@node1 system]# chmod a+x Myscripts.timer 
[root@node1 system]# cat Myscripts.timer
[Unit]
Description=Runs myscript every hour
 
[Timer]
# 首次运行要在启动后10分钟后
OnBootSec=10min
# 每次运行间隔时间
OnUnitActiveSec=1h
# 需要执行的脚本文件名，其Type必须是"simple"
Unit=test.service
 
[Install]
WantedBy=multi-user.target

[root@node1 system]# systemctl daemon-reload
[root@node1 system]# systemctl start timers.target
[root@node1 system]# systemctl start Myscripts.timer
[root@node1 system]# systemctl enable Myscripts.timer

#查看
[root@node1 ~]# systemctl status Myscripts.timer
● Myscripts.timer - Runs myscript every hour
   Loaded: loaded (/etc/systemd/system/Myscripts.timer; disabled; vendor preset: disabled)
   Active: active (waiting) since 五 2018-01-05 02:58:26 CST; 3min 19s ago

1月 05 02:58:26 node1 systemd[1]: Started Runs myscript every hour.
1月 05 02:58:26 node1 systemd[1]: Starting Runs myscript every hour.

#验证
[root@node1 ~]# ll log 
-rw-r--r--. 1 root root 54 1月   5 03:01 log
```
