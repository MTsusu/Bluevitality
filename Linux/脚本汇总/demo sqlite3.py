#!/usr/bin/env python

import sqlite3

con = sqlite3.connect("lesson.db")    #若不存在则新建数据库
cur = con.cursor()                    #获取数据库游标
sql = "insert into lesson_info values ('%s', '%s','%s','%s','%s','%s')" % (name, link, des, number, time, degree)
cur.execute(sql)                      #执行SQL
con.commit()                          #提交事务



'''
数据库的连接对象，有以下几种操作行为：
1 )、commit()    事务提交
2 )、rollback()  事务回滚
3 )、cursor()    创建游标
4 )、close()     关闭一个连接

在创建了游标之后，它有以下可以操作的方法：
execute()   执行sql语句
scroll()    游标滚动
close()     关闭游标
executemany 执行多条sql语句 
fetchone()  从结果中取一条记录
fetchmany() 从结果中取多条记录
fetchall()  从结果中取出多条记录
'''

#insert
>>> cur.execute("insert into catalog values(0, 0, 'i love python')")
>>> cur.execute("insert into catalog values(1, 0, 'hello world')")
>>> db.commit()

#select
>>> cur.execute("select * from iplaypython")
>>> print cur.fetchall()

#update
>>> cur.execute("update iplaypython set name='happy' where id = 0")
>>> db.commit()
>>> cur.execute("select * from iplaypython")
>>> print cur.fetchone()

#delete
>>> cur.execute("delete from iplaypython where id = 1")
>>> db.commit()
>>> cur.execute("select * from iplaypython")
>>> cur.fetchall()
>>> cur.close()
>>> db.close()

