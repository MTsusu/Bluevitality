#coding=utf8
import IPy
import string
import re

def transp():
    q=raw_input("format-> netbit/length :")
    ip=IPy.IP(str(q))
    print "IP段数量为：",ip.len()
    address=re.findall(r'\d+.\d+.\d+.\d+',q)[0]
    print address
    print "二进制格式为：",IPy.IP(str(address)).strBin()
    print "*"*30
    for x in ip:
            print x

transp()
