#### 简介
```txt
该venv模块提供了创建轻量级“虚拟环境”，提供与系统Python的隔离支持。
每一个虚拟环境都有其自己的Python二进制（允许有不同的Python版本创作环境），并且可以拥有自己独立的一套Python包。
他最大的好处是可以让每一个python项目单独使用一个环境，而不会影响python系统环境，也不会影响其他项目的环境
环境升级不影响其他应用，也不会影响全局的python环境，可防止系统中出现包管理混乱和版本冲突
```

#### 建立虚拟环境
```bash
[root@localhost tmp]# python3.6 -m venv .             #在当前目录建立一个虚拟的工作环境
[root@localhost tmp]# ll
总用量 8
drwxr-xr-x 2 root root 4096 11月 10 17:37 bin
drwxr-xr-x 2 root root    6 11月 10 17:37 include
drwxr-xr-x 3 root root   22 11月 10 17:37 lib
lrwxrwxrwx 1 root root    3 11月 10 17:37 lib64 -> lib
-rw-r--r-- 1 root root   69 11月 10 17:37 pyvenv.cfg
[root@localhost tmp]# source bin/activate             #激活虚拟环境
(tmp) [root@localhost tmp]# pwd
/tmp
(tmp) [root@localhost tmp]#                           #激活虚拟环境后，在命令行会提示当前虚拟环境的名称，表示激活成功
(tmp) [root@localhost tmp]# pip install numpy         #在当前环境安装numpy
```

