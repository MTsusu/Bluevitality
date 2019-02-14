#### View function
```python
app = Flask(__name__)  
app.config['SECRET_KEY'] = "a complex string"  

from flask.ext.wtf import Form  
from wtforms import StringField, SubmitField  
from wtforms.validators import Required  
  
class loginForm(Form):  
    username = StringField(label=u"NAME:",  validators = [DataRequired()]) 
    password = StringField(label=u"PASS:",  validators = [DataRequired()]) 
    submit = SubmitField('Submit')

@app.route('/', methods=['GET','POST'])  
def index():  
    form = loginForm()                #表单类实例  
    if form.validate_on_submit():     #如果验证通过  
        name = form.name.data         #获取表单name字段的值给name
        form.name.data = ''
    return render_template('index.html', form = form)  
    
```
#### Template model
```python
<h1> Login <h1>
<form method="post" action="...">  
    {{ form.username.label }} 
    {{ form.username() }}
    {{ form.password.label }}
    {{ form.password() }}
    {{ form.name.label }} {{ form.name() }}  
    {{ form.submit() }}  
</form>  
```
#### Example
```python
#表单代码
from flask_wtf import Form
from wtforms import StringField, BooleanField, PasswordField,SubmitField
from wtforms.validators import DataRequired
 
class LoginForm(Form):
    openid = StringField('openid', validators=[DataRequired()])
    remember_me = BooleanField('remember_me', default = False)
    password = PasswordField('password',validators=[DataRequired()])
    submit = SubmitField('submit')


#表单对应的HTML：
<input id="openid" name="openid" type="text" value="">
<input id="remember_me" name="remember_me" type="checkbox" value="y">
<input id="password" name="password" type="password" value="">
<input id="submit" name="submit" type="submit" value="submit">
```

#### 域类型及其验证其
```txt
域：
StringField                 文本
TextAreaField               多行文本
PasswordField               密码类文本
HiddenField                 隐藏文本
DateField                   接收给定格式的 datetime.datevalue 的文本
DateTimeField               接收给定格式的 datetime.datetimevalue 的文本T
IntegerField                接收整数的文本
DecimalField                接收decimal.Decimal类型值的文本
FloatField                  接收浮点类型值的文本
BooleanField                选是否的复选框
RadioField                  包含多个互斥选项的复选框
SelectField                 下拉菜单
SelectMultipleField         可多选的下拉菜单
FileField                   文件上传
SubmitField                 提交
FormField                   讲一个表单作为域放入另一个表单里
FieldList                   一组给定类型的域

验证器：
Validator                   Description
Email                       邮箱格式
EqualTo                     比较两个域的值，例如在要求输入两次密码的时候
IPAddress                   IPv4 地址
Length                      按字符串的长度验证
NumberRange                 输入数字需在某范围内
Optional                    允许不填，不填的时候就忽略其他验证器
Required                    必填
Regexp                      通过一个正则表达式验证
URL                         URL格式
AnyOf                       属于一组可能值中的一个 
NoneOf                      不属于一组可能值中的任何一个
```
