#crontab进程自动调起（需要使用默认的catalina.sh脚本，生产使用的Tomcat对其进行了修改，增加了cronlog部分）

#/home/rhkf/ngcs/logrotate.conf

/home/<project>/*/tomcat*/logs/*.out {
    #prerotate    在logrotate转储前需执行的指令，例如修改文件的属性等动作；必须独立成行
    #postrotate   在logrotate转储后需执行的指令，例如重新启动 (kill -HUP) 某个服务！必须独立成行
    copytruncate  #用于还在打开中的日志文件，把当前日志备份并截断
    rotate 4      #保留4个备份
    compress      #通过gzip压缩转储后的日志
    delaycompress #总是与compress选项一起用，delaycompress指示logrotate不要将最近的归档压缩，压缩将在下个轮循中进行
    missingok     #如果日志丢失，不报错继续滚动下一个日志
    notifempty    #如果是空文件的话不转储
    size 4096M    #到达指定的大小时才转储
    dateext       #用当前日期作为切割后的文件后缀格式
    dateformat .%s    #必须配合dateext使用，紧跟在下一行出现，定义切割后的文件名，只支持 %Y %m %d %s 四个参数
}

每8小时执行定时任务，8小时若超过4G的catalina.out，则处理，共保存4个文件。
使用‘-f’选项来强制logrotate轮循日志文件（其中第2个文件路径是logrotate自身的日志，用于排障）
# 样例：* */8 * * *  /usr/sbin/logrotate -f /home/<username>/ngcs/logrotate.conf -s /home/<username>/logrotate.stats

