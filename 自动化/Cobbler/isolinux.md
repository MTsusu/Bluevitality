#### CentOS7的安装启动流程
1. 先读光盘的取MBR：/isolinux/boot.cat
2. 加载引导文件：/isolinux/isolinux.bin & isolinux.cfg
3. 加载光盘内核：/isolinux/vmlinuz  ( 向内核传递参数：append initrd=initrd.img ... )
4. 加载initrd文件.....
5. 装载anaconda应用程序，调用其GUI进行安装(文本窗口"tui"基于：curses)

#### 安装光盘内的：/ISOLinux 下的文件
```bash
[root@localhost ~]# mkdir -p /mnt/cdrom
[root@localhost ~]# mount -t auto /dev/cdrom /mnt/cdrom
mount: /dev/sr0 写保护，将以只读方式挂载
[root@localhost ~]# cd /mnt/cdrom/
[root@localhost cdrom]# ll
总用量 106
-rw-rw-r--. 3 root root    14 9月   5 21:25 CentOS_BuildTag
drwxr-xr-x. 3 root root  2048 9月   5 21:36 EFI
-rw-rw-r--. 3 root root   227 8月  30 22:33 EULA
-rw-rw-r--. 3 root root 18009 12月 10 2015 GPL
drwxr-xr-x. 3 root root  2048 9月   5 21:46 images
drwxr-xr-x. 2 root root  2048 9月   5 21:36 isolinux         #类似于光盘的安装程序专用目录
drwxr-xr-x. 2 root root  2048 9月   5 21:36 LiveOS
drwxrwxr-x. 2 root root 69632 9月   5 21:38 Packages
drwxr-xr-x. 2 root root  4096 9月   5 21:40 repodata
-rw-rw-r--. 3 root root  1690 12月 10 2015 RPM-GPG-KEY-CentOS-7
-rw-rw-r--. 3 root root  1690 12月 10 2015 RPM-GPG-KEY-CentOS-Testing-7
-r--r--r--. 1 root root  2883 9月   5 22:14 TRANS.TBL
[root@localhost cdrom]# cd isolinux/                         #在此目录内文件的基础上启动anaconda_GUI安装程序
[root@localhost isolinux]# ll
总用量 53409
-r--r--r--. 1 root root     2048 9月   5 22:14 boot.cat      #类似于MBR的前64字节
-rw-r--r--. 1 root root       84 9月   5 21:36 boot.msg
-rw-r--r--. 1 root root      281 9月   5 21:36 grub.conf     #
-rw-r--r--. 1 root root 48434768 9月   5 21:36 initrd.img    #用于光盘的ramdiskfs
-rw-r--r--. 1 root root    24576 9月   5 21:36 isolinux.bin  #用于引导
-rw-r--r--. 1 root root     3032 9月   5 21:36 isolinux.cfg  #isolinux.bin的配置文件（包括菜单信息）
-rw-r--r--. 1 root root   190896 11月  6 2016 memtest
-rw-r--r--. 1 root root      186 10月  1 2015 splash.png     #背景图片
-r--r--r--. 1 root root     2215 9月   5 22:14 TRANS.TBL
-rw-r--r--. 1 root root   152976 11月  6 2016 vesamenu.c32   #用于显示一个图形窗口
-rwxr-xr-x. 1 root root  5877760 8月  23 05:21 vmlinuz       #用于光盘引导安装的Linux内核所在
[root@localhost isolinux]# cat isolinux.cfg
........
label rescue             #提示符此处为"rescue"，用于菜单编辑界面的调用:boot: rescue initrd=initrd.img
  menu indent count 5                                                               #
  menu label ^Rescue a CentOS system                                                #菜单
  kernel vmlinuz                                                                    #指明内核文件
  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet  #向内核额外传递参数
........
```
#### anaconda & kickstart
```bash
# 两种配置方式：
#       1.通过GUI进行交互式安装
#       2.通过kickstart文件自动安装

# 在Linux启动时的菜单栏对选中的内核ENTER进入Boot提示附后，可设置kickstart文件：
#       光盘：boot: ks=cdrom:/Path/to/kickstart_file
#       硬盘：boot: ks=hd:/Path/to/kickstart_file
#       HTTP：boot: ks=http://Host:Port/Path/to/kickstart_file
#       FTP：boot: ks=ftp://Host:Port/Path/to/kickstart_file

# 每次当系统安装完成以后将自动在root目录下生成"anaconda-ks.cfg"文件（即使用ISO安装本系统时的一些设置的配置保存）
[root@localhost ~]# ll anaconda-ks.cfg 
-rw-------. 1 root root 923 11月 20 06:37 anaconda-ks.cfg
[root@localhost ~]# cat anaconda-ks.cfg 
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
keyboard --vckeymap=cn --xlayouts='cn'
# System language
lang zh_CN.UTF-8

# Network information
network  --bootproto=dhcp --device=eno16777736 --onboot=off --ipv6=auto
network  --hostname=localhost.localdomain

# Root password
rootpw --iscrypted $6$Eaehx8nCGlHIrB39$9LlCHL5FDJz3mCs9JLFeN1Z0xS93dCrnC/BW.....(略)
# System timezone
timezone Asia/Shanghai --isUtc
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

%packages
@^minimal
@compat-libraries
@core
@security-tools

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end
```
#### 检查ks文件语法
```bash 
[root@localhost ~]# yum -y install system-config-kickstart
[root@localhost ~]# ksvalidator ~/anaconda-ks.cfg
```
