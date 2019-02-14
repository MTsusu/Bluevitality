#定义资源，资源名称为："Mysqls"
resource Mysqls {

  	meta-disk internal;			#internal表示将DRBD的元数据保存在磁盘自身

 	#在哪个节点上				   注意!，节点名称需要在/etc/hosts中做映射
	on Mysql1 {
		device   /dev/drbd1;		#DRBD的设备文件名称
		disk     /dev/sda1;		#使用哪个磁盘或分区设备
		address 10.0.0.7:7788;		#当前资源监听在哪个地址上
	}
	
	on Mysql2 {
		device   /dev/drbd1;
		disk     /dev/sda1;
		address 10.0.0.8:7788;
	} 
}


# resource Mysqls {
# 
#  	meta-disk internal;
#	device   /dev/drbd1
#	disk     /dev/sda1;
# 	
# 	on Mysql1 {
# 		address 10.0.0.7:7788;
# 	}
#
# 	on Mysql2 {
# 		address 10.0.0.8:7788;
# 	} 
# }
