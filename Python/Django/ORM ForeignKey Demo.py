from django.db import models

#Blog表
class Blog(models.Model):
    name = models.CharField(max_length=100)
    tagline = models.TextField()

#Author表
class Author(models.Model):
    name = models.CharField(max_length=50)
    email = models.EmailField()

#Entry表（注：ForeignKey字段的主要功能是维护一对多关系, 以进行关联查询，有外键的表为多的一方，参照的另一方为主键）
class Entry(models.Model):
    blog = models.ForeignKey(Blog, to_field=Blog.id)    #ForeignKey接受1个Model类作参数，默认使用关联对象的主键作为关联到的关联对象的字段
    authors = models.ManyToManyField(Author)
    headline = models.CharField(max_length=255)
    body_text = models.TextField()
    pub_date = models.DateField()
    mod_date = models.DateField()
    n_comments = models.IntegerField()
    n_pingbacks = models.IntegerField()
    rating = models.IntegerField()

#-------------------------------------------------------------------------------------------------
#前向查询：
#若关系模型A包含与模型B关联的关联字段, 模型A的实例可以通过关联字段访问与其关联的模型B的实例:
#使用ForeignKey查询
>>> e = Entry.objects.get(id=2)
>>> e.blog                                              #返回当Entry表中id为2时与其相关的Blog对象
>>> e.blog = some_blog                                  #修改当Entry表中id为2时其Blog对象的值？
>>> e.save()

#Django提供了一种使用双下划线__的查询语法：
>>> Entry.objects.filter(blog__name='Beatles Blog')
#-------------------------------------------------------------------------------------------------
#反向查询：
#被索引的关系模型可访问所有参照它的模型的实例
#如Entry.blog作为Blog的外键，默认Blog.entry_set是包含所有参照Blog的Entry示例的查询集,可用查询集API取出相应实例
>>> b = Blog.objects.get(id=1)
>>> b.entry_set.all()
