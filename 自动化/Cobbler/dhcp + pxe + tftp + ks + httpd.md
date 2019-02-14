###### 本环境下部署的系统版本为： CentOS Linux release 7.2.1511 (Core) 
#### 配置DHCP提供给PXE端引导文件的TFTP服务地址，及TFTP服务器上的PXE文件名
```bash
# PXE：预引导执行环境（允许客户端启动后通过网络对DHCP指定的TFTP地址进行引导文件的加载）
# 注： DHCP服务器上的网卡地址需要手工修改网卡配置文件来指定（固定，不要用vmware的NET8，新建一个NET并取消DHCP）...

[root@localhost ~]# setenforce 0 && systemctl stop firewalld 
[root@localhost ~]# yum -y install dhcp
[root@localhost ~]# cat /etc/dhcp/dhcpd.conf
subnet 192.168.5.0 netmask 255.255.255.0 {
  range 192.168.5.2 192.168.5.250;
  default-lease-time 600;
  max-lease-time 7200;
  filename "pxelinux.0";            #PXE引导文件（由syslinux提供 "yum install syslinux" 此文件仅针对其所在平台）
  next-server 192.168.5.1;          #引导文件所在服务器地址
}
[root@localhost ~]# systemctl start dhcpd && systemctl enable dhcpd
[root@localhost ~]# netstat -atupnl | grep dhcp
udp        0      0 0.0.0.0:26300           0.0.0.0:*                 2250/dhcpd          
udp        0      0 0.0.0.0:67              0.0.0.0:*                 2250/dhcpd          
udp6       0      0 :::46281                :::*                      2250/dhcpd   
```
#### 服务端设置
```bash
[root@localhost ~]# yum -y install xinetd tftp-server syslinux system-config-kickstart httpd
[root@localhost ~]# cat /etc/xinetd.d/tftp
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot          #TFTP的默认根路径 /var/lib/tftpboot
        disable                 = no                            #改为no
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
[root@localhost ~]# chmod  777 /var/lib/tftpboot
[root@localhost ~]# systemctl start tftp.socket && systemctl enable tftp.socket
[root@localhost ~]# systemctl start tftp.service && systemctl enable tftp.service
[root@localhost ~]# systemctl start httpd && systemctl enable httpd
[root@localhost ~]# systemctl start xinetd && systemctl enable xinetd
[root@localhost ~]# mount -t auto /dev/cdrom /mnt/cdrom/                    #挂载IOS光盘

[root@localhost ~]# cp /mnt/cdrom/isolinux/isolinux.cfg /var/lib/tftpboot/  #引导菜单配置文件
[root@localhost ~]# cp /mnt/cdrom/isolinux/splash.png /var/lib/tftpboot/    #GRUB背景图片
[root@localhost ~]# cp /mnt/cdrom/isolinux/{vmlinuz,initrd.img} /var/lib/tftpboot/  #内核与ramdisk
[root@localhost ~]# cp /mnt/cdrom/isolinux/boot.msg /var/lib/tftpboot/      #提示信息，在菜单之前出现，时间较短
[root@localhost ~]# cp /mnt/cdrom/isolinux/vesamenu.c32 /var/lib/tftpboot/  #系统自带的两种窗口模块之一
[root@localhost ~]# cp /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
[root@localhost ~]# cp /usr/share/syslinux/chain.c32 /var/lib/tftpboot/
[root@localhost ~]# cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot     #相当于bootloader
[root@localhost ~]# mkdir -p /var/lib/tftpboot/pxelinux.cfg                 #新建 pxelinux.cfg 目录（不是文件）
[root@localhost ~]# ll /var/lib/tftpboot/
-r--r--r--.  1  root  root        84 1月   14 08:00  boot.msg
-rw-r--r--.  1  root  root     20704 1月   14 08:01  chain.c32
-r--r--r--.  1  root  root  38508192 1月   14 08:00  initrd.img
-r--r--r--.  1  root  root      3032 1月   14 08:00  isolinux.cfg
-rw-r--r--.  1  root  root     55012 1月   14 08:01  menu.c32
-rw-r--r--.  1  root  root     26764 1月   14 08:01  pxelinux.0
drwxr-xr-x.  2  root  root         6 1月   14 08:01  pxelinux.cfg
-r--r--r--.  1  root  root       186 1月   14 08:00  splash.png
-r--r--r--.  1  root  root    153104 1月   14 08:00  vesamenu.c32
-r-xr-xr-x.  1  root  root   5156528 1月   14 08:00  vmlinuz

[root@localhost ~]# chmod 777 -R /var/lib/tftpboot/pxelinux.cfg
[root@localhost ~]# chmod 777 /var/lib/tftpboot/pxelinux.0
[root@localhost ~]# chmod 777 /var/www/html
[root@localhost ~]# mkdir -p /var/www/html/Centos7
[root@localhost ~]# cp -r /mnt/cdrom/* /var/www/html/Centos7     #CentOS7的ISO (在ks文件中标记从此处"HTTP/FTP"载入)
[root@localhost ~]# cp ~/anaconda-ks.cfg /var/www/html/Centos7/ks.cfg
[root@localhost ~]# vim /var/www/html/Centos7/ks.cfg
# 注： http:/Host:Port/Path/ks.cfg 
# 本文件中要有 'url --url="http://192.168.5.1/Centos7/"' 使其从网络进行安装

#验证ks文件正确性（此处没有ks.cfg的文档，请参考本URL下的：Kickstart.cfg，务必在/var/www/html/下放置ks.cfg..）
[root@localhost ~]# ksvalidator /var/www/html/Centos7/ks.cfg
[root@localhost ~]# # cp /var/lib/tftpboot/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default  #此步骤跳过（BUG）
[root@localhost ~]# vim /var/lib/tftpboot/pxelinux.cfg/default    #直接编辑如下信息，指定ks文件地址...
default linux
prompt 1
timeout 10
display boot.msg
label linux
  kernel vmlinuz
  append initrd=initrd.img text ks=http://192.168.5.1:80/Centos7/ks.cfg

[root@localhost ~]# chmod 644 /var/lib/tftpboot/pxelinux.cfg/default
```
#### 客户端
`进入BIOS开启网卡的PXE功能后重启即可`
