#### chattr，lsattr
```bash
# -：     在原有设定基础上移除参数
# =：     设为指定参数
# A：     文件或目录的 atime不可被修改, 可有效预防例如手提电脑磁盘I/O错误的发生
# S：     硬盘I/O同步选项，类似sync。
# a：     即append，只能向文件中添加数据而不能删除，多用于服务器日志文件安全
# c：     即compresse，文件是否经压缩后再存储。读取时需要经过自动解压操作
# d：     即no dump，文件不能成为dump程序的备份目标
# i：     设定文件不能被删除、改名、设定链接关系，同时不能写入或新增内容
# j：     即journal，设定此参数使得当通过mount参数：data=ordered 或者 data=writeback 
#         挂载的文件系统，文件在写入时会先被记录(在journal中)。
#         如果filesystem被设定参数为data=journal，则该参数自动失效。
# s：     保密性地删除文件或目录，即硬盘空间被全部收回。
# u：     与s相反，当设定为u时，数据内容其实还存在磁盘中，可以用于undeletion.

#Example
[root@localhost ~]# chattr +i +a msmtp-1.4.31.tar.bz2 
[root@localhost ~]# lsattr msmtp-1.4.31.tar.bz2 
----ia---------- msmtp-1.4.31.tar.bz2
```
#### setfacl，getfacl
```bash
[root@localhost ~]# setfacl -h
setfacl 2.2.51 -- set file access control lists
Usage: setfacl [-bkndRLP] { -m|-M|-x|-X ... } file ...
  -m, --modify=acl        modify the current ACL(s) of file(s)
  -M, --modify-file=file  read ACL entries to modify from file
  -x, --remove=acl        remove entries from the ACL(s) of file(s)
  -X, --remove-file=file  read ACL entries to remove from file
  -b, --remove-all        remove all extended ACL entries
  -k, --remove-default    remove the default ACL
      --set=acl           set the ACL of file(s), replacing the current ACL
      --set-file=file     read ACL entries to set from file
      --mask              do recalculate the effective rights mask
  -n, --no-mask           don't recalculate the effective rights mask
  -d, --default           operations apply to the default ACL
  -R, --recursive         recurse into subdirectories
  -L, --logical           logical walk, follow symbolic links
  -P, --physical          physical walk, do not follow symbolic links
      --restore=file      restore ACLs (inverse of `getfacl -R')
      --test              test mode (ACLs are not modified)
  -v, --version           print version and exit
  -h, --help              this help text
  
#对用户设置权限
[root@localhost ~]# setfacl -m u:username:rw-  test.txt 
[root@localhost ~]# setfacl -m d:u:username:rw-  test/  #针对目录

#对组设置权限
[root@localhost ~]# setfacl -m g:group:r-- test.txt
[root@localhost ~]# setfacl -m d:g:group:r-- test/

#查看权限
[root@localhost ~]# getfacl  filename/directory　　     #文件或目录名

#添加FS的ACL权限
[root@localhost ~]# vim /etc/fstab
/dev/mapper/centos-root /      xfs     defaults,acl       0 0
```
