### 介绍
```python
#有些任务可能事先需要设置，事后做清理工作。对于这种场景Python的with语句提供了一种非常方便的处理方式。
#一个很好的例子是文件处理，你需要获取一个文件句柄，从文件中读取数据然后关闭文件句柄。

#如果不用with，代码如下：
        file = open("/tmp/foo.txt")
        data = file.read()
        file.close()

#这有两个问题。1是可能忘记关闭文件句柄；2是文件读取数据发生异常，没有进行任何处理。下面是处理异常的加强版本：
        file = open("/tmp/foo.txt")
        try:
            data = file.read()
        finally:
            file.close()
            
#虽然这段代码运行良好，但是太冗长了。这时候就是with一展身手的时候了。
#除了有更优雅的语法，with还可以很好的处理上下文环境产生的异常。下面是with版本的代码：
        with open("/tmp/foo.txt") as file:
            data = file.read()

#Python对with的处理还很聪明。基本思想是with所求值的对象必须有一个__enter__()方法和一个__exit__()方法。
```
```python
with open(r'somefileName') as somefile:   #with后面是个表达式，它返回的是一个上下文管理器对象
        for line in somefile:             #使用as可将此结果赋值给某个变量以方便之后操作。
            print line
            # ...more code
            
#使用with后不管with中的代码出现什么错误，都会进行对当前对象进行清理工作
#例如file的file.close()方法，无论with中出现任何错误，都会执行file.close()方法
```

### 说明
with只有特定场合下才能使用，这个特定场合指的是那些支持了上下文管理器的对象  
比如：  
* file  
* decimal.Context  
* thread.LockType  
* threading.Lock  
* threading.RLock  
* threading.Condition  
* threading.Semaphore  
* threading.BoundedSemaphore  

### 什么是上下文管理器

这个管理器就是在对象内实现了两个方法：**__enter__()** 和 **__exit__()**
* __enter__() 在with的代码块执行之前执行  
* __exit__()  在代码块执行结束后执行( 内部会包含当前对象的清理方法 )  
上下文管理器可以自定义，也可以重写__enter__()和__exit__()方法  

with语句类似  
　　try:  
　　except:  
　　finally:  
的功能：但是with语句更简洁。而且更安全。代码量更少。  

### Example
```python
#实现一个类，其含有一个实例属性 db 和上下文管理器所需要的方法 __enter()__ 和 __exit()__ 
class transaction(object):
  def __init__(self, db):
    self.db = db

  def __enter__(self):
    self.db.begin()

  def __exit__(self, type, value, traceback):
    if type is None:
      db.commit()
    else:
      db.rollback()
```
