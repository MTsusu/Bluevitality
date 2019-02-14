#### 内核源码：/usr/src/kernels/\<kernel-version-release\>/
```bash
# 若此目录为空，则需安装包：yum -y install kernel-headers kernel-devel
[root@localhost ~]# ll -l /usr/src/kernels/3.10.0-693.5.2.el7.x86_64/
total 4304
drwxr-xr-x.  32 root root    4096 Nov 21 02:53 arch
drwxr-xr-x.   3 root root      74 Nov 21 02:53 block
drwxr-xr-x.   4 root root      72 Nov 21 02:53 crypto
drwxr-xr-x. 117 root root    4096 Nov 21 02:54 drivers
drwxr-xr-x.   2 root root      21 Nov 21 02:54 firmware
drwxr-xr-x.  75 root root    4096 Nov 21 02:54 fs
drwxr-xr-x.  28 root root    4096 Nov 21 02:54 include
drwxr-xr-x.   2 root root      35 Nov 21 02:54 init
drwxr-xr-x.   2 root root      21 Nov 21 02:54 ipc
-rw-r--r--.   1 root root     505 Oct 21 04:59 Kconfig
drwxr-xr-x.  11 root root    4096 Nov 21 02:54 kernel
drwxr-xr-x.  10 root root    4096 Nov 21 02:54 lib
-rw-r--r--.   1 root root   50960 Oct 21 04:59 Makefile
-rw-r--r--.   1 root root    2305 Oct 21 04:59 Makefile.qlock
drwxr-xr-x.   2 root root      55 Nov 21 02:54 mm
-rw-r--r--.   1 root root 1052863 Oct 21 04:59 Module.symvers
drwxr-xr-x.  58 root root    4096 Nov 21 02:54 net
drwxr-xr-x.  13 root root    4096 Nov 21 02:54 samples
drwxr-xr-x.  13 root root    4096 Nov 21 02:54 scripts
drwxr-xr-x.   9 root root    4096 Nov 21 02:54 security
drwxr-xr-x.  23 root root    4096 Nov 21 02:54 sound
-rw-r--r--.   1 root root 3228852 Oct 21 04:59 System.map
drwxr-xr-x.  17 root root    4096 Nov 21 02:54 tools
drwxr-xr-x.   2 root root      35 Nov 21 02:54 usr
drwxr-xr-x.   4 root root      41 Nov 21 02:54 virt
-rw-r-
```
#### Linux Kernel：/boot/vmlinuz-\<kernel-version-release\>.el7.x86_64 
```bash
#"vm"代表 "Virtual Memory" Linux能够使用硬盘空间作为虚拟内存，因此得名"vm"
#vmlinuz是可执行的Linux内核，位于/boot/vmlinuz，它一般是一个软链接... 
#vmlinux是未压缩的内核，vmlinuz是vmlinux的压缩文件。
[root@localhost ~]# ll /boot/vmlinuz-3.10.0-327.el7.x86_64 
-rwxr-xr-x. 1 root root 5156528 Nov 20  2015 /boot/vmlinuz-3.10.0-327.el7.x86_64
[root@localhost ~]# ll /boot
total 75628
-rw-r--r--. 1 root root   126426 Nov 20  2015 config-3.10.0-327.el7.x86_64
drwxr-xr-x. 2 root root       26 Nov 20 06:33 grub
drwx------. 6 root root      104 Dec  6 23:14 grub2
-rw-r--r--. 1 root root 43567908 Nov 20 06:36 initramfs-0-rescue-a0d4da63906a4a5f97671a27a749c0e3.img
-rw-------. 1 root root 19605794 Nov 21 02:53 initramfs-3.10.0-327.el7.x86_64.img
-rw-r--r--. 1 root root   602621 Nov 20 06:34 initrd-plymouth.img
-rw-r--r--. 1 root root   252612 Nov 20  2015 symvers-3.10.0-327.el7.x86_64.gz
-rw-------. 1 root root  2963044 Nov 20  2015 System.map-3.10.0-327.el7.x86_64  #depmpd生成的映射关系的描述
-rwxr-xr-x. 1 root root  5156528 Nov 20 06:36 vmlinuz-0-rescue-a0d4da63906a4a5f97671a27a749c0e3
-rwxr-xr-x. 1 root root  5156528 Nov 20  2015 vmlinuz-3.10.0-327.el7.x86_64

[root@localhost ~]# uname -r        #查看内核版本信息
3.10.0-327.el7.x86_64   
[root@localhost ~]# uname -m        #查看内核硬件平台
x86_64  
[root@localhost ~]# uname -p        #查看处理器类型（架构）
x86_64  
[root@localhost ~]# uname -p        #查看硬件平台
x86_64  
[root@localhost ~]# uname -o        #OS名称
GNU/Linux

#内核的配置文件
[root@localhost ~]# ll /boot/config-3.10.0-327.el7.x86_64 
-rw-r--r--. 1 root root 126426 Nov 20  2015 /boot/config-3.10.0-327.el7.x86_64
[root@localhost ~]# cat /boot/config-3.10.0-327.el7.x86_64 | head
#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.10.0-327.el7.x86_64 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
```
#### Create vmlinuz ...
```txt
vmlinuz的建立有2种方式：

    一，编译内核时通过"make zImage"创建，然后通过下面代码产生： 
        cp /usr/src/linux-2.4/arch/i386/linux/boot/zImage /boot/vmlinuz
        zImage适用于小内核的情况，它的存在是为了向后的兼容性
        
    二，内核编译时通过命令make bzImage创建，然后通过下面代码产生： 
        cp /usr/src/linux-2.4/arch/i386/linux/boot/bzImage /boot/vmlinuz 
        bzImage是压缩的内核映像，注意bzImage不是bzip2压缩的，名字中的bz易误解，bz表示"big zImage"

Notice 1 
    zImage（vmlinuz）和bzImage（vmlinuz）都是用gzip压缩的。
    它们不仅是一个压缩文件，而且在这两个文件的开头部分内嵌有gzip解压缩代码。所以不能用gunzip 或 gzip –dc解包vmlinuz。
    
Notice 2 
    内核文件中包含一个微型的gzip用于解压缩内核并引导它。
    两者的不同之处在于，老的zImage解压缩内核到低端内存（第一个640K）
    bzImage解压缩内核到高端内存（1M以上）
    如果内核比较小则可采用zImage或bzImage之一，两种方式引导的系统运行时是相同的。大的内核只能采用bzImage
    
Notice 3 
    vmlinux是未压缩的内核，vmlinuz是vmlinux的压缩文件。 
    例如：vmlinux-2.4.20-8是未压缩内核，vmlinuz-2.4.20-8是vmlinux-2.4.20-8的压缩文件。
```

#### 内核模块：/lib/modules/\<kernel-version-release\>/
```bash
#Linux内的设备驱动程序可以方便地以模块化（modularize）形式设置，并在系统运行期间可直接装载或卸载。
[root@localhost ~]# ls -l /lib/modules/3.10.0-327.el7.x86_64/
total 2704
lrwxrwxrwx.  1 root root     38 Nov 20 06:33 build -> /usr/src/kernels/3.10.0-327.el7.x86_64
drwxr-xr-x.  2 root root      6 Nov 20  2015 extra
drwxr-xr-x. 11 root root   4096 Nov 20 06:33 kernel
-rw-r--r--.  1 root root 705037 Nov 20 06:36 modules.alias
-rw-r--r--.  1 root root 681768 Nov 20 06:36 modules.alias.bin
-rw-r--r--.  1 root root   1288 Nov 20  2015 modules.block
-rw-r--r--.  1 root root   5995 Nov 20  2015 modules.builtin
-rw-r--r--.  1 root root   7744 Nov 20 06:36 modules.builtin.bin
-rw-r--r--.  1 root root 218218 Nov 20 06:36 modules.dep        #描述了模块之间的依赖关系
-rw-r--r--.  1 root root 316220 Nov 20 06:36 modules.dep.bin    #二进制方式供程序查询使用...
-rw-r--r--.  1 root root    339 Nov 20 06:36 modules.devname
-rw-r--r--.  1 root root    108 Nov 20  2015 modules.drm
-rw-r--r--.  1 root root    100 Nov 20  2015 modules.modesetting
-rw-r--r--.  1 root root   1522 Nov 20  2015 modules.networking
-rw-r--r--.  1 root root  84666 Nov 20  2015 modules.order
-rw-r--r--.  1 root root     89 Nov 20 06:36 modules.softdep
-rw-r--r--.  1 root root 311845 Nov 20 06:36 modules.symbols
-rw-r--r--.  1 root root 387028 Nov 20 06:36 modules.symbols.bin
lrwxrwxrwx.  1 root root      5 Nov 20 06:33 source -> build
drwxr-xr-x.  2 root root      6 Nov 20  2015 updates
drwxr-xr-x.  2 root root     91 Nov 20 06:33 vdso
drwxr-xr-x.  2 root root      6 Nov 20  2015 weak-updates

#   注：
#   []       ...
#   [M]      以模块方式加载(/lib/modules/\<kernel-version-release\>/)
#   [*]      将模块加入内核

#查看/proc/modules
[root@localhost ~]# lsmod | head    #内核已经装载的相关模块，大小，使用次数以及被谁使用的信息...
Module                  Size  Used by
snd_seq_midi           13565  0 
snd_seq_midi_event     14899  1 snd_seq_midi
crc32_pclmul           13113  0 
ghash_clmulni_intel    13259  0 
aesni_intel            69884  0 
lrw                    13286  1 aesni_intel
gf128mul               14951  1 lrw
glue_helper            13990  1 aesni_intel
ablk_helper            13597  1 aesni_intel

#查看模块信息
[root@localhost ~]# modinfo ext4    #-k <kernel>    显示指定内核模块内的模块信息...   
filename:       /lib/modules/3.10.0-327.el7.x86_64/kernel/fs/ext4/ext4.ko   #模块路径!...
license:        GPL
description:    Fourth Extended Filesystem
author:         Remy Card, Stephen Tweedie, Andrew Morton, Andreas Dilger, Theodore Ts'o and others
alias:          fs-ext4
alias:          ext3
alias:          fs-ext3
alias:          ext2
alias:          fs-ext2
rhelversion:    7.2
srcversion:     DB48BDADD011DE28724EB21
depends:        mbcache,jbd2
intree:         Y
vermagic:       3.10.0-327.el7.x86_64 SMP mod_unload modversions 
signer:         CentOS Linux kernel signing key
sig_key:        79:AD:88:6A:11:3C:A0:22:35:26:33:6C:0F:82:5B:8A:94:29:6A:B3
sig_hashalgo:   sha256

#装/卸载模块
[root@localhost ~]# modprobe ext4           #卸载：-r，指定模块的配置文件：-c 
[root@localhost ~]# modprobe -r dm_mirror   #rmmod <xxx> <===> modprobe -r <xxx>
[root@localhost ~]# lsmod | grep dm_mirror
[root@localhost ~]# modprobe dm_mirror
[root@localhost ~]# lsmod | grep dm_mirror
dm_mirror              22135  0 
dm_region_hash         20862  1 dm_mirror
dm_log                 18411  2 dm_region_hash,dm_mirror
dm_mod                113292  8 dm_log,dm_mirror

#内核模块依赖关系文件及系统信息映射文件的生成工具...
[root@localhost ~]# depmod -b /lib/modules/3.10.0-327.el7.x86_64/   #依特定内核版本的模块生成...
```
#### Ramdisk：/boot/initrd-<x.x.x>.img
```bash
#是"initial ramdisk"的简写，initrd映象文件是用'mkinitrd'创建的（此命令是RedHat专有的）
#initrd一般被用来临时的引导硬件到实际内核vmlinuz能够接管并继续引导的状态（用于辅助内核完成根文件系统的加载）
#initrd-2.4.7- 10.img：主要用于加载ext3等文件系统及scsi设备的驱动，可将其理解为超小型的linux
[root@localhost ~]# ll /boot/initr*
-rw-r--r--. 1 root root 43567908 Nov 20 06:36 /boot/initramfs-0-rescue-a0d4da63906a4a5f97671a27a749c0e3.img
-rw-------. 1 root root 19605794 Nov 21 02:53 /boot/initramfs-3.10.0-327.el7.x86_64.img
-rw-r--r--. 1 root root   602621 Nov 20 06:34 /boot/initrd-plymouth.img

#ramdisk的2中形式：
#    1.initrd
#    2.initramfs

#通常，ramdisk是在系统安装过程到最后一步时通过收集当前系统上硬件的相关信息按需创建的（使用：mkinitrd）
#Example：
[root@localhost ~]# rm -rf /boot/initramfs-3.10.0-327.el7.x86_64.img    #此时将无法加载根文件系统
#根据当前主机已经存在的特定的内核版本生成特定路径下的ramdiskfs （还有命令：dracut，其与mkinitrd格式相同!）
[root@localhost ~]# mkinitrd /boot/initramfs-$(uname -r).img $(uname -r) [--with=<module>]

#Research demo
[root@localhost boot]# mv initramfs-3.10.0-327.el7.x86_64.img  initramfs-3.10.0-327.el7.x86_64.img.gz
[root@localhost boot]# gzip -d initramfs-3.10.0-327.el7.x86_64.img.gz 
[root@localhost boot]# file initramfs-3.10.0-327.el7.x86_64.img 
initramfs-3.10.0-327.el7.x86_64.img: ASCII cpio archive (SVR4 with no CRC)
[root@localhost boot]# mkdir tmp && cd tmp
[root@localhost tmp]# cpio -id < ../initramfs-3.10.0-327.el7.x86_64.img 
87848 blocks
[root@localhost tmp]# ll
total 8
lrwxrwxrwx.  1 root root    7 Dec  8 07:29 bin -> usr/bin
drwxr-xr-x.  2 root root   42 Dec  8 07:29 dev
drwxr-xr-x. 12 root root 4096 Dec  8 07:29 etc
lrwxrwxrwx.  1 root root   23 Dec  8 07:29 init -> usr/lib/systemd/systemd
lrwxrwxrwx.  1 root root    7 Dec  8 07:29 lib -> usr/lib
lrwxrwxrwx.  1 root root    9 Dec  8 07:29 lib64 -> usr/lib64
drwxr-xr-x.  2 root root    6 Dec  8 07:29 proc
drwxr-xr-x.  2 root root    6 Dec  8 07:29 root
drwxr-xr-x.  2 root root    6 Dec  8 07:29 run
lrwxrwxrwx.  1 root root    8 Dec  8 07:29 sbin -> usr/sbin
-rwxr-xr-x.  1 root root 3117 Dec  8 07:29 shutdown
drwxr-xr-x.  2 root root    6 Dec  8 07:29 sys
drwxr-xr-x.  2 root root    6 Dec  8 07:29 sysroot
drwxr-xr-x.  2 root root    6 Dec  8 07:29 tmp
drwxr-xr-x.  7 root root   61 Dec  8 07:29 usr
drwxr-xr-x.  2 root root   27 Dec  8 07:29 var

```
#### 引导文件：/boot/grub2/grub.cfg
```bash
#grub.conf是grub的主配置文件，通过它grub才能正确的找到kernel，因此系统才能正常启动...
#grub2采用模块化设计，主配置文件是/boot/grub2/grub.cfg，默认不允许修改它而是修改其他配置最后通过grub-mkconfig重新生成
#旧版本的grub命名为GRUB Legacy...
[root@localhost ~]# ll /etc/grub2.cfg 
lrwxrwxrwx. 1 root root 22 Nov 20 06:33 /etc/grub2.cfg -> ../boot/grub2/grub.cfg

[root@localhost ~]# cat  /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
GRUB_DISABLE_RECOVERY="true
[root@localhost ~]# ll /etc/grub.d/
total 72
-rwxr-xr-x. 1 root root  8702 Nov 24  2015 00_header
-rwxr-xr-x. 1 root root   992 May  4  2015 00_tuned
-rwxr-xr-x. 1 root root   230 Nov 24  2015 01_users
-rwxr-xr-x. 1 root root 10232 Nov 24  2015 10_linux
-rwxr-xr-x. 1 root root 10275 Nov 24  2015 20_linux_xen
-rwxr-xr-x. 1 root root  2559 Nov 24  2015 20_ppc_terminfo
-rwxr-xr-x. 1 root root 11169 Nov 24  2015 30_os-prober
-rwxr-xr-x. 1 root root   214 Nov 24  2015 40_custom
-rwxr-xr-x. 1 root root   216 Nov 24  2015 41_custom
-rw-r--r--. 1 root root   483 Nov 24  2015 README

#若上述文件经过修改，则需要重新下发到/boot/grub2/grub.cfg
[root@localhost ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-327.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-a0d4da63906a4a5f97671a27a749c0e3
Found initrd image: /boot/initramfs-0-rescue-a0d4da63906a4a5f97671a27a749c0e3.img
done
```
#### 描述内核运行状态的伪文件系统：/proc  
```bash
#sysctl用于查看(-a)和设置(-w)内核运行时的一些参数
[root@localhost ~]# ll /proc/1/exe 
lrwxrwxrwx. 1 root root 0 Dec  8 05:13 /proc/1/exe -> /usr/lib/systemd/systemd
[root@localhost ~]# ll /proc/fs
total 0
dr-xr-xr-x. 2 root root 0 Dec  8 06:56 ext4
dr-xr-xr-x. 2 root root 0 Dec  8 06:56 jbd2
dr-xr-xr-x. 2 root root 0 Dec  8 06:56 nfsd
dr-xr-xr-x. 2 root root 0 Dec  8 06:56 xfs
[root@localhost ~]# ll /proc/mounts 
lrwxrwxrwx. 1 root root 11 Dec  8 06:56 /proc/mounts -> self/mounts
[root@localhost ~]# cat /proc/sys/kernel/hostname 
localhost
[root@localhost ~]# sysctl -w kernel.hostname="tets"
kernel.hostname = tets
[root@localhost ~]# cat /proc/sys/kernel/hostname   
tets
[root@localhost ~]# echo 'kernel.hostname="Linux"' >> /etc/sysctl.conf 
[root@localhost ~]# sysctl -p
kernel.hostname = "Linux"
[root@localhost ~]# cat /proc/sys/kernel/hostname                      
"Linux"
```
#### 内核识别的各硬件相关的属性信息：/sys
```
#Sysfs文件系统是一个类似于proc文件系统的特殊文件系统
#用于将系统中的设备组织成层次结构并向用户模式程序提供详细的内核数据结构信息。
#其实就是在用户态可通过对sys文件系统的访问来看内核态的一些驱动或设备等...
#udev（用户空间）通过此"/sys"路径下对应的设备文件输出的信息动态的为各个设备创建所需要的设备文件到"/dev"路径下!
[root@localhost sys]# tree /sys -d -L 1 
/sys
|-- block
|-- bus
|-- class
|-- dev
|-- devices
|-- firmware
|-- fs
|-- hypervisor
|-- kernel
|-- module
`-- power

#udev的规则文件所在
[root@localhost ~]# ll /etc/udev/rules.d/
total 8
-rw-r--r--. 1 root root 709 Nov 20  2015 70-persistent-ipoib.rules
-rw-r--r--. 1 root root 161 Nov 21 02:53 90-eno-fix.rules
[root@localhost ~]# ls /usr/lib/udev/rules.d/ | head
10-dm.rules
11-dm-lvm.rules
13-dm-disk.rules
40-redhat.rules
42-usb-hid-pm.rules
50-udev-default.rules
60-alias-kmsg.rules
......（略）
```
