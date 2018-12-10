#### 安装
```bash
[root@localhost bin]# pip install --upgrade pip
Requirement already up-to-date: pip in /usr/lib/python2.7/site-packages
[root@localhost bin]# pip install jinja2
Requirement already satisfied: jinja2 in /usr/lib/python2.7/site-packages
Requirement already satisfied: MarkupSafe>=0.23 in /usr/lib64/python2.7/site-packages (from jinja2)
[root@localhost bin]# pip install MarkupSafe
Requirement already satisfied: MarkupSafe in /usr/lib64/python2.7/site-packages
```
#### 变量
```python
>>> from jinja2 import Template
>>> Template('Hello {{ name }}!').render(name="wangyu")
u'Hello wangyu!'     

>>> Template("1+2={{ 1+2 }}").render()
u'1+2=3'

>>> class a:
...     pass
... 
>>> a.var=1
>>> Template("{{ obj.var}}").render(obj=a)
u'1'

>>> Dict={"a":1,"b":2}                                   
>>> Template("Your a: {{ Dict['a'] }}").render(Dict=Dict)
u'Your a: 1'

>>> list=[1,2,3,4,5,6]
>>> Template("""
... {% for item in list %}
...     item: {{ item }}
... {% endfor %}
... """).render(list=list)
u'\n\n\titem: 1\n\n\titem: 2\n\n\titem: 3\n\n\titem: 4\n\n\titem: 5\n\n\titem: 6\n'

# 通过创建一个 Template 的实例，你会得到一个新的模板对象，提供一 个名为 render() 的方法
# 该方法在有字典或关键字参数时调用 扩充模板。字典或关键字参数会被传递到模板，即模板“上下文”
```
#### if & for
```python
>>> from jinja2 import Template
>>> a=[1,2,3,4,5] 
>>> Template("""
... {% if 1 in obj %}
...     True...
... {% endif %}
... """).render(obj=a)
u'\n\n    True...\n'

>>> Template("""
... {% if 1==1 %}
...     123
... {% endif %}
... """).render()
u'\n\n\t123\n'

>>> a=[1,2,3,4,5]     
>>> Template("""      
... {% for i in obj %}
...     {{ i }}       
... {% endfor %}
... """).render(obj=a)
u'\n\n\t1\n\n\t2\n\n\t3\n\n\t4\n\n\t5\n'

>>> """
... {% if kenny.sick %}
... Kenny is sick.
... {% elif kenny.dead %}
... You killed Kenny! You bastard!!!
... {% else %}
... Kenny looks okay --- so far
... {% endif %}

# 在模板中添加变量可用set语句： {% set name='xx' %}
# 解释性语言中的变量类型是运行时确定的，因此这里的变量可以赋任何类型的值。
# 控制语句都放在{% ... %}中，并且有一个语句{% endxxx %}进行结束

# 可以使用with语句来创建一个内部的作用域，将set语句放在其中，这样创建的变量只在with代码块中才有效
>>> """
... {% with foo = 42 %}
... {{ foo }}
... {% endwith %}

# Jinja2中for循环内置常量
  loop.index	  当前迭代的索引（从1开始）
  loop.index0	  当前迭代的索引（从0开始）
  loop.first	  是否是第一次迭代，返回True\/False
  loop.last	    是否是最后一次迭代，返回True\/False
  loop.length	  序列的长度
```

#### Macro
```python
>>> from jinja2 import Template
>>> Template("""
... {% macro input(name, value='', type='text') %} 
...     {{ type }} {{ value }} {{ name }}
... {% endmacro %}
... {{ input("1","2","3") }}
... """).render()
u'\n\n\n\t3 2 1\n'
```

#### 引入
```python
# include 可把一个模板引入到其他模板，类似于把一个模板的代码copy到另外一个模板的指定位置
>>> """
... {% include 'header.html' %}
... Body
... {% include 'footer.html' %}
# 它也支持继承，与Flask相同
```

#### 过滤器
```python
>>> from jinja2 import Template
# 过滤器是通过（|）符号进行使用的，例如：{{ name|length }}：将返回name的长度
# 过滤器相当于是一个函数，把当前的变量传入到过滤器中，然后过滤器根据自己的功能，再返回相应的值之后再将结果渲染到页面

abs(value)：   返回一个数值的绝对值。示例：-1|abs
default(value,default_value,boolean=false)：   如果当前变量没有值，则会使用参数中的值来代替。
  示例：name|default('xiaotuo')——如果name不存在，则会使用xiaotuo来替代。
  boolean=False默认是在只有这个变量为undefined的时候才会使用default中的值，
  如果想使用python的形式判断是否为false，则可以传递boolean=true。也可以使用or来替换。

escape(value)或e：      转义字符，会将<、>等符号转义成HTML中的符号。示例：content|escape或content|e。
first(value)：          返回一个序列的第一个元素。示例：names|first
format(value,*arags,**kwargs)：      格式化字符串。比如：
{{ "%s" - "%s"|format('Hello?',"Foo!") }}     将输出：Helloo? - Foo!
last(value)：          返回一个序列的最后一个元素。示例：names|last。
length(value)：        返回一个序列或者字典的长度。示例：names|length。
join(value,d=u'')：    将一个序列用d这个参数的值拼接成字符串。
safe(value)：    如果开启了全局转义，那么safe过滤器会将变量关掉转义。示例：content_html|safe。
int(value)：     将值转换为int类型。
float(value)：   将值转换为float类型。
lower(value)：   将字符串转换为小写。
upper(value)：   将字符串转换为小写。
replace(value,old,new)：     替换将old替换为new的字符串。
truncate(value,length=255,killwords=False)：   截取length长度的字符串。
striptags(value)：   删除字符串中所有的HTML标签，如果出现多个空格，将替换成一个空格。
trim：               截取字符串前面和后面的空白字符。
string(value)：      将变量转换成字符串。
wordcount(s)：       计算一个长字符串中单词的个数。
```

#### 测试器
```python
>>> from jinja2 import Template
# 测试器主要用来判断一个值是否满足某种类型，语法是：if...is...：

... {% if variable is escaped%}
... value of variable: {{ escaped }}
... {% else %}
... variable is not escaped
... {% endif %}

callable(object)：   是否可调用。
defined(object)：    是否已经被定义了。
escaped(object)：    是否已经被转义了。
upper(object)：      是否全是大写。
lower(object)：      是否全是小写。
string(object)：     是否是一个字符串。
sequence(object)：   是否是一个序列。
number(object)：     是否是一个数字。
odd(object)：        是否是奇数。
even(object)：       是否是偶数。
```
