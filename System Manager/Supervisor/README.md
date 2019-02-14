#### 备忘
```txt
Supervisor 只能管理在前台运行的程序，如果应用程序有后台运行的选项则需要关闭
是一个用 Python 写的进程管理工具，可以很方便的用来启动、重启、关闭进程（不仅仅是 Python 进程）
除了对单个进程的控制，还可以同时启动、关闭多个进程
比如很不幸的服务器故障导致所有应用被杀死，此时可用其同时启动所有应用而不是一个个地敲命令启动...
当一个进程挂掉时linux不会自动重启它，想要自动重启的话还要自己写一个监控重启脚本。而supervisor则可以完美的解决这些问题。
其实supervisor管理进程就是通过"fork/exec"的方式把这些被管理的进程当作它的子进程来启动。
这样的话只要在supervisor配置文件中把要管理的进程的可执行文件的路径写进去就OK了。省下了Linux管理进程时写控制脚本的麻烦

supervisor可以对进程组统一管理，也就是说可以把需要管理的进程写到一个组里面
然后我们把这个组作为一个对象进行管理，如启动，停止，重启等等操作...
```

#### Example.conf
```conf
[unix_http_server]
file=/tmp/supervisor.sock   ; UNIX socket 文件，supervisorctl会使用
chmod=0700                  ; socket 文件的 mode，默认是 0700
chown=nobody:nogroup        ; socket 文件的 owner，格式： uid:gid

[inet_http_server]          ; supervisor的HTTP服务，其提供web管理界面
port=127.0.0.1:9001         ; Web管理后台运行的 IP 和端口，若开放到公网需注意安全性
username=user               ; 登录管理的用户名
password=123                ; 登录管理的密码

[supervisord]
nodaemon=true               ; 当在Docker容器内用于管理后台守护进程时需将Supervisor设置为前台启动!

[program:usercenter]        ; usercenter 是应用的唯一标识，不能重复。对其的操作如：start, restart等..都通过此名字实现
directory = /home/leon/projects/usercenter          ; 程序的启动目录，command指令的工作目录
command = gunicorn -w 8 -b 0.0.0.0:17510 wsgi:app   ; 启动命令
priority=1                                          ; 启动优先级
autostart = true                                    ; 在 supervisord 启动时是否也自动启动
startsecs = 5                                       ; 启动 5 秒后没有异常退出就当作已正常启动
autorestart = true                                  ; 程序异常退出后自动重启
startretries = 3                                    ; 启动失败后的重试次数，默认 3
exitcodes=0,2                                       ; 期望或者说预料中的进程退出码
user = leon                                         ; 用哪个用户身份启动
redirect_stderr = true                              ; 把 stderr 重定向到 stdout，默认 false
stdout_logfile_maxbytes = 20MB                      ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups = 20                         ; stdout 日志文件备份数
stdout_logfile = /data/logs/usercenter_stdout.log
; stdout 日志文件，需要注意当指定的日志路径中的目录不存在时无法正常启动，所以需要手动创建目录

; 有时候用 Supervisor 托管的程序还会有子进程（如 Tornado）
; 如果只杀死主进程，子进程就可能变成孤儿进程。通过这两项配置来确保所有子进程都能正确停止：
stopasgroup = true
killasgroup = true
```
#### Groups
```
[group:thegroupname]  
; 这就是给programs分组，划分到组里的program就不用一个个去操作了，可以使用组名进行统一的操作... 
; 注意program被划分到组后，就相当于原来的配置从supervisor的配置文件里消失了
; supervisor只会对组进行管理，而不再会对组里面的单个program进行管理了

programs=progname1,progname2                        ; 用逗号分隔的组成员，这个是个必须的设置项
priority=999 
```
#### supervisorctl
```bash
# Supervisorctl 是 supervisord 的一个命令行客户端工具
# 启动时需要指定与 supervisord 使用同一份配置文件，否则与 supervisord 一样按照顺序查找配置文件。

[root@localhost ~]# supervisorctl -c /etc/supervisord.conf
supervisor> status                      # 查看程序状态
supervisor> stop usercenter             # 关闭 usercenter 程序
supervisor> start usercenter            # 启动 usercenter 程序
supervisor> restart usercenter          # 重启 usercenter 程序
supervisor> reread                      # 读取有更新（增加）的配置文件，不会启动新添加的程序
supervisor> update                      # 重启配置文件修改过的程序

# 上面这些命令都有相应的输出，除进入supervisorctl的shell界面以外，也可直接在终端运行：
$ supervisorctl status
$ supervisorctl stop usercenter
$ supervisorctl start usercenter
$ supervisorctl restart usercenter
$ supervisorctl reread
$ supervisorctl update
```
