#### 备忘
```txt
格式：              服务名称[.=!]信息等级
    .               从指定等级开始
    =               指定等级
    !               排除等级
    
等级：
    info            基本信息
    notice          除info外需注意信息
    warning(warn)   警告信息，可能有问题但还不至于影响到服务
    err(error)      错误信息
    crit            严重错误
    alert           严重警告
    emerg(panic)    崩溃状态
    none            不记录...
    *               所有级别
```
#### 远程服务器接收日志
```bash
[root@localhost /]# grep -A 2 '# Provides' /etc/rsyslog.conf 
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514
--
# Provides TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514
```
#### Rsyslog Modules ...
```bash
[root@localhost /]# grep "###" /etc/rsyslog.conf        #配置分段...
#### MODULES ####
#### GLOBAL DIRECTIVES ####
#### RULES ####
# ### begin forwarding rule ###
# ### end of the forwarding rule ###
[root@localhost /]# rpm -ql rsyslog | grep '/usr/lib64'
/usr/lib64/rsyslog
/usr/lib64/rsyslog/imdiag.so                            #以"i"开头的是与输入相关的模块，如：过滤工具
/usr/lib64/rsyslog/imfile.so
/usr/lib64/rsyslog/imjournal.so
/usr/lib64/rsyslog/imklog.so
/usr/lib64/rsyslog/immark.so
/usr/lib64/rsyslog/impstats.so
/usr/lib64/rsyslog/imptcp.so
/usr/lib64/rsyslog/imtcp.so
/usr/lib64/rsyslog/imudp.so
/usr/lib64/rsyslog/imuxsock.so
/usr/lib64/rsyslog/lmnet.so
/usr/lib64/rsyslog/lmnetstrms.so
/usr/lib64/rsyslog/lmnsd_ptcp.so
/usr/lib64/rsyslog/lmregexp.so
/usr/lib64/rsyslog/lmstrmsrv.so
/usr/lib64/rsyslog/lmtcpclt.so
/usr/lib64/rsyslog/lmtcpsrv.so
/usr/lib64/rsyslog/lmzlibw.so
/usr/lib64/rsyslog/mmanon.so
/usr/lib64/rsyslog/mmcount.so
/usr/lib64/rsyslog/omjournal.so                         #以"o"开头的是与输出相关的模块...
/usr/lib64/rsyslog/ommail.so
/usr/lib64/rsyslog/omprog.so
/usr/lib64/rsyslog/omruleset.so
/usr/lib64/rsyslog/omstdout.so
/usr/lib64/rsyslog/omtesting.so
/usr/lib64/rsyslog/omuxsock.so
/usr/lib64/rsyslog/pmaixforwardedfrom.so
/usr/lib64/rsyslog/pmcisconames.so
/usr/lib64/rsyslog/pmlastmsg.so
/usr/lib64/rsyslog/pmrfc3164sd.so
/usr/lib64/rsyslog/pmsnare.so
```
