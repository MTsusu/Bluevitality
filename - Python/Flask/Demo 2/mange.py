#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 演示flask_script的用法
from flask_script import Manager
from test import app
import sqlite3
from model import User

manger = Manager(app=app)


@manger.command
def hello():
    print('hello world!')


@manger.option('-m', '--mag', dest='msg_val', default='world!')
def hello_world(msg_val):
    print('hello' + msg_val)


# 初始化数据库
@manger.command
def init_db():
    sql = 'create table user (id INT, name TEXT)'
    conn = sqlite3.connect('test.db')
    cursor = conn.cursor()
    cursor.execute(sql)
    conn.commit()
    cursor.close()
    conn.close()


@manger.command
def save():
    user = User(2, 'jike2')
    user.save()


@manger.command
def query():
    users = User.query()
    for user in users:
        print(user)

if __name__ == '__main__':
    manger.run()