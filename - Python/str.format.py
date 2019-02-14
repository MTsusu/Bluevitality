#### 常用输出格式
```python
#注： format 通过 {} 和 : 来代替 %

#参数位置
>>> '{0},{1}'.format('one',2) 
'one,2'
>>> '{1},{0}'.format('one',2)
'2,one'
>>> '{0},{0}'.format('one',2)
'one,one'

#关键字占位
>>> '{name},{age}'.format(name="bluevitality",age="18")
'bluevitality,18'

#对象下标占位
>>> p=["one","two"]             
>>> '{x[0]},{x[1]}'.format(x=p) 
'one,two

#调用对象属性
>>> class demo:
...     def __init__(self,name,age):
...             self.name,self.age=name,age
...     def __str__(self):
...             return "this guy is {self.name} is {self.age} old".format(self=self)
... 
>>> test=demo("bluevitality",18)
>>> str(test)
'this guy is bluevitality is 18 old'
```

#### 常用占位方式
```python
#居中    ^
#左对齐  <
#右对齐  >
# ：     填充的字符（只能是一个字符，不指定的话默认是用空格填充）

>>> '{0:>10},{1:1<10}'.format('testa','testb')  #第一个串右对齐并以默认的空格填充，第二个串左对齐并以数字一填充
'     testa,testb11111'

>>> '{0:<10.3f}'.format(314.15926)              #第一个串左对齐10个空格的宽度并指定其小数点精度为3，格式为浮点型
'314.159   '

>>> '{0:b}'.format(256)     #二进制
'100000000'
>>> '{0:d}'.format(256)     #十进制
'256'
>>> '{0:o}'.format(256)     #八进制
'400'
>>> '{0:x}'.format(256)     #十六进制
'100'
```
