# Example 1
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root@localhost/test'
db = SQLAlchemy(app)

class User(db.Model):
	
	id = db.Column(db.Integer,primary_key=True)
	username = db.Column(db.String(32),unique=True)
	password = db.Column(db.String(32))
	
	def __init__(self,username,password):
		self.username = username
		self.password = password
		
	def add(self):
		try:
			db.session.add(self)
			db.session.commit()
			return self.id
		except Exception,e:
			db.session.rollback()
			return e
		finally:
			return 0
		
	def isExisted(self):
		temUser=User.query.filter_by(username=self.username,password=self.password).first()
		if temUser is None:
			return 0
		else:
			return 1


# Example 2
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer,primary_key=True)
    username = db.Column(db.String(64),unique=True,index=True)

    role_id = db.Column(db.Integer,db.ForeignKey('roles.id'))
    #就是User类中添加了一个role_id变量，数据类型db.Integer,第二个参数指定外键是哪个表中的哪个id
    #ForeignKey的参数是Role类中__tablename__的值与此表的id

class Role(db.Model):
    __tablename__ = 'roles'
    id = db.Column(db.Integer,primary_key=True)
    name = db.Column(db.String(64),unique=True)

    users = db.relationship('User',backref='role')	#一对多
#这句话比较复杂，仔细读下面的话：
#添加到Role模型中的users属性代表这个关系的面向对象视角。对于一个Role类的实例，其users属性将返回与角色相关联的用户组成的列表
#db.Relationship()    (注：relationship的参数是其多的一方的类名)
#第1个参数表明这个关系的另一端是哪个模型（类）。如果模型类尚未定义可使用字串形式指定。
#第2个参数backref将向User类中"偷偷的"添加role属性从而定义反向关系。这属性可替代role_id访问Role模型，此时获取的是模型对象而不是外键的值

# Example 3 一对一关系
# Role表
class Role(db.Model):
    id=db.Column(db.Integer,primary_key=True)
    name=db.Column(db.String(80))

# RoleType表
class Role_type(db.Model):
    query_class=Common_list_name_Query
    id=db.Column(db.Integer,primary_key=True)
    name=db.Column(db.String(120))

#一对一，只需要在属性里改变下定义
# Role表
class Role(db.Model):
    role_type_id=db.Column(db.Integer,db.ForeignKey('role_type.id'))
	
role=db.relationship('Role',backref='role_type',lazy='dynamic', uselist=False)

# Example 4 一对多关系
# Role表
class Role(db.Model):
    id=db.Column(db.Integer,primary_key=True)
    name=db.Column(db.String(80))

# RoleType表
class Role_type(db.Model):
    query_class=Common_list_name_Query
    id=db.Column(db.Integer,primary_key=True)
    name=db.Column(db.String(120))

# 一对多需要在两个表内斗填上相互的关系
class Role(db.Model):
    role_type_id=db.Column(db.Integer,db.ForeignKey('role_type.id')) 	
    # 用于外键的字段，表明这一列的值应该保存指定名称的远程列的值（ForeignKey的参数是Role_type类中__tablename__的值与此表的id）

class Role_type(db.Model):
    roles=db.relationship('Role',backref='role_type',lazy='dynamic')
    #第一个参数为对应参照的类User,第二个参数backref表示给关联的数据库模型添加一个属性（relationship的参数是其多的一方的类名）

#Example：
#例如，如果一个User拥有多个Book，就可以定义一对多关系如下：
class User(Base):
    __tablename__ = 'user'
    id = Column(String(20), primary_key=True)
    name = Column(String(20))
    # 一对多:
    books = relationship('Book')	#relationship的参数是其多的一方的类名	

class Book(Base):
    __tablename__ = 'book'
    id = Column(String(20), primary_key=True)
    name = Column(String(20))
    # “多”的一方的book表是通过外键关联到user表的:（ForeignKey的参数是User类中__tablename__的值与此表的id）
    user_id = Column(String(20), ForeignKey('user.id'))

#当我们查询一个User对象时，该对象的books属性将返回一个包含若干个Book对象的list。
