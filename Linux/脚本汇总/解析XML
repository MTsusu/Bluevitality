#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
from xml.dom.minidom import parse
import xml.dom.minidom
 
DOMTree = xml.dom.minidom.parse("server.xml")
collection = DOMTree.documentElement

#SHUTDOWN PORT
print collection.getAttribute("port"),collection.getAttribute("shutdown")
 
 
x = collection.getElementsByTagName.("Connector")   #获取子集[0]
for i in x:
    print i.getAttribute("port"),i.getAttribute("portocol")
    print i.getAttribute("port"),i.getAttribute("portocol")
