#无参装饰器
>>> def log(func):
...     def wrapper(*args,**kw):
...         print "str..."
...         return func(*args,**kw)
...     return wrapper
...
>>> @log
... def function(x,y):
...     print x*y
...
>>> function(10,10)
str...
100


# ---------------------------------------------------
#带参装饰器
>>> def log(argument):
...     def wrapper_func(func):
...         def wrapper_args(*args,**kw):
...             print argument
...             return func(*args,**kw)
...         return wrapper_args
...     return wrapper_func
...
>>> @log('Testing...')
... def function(x,y):
...     print x*y
...
>>> function(10,10)
Testing...
100

#---------------------------------------------------
#在类的外部定义一个针对类的装饰器对类方法进行装饰并使其能够调用类中的其他方法

>>> def catch_exception(func):
...     def wrapper(self, *args, **kwargs):             #多了self
...             try:
...                 return func(self, *args, **kwargs)  #多了self
...             except Exception:                       #不用顾虑，直接调用原来的类的方法
...                 self.revive()
...                 return 'an Exception raised.'
...     return wrapper
...
>>> class Test(object):
...
...     def __init__(self):
...             pass
...
...     def revive(self):
...             print("revive from exception.")
...             # do something to restore
...
...     @catch_exception
...     def read_value(self):
...             print('here I will do something.')
...             #do someting
