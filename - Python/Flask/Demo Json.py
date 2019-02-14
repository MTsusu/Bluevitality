#!/usr/bin/env python
# -*- coding:utf-8 -*-

from flask import Flask,json
app = Flask(__name__)
users = ['Linda','Marion5','Race8']

@app.route('/')
def v_index():
    return json.dumps(users),200,[('Content-Type','application/json;charset=utf-8')]    #返回内容，状态码，报文头

app.run(host='0.0.0.0',port=8080)

