#!/usr/bin/python             
# -*- coding: UTF-8 -*-

import time
import os
import multiprocessing
from random import random
from multiprocessing import cpu_count

CPU_NUMBERS=cpu_count() #CPU核心数量
SECURITY_LOAD_LEVEL=float(CPU_NUMBERS * 0.5)  #保持在负载安全阈值

print "this cpu numbers:" + str(CPU_NUMBERS)  #主机CPU数
print "my pid:" + str(os.getpid())            #PID

#获取主机1分钟负载信息
def get_load():
    f = open("/proc/loadavg")
    loadstate=f.read().split()
    return loadstate[0]

#跑起来
def Oh(x):
    while True:
        if float(get_load()) >= SECURITY_LOAD_LEVEL:  #当负载高于安全阈值执行Sleep
            time.sleep(0.01)
            continue
        print "cpu numbers:" + str(float(CPU_NUMBERS * 0.5))
        print "Load" + str(get_load())
        '''pass    #空转'''
        hits=0
        for i in range(1,1000*1000+1):  #计算圆周率
            x,y=random(),random()
            dist=pow(x**2+y**2,0.5)
            if dist <=1.0:
                hits=hits+1

if __name__ == '__main__':
    record = []
    for i in range(int(CPU_NUMBERS)): #Fork出与CPU核心数相同的进程开始吃CPU
        p=multiprocessing.Process(target=Oh,args=(str(i)))
        p.start()
        record.append(p)
    for i in record:
        p.join()
