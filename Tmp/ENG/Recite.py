# -*- coding: UTF-8 -*-

import os
import sys
import string
import chardet
import subprocess
import threading
import argparse
import platform
import time

def open_file(filename="null"):
    if filename == "null":
        for i in os.listdir(os.getcwd()):       #没指定文件名的时候遍历当前目录以txt结尾的文件
            if i.endswith(".txt"):
                filename=str(i)
    try:
        file=open(filename,"r+")
    except:
        print "not exist"
    return file

def wait(word):
    v=str(raw_input())
    if v=="1":      #按1并回车后将单词追加到以日期命名的文件中
        try:
            f = open(str(time.strftime('%Y-%m-%d', time.localtime(time.time())))+".txt", 'a+')
            f.write(str(word))
            f.close()
        except e:
            print "Write Error ..."

def echo_line(file,lazy=1):
    f=file
    def echo_format(length=20,high=3):
        print "---" * int(length), "\n" * int(high)
        print " ",line
        print count
        thd=threading.Thread(target=wait,args=(line,))  #在线程中执行wait函数，使其可被主线程跳过执行完成超时
        thd.daemon=True
        thd.start()
        print "\n" * int(high)
    count=1
    for line in f:
        time.sleep(int(lazy))
        count+=1
        if 'Windows' in platform.system():
            x=subprocess.call("cls",shell=True)
            echo_format()
        else:
            x=subprocess.call("clear")
            echo_format()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--filename',help="filename")
    parser.add_argument('-t', '--time',help="lazy time for timeout ...")
    args = parser.parse_args()
    if args.filename:
        if args.time:
            echo_line(open_file(filename=str(args.filename)),lazy=int(args.time))
    exit(0)
