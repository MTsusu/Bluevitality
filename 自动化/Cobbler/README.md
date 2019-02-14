```txt
Cobbler使用Python开发，目前实验使用的版本是Cobbler 2.6.11 Released by Jörgen on January 23, 2016
Cobbler通过将设置和管理一个安装服务器所涉及的任务集中在一起，从而简化了系统配置。
其相当于封装了DHCP、TFTP、XINTED、yum仓库等(针对不同版本的源)服务，结合了PXE、kickstart等安装方法......
可实现自动化安装系统，并且可同时提供多种版本以实现在线安装不同版本的系统。
其与PXE安装系统的区别就是可以同时部署多个版本的系统，而PXE只能选择一种系统

交互过程分析：
    cobbler server与裸机（PXE client）交互过程分析：
    裸机配置了从网络启动后，开机后会广播包请求DHCP服务器（cobbler server）发送其分配好的一个IP
    DHCP服务器（cobbler server）收到请求后发送responese，包括其ip地址
    裸机拿到ip后再向cobbler server发送请求OS引导文件的请求
    cobbler server告诉裸机OS引导文件的名字和TFTP server的ip和port
    裸机通过上面告知的TFTP server地址和port通信，下载引导文件
    裸机执行执行该引导文件，确定加载信息，选择要安装的os，期间会再向cobbler server请求kickstart文件和os image
    cobbler server发送请求的kickstart和os iamge
    裸机加载kickstart文件
    裸机接收os image，安装该os image
    之后，裸机就不“裸”了，有了自己的os和dhcp分配给其的ip
```
###### Kickstart.cfg
```txt
自动安装Linux的步骤描述文件...，默认当手动安装完成后在root用户的家目录下有个 anaconda-ks.cfg 文件，即ks文件
```
###### isolinux
```txt
ISO文件内用于安装Linux的/isolinux路径下各文件的作用说明...
```
