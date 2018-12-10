#!/usr/bin/env python
#coding=utf-8

import os,sys
import subprocess
from multiprocessing import Process,Lock,Queue
import re
import time

#JVM内存溢出关键字
GC_ERROR = str('123321')

#获取JAVA_HOME
JMAP = str(os.getenv('JAVA_HOME'))+'/bin/jmap'

#指定路径内搜索Tomcat的日志文件
def scan_log(PATH):
	for FILENAME in os.listdir(PATH):
		FILEPATH = os.path.join(PATH, FILENAME)
		if os.path.isfile(FILEPATH):
            		#日志必须是 catalina.yyyy-mm-dd.log 结尾，否则不录入
			if not str(FILENAME).endswith(str(DATE)+".log"):
				continue
			else:
				Q.put(str(FILEPATH))
				print "加入队列的文件名",FILEPATH 
				print "队列大小",Q.qsize()
		elif os.path.isdir(FILEPATH):
			scan_log(FILEPATH)

#扫描所有日志文件内的关键字并在匹配后重启服务
def monitor_log():
	if not Q.empty():
		L.acquire()
		F = Q.get()
		L.release()
	else:
		return
	print "队列中读取的文件名",F
	print "读取后队列大小",Q.qsize()
	#实时读取日志的最后一行进行匹配
	popen = subprocess.Popen('tail -2f '+F,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
	#print "当前进程监听：%s" %(F)
	MATCH = re.compile(GC_ERROR)
		
	while True:	
		LINE=popen.stdout.readline().strip()
		new_line=MATCH.search(LINE.lower())

		#动作，这里重启TOMCAT（根据grep匹配的patterng关键字进行kill操作） 
		if new_line:
			print "OK!"
			time.sleep(0.1)
			#ps -ef | grep <路径中"logs"左边的部分>     
			pattern='logs/(.*?)$'
			out = re.sub(pattern,'',F)
			PID = os.popen("ps -ef | grep %s | grep bin/java | awk '{print $2}'" %(out)).read() #获取PID，需要KILL
			
			# DUMP_HEAP + STOP + START
			DUMP_HEAP = u"%s -dump:format=b,file=%slogs/%s_hprof  %s" %(JMAP,out,DATE,PID)
			STOP_COMMAND = u"kill -9 %s" %(PID)
			time.sleep(0.1)
			START_COMMAND = u"bash %sbin/startup.sh" %(out)
            		
			#命令
			print str("heap_info: %slogs/%s_hprof" %(out,DATE))		#记录到日志
			print "DUMP_HEAP: ",DUMP_HEAP
			print "STOP: ",STOP_COMMAND
			print "start: ",START_COMMAND
            		
			#子进程exec
            		subprocess.Popen(str(DUMP_HEAP),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            		subprocess.Popen(str(STOP_COMMAND),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            		subprocess.Popen(str(START_COMMAND),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

if __name__ == '__main__':
	#检查Jmap命令是否位于$JAVA_HOME/bin下
	if not os.path.isfile(JMAP):
		print ("Jmap command not exist")
		sys.exit(1)
	
	Q = Queue()
	L = Lock()
	
	#当前时间yyyy-mm-dd
	DATE = time.strftime('%Y-%m-%d',time.localtime(time.time()))
	
    	#注意目录名后加'/’
	scan_log("/tmp/tmp/")
	print "队列总大小：",Q.qsize()	

    	#每个进程处理一个日志文件
	process_list = []
	for i in xrange(int(Q.qsize())):
		p = Process(target=monitor_log,args=())
		p.start()
		process_list.append(p)
	for i in process_list:
		i.join()
