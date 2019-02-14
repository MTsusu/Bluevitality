#当我们登录摸一个网站时，输入用户名和密码，如果密码输入错误，点击确定按钮后经常会出现一条提示密码错误的消息。这个消息就是flash消息

# template.html：
#  <form method="POST">                                 #登陆提交的表单
#          {{form.hidden_tag()}}    
#      <p> {{form.name.label}} </p>  
#          {{form.name()}}    
#      <br>
#          {{form.submit }}    
#  </form>    
#  
#  <h6>flashed message</h6>  
#  
#   <p>  
#      {% for message in get_flashed_messages() %}      #展示FLASH()消息
#            {{ message }}  
#      {% endfor %}   
#   </p>  
 
#视图函数中，通过session获取name字段的数值，如果我们两次提交的数值不一致，就是flash一个name has been changed的消息

from flask.ext.wtf import Form  
from wtforms import StringField, SubmitField  
from wtforms.validators import Required  

app = Flask(__name__)  
app.config['SECRET_KEY'] = "a complex string" 

@app.route('/',methods=['GET','POST'])  
def index():  
    form = NameForm()  
    if form.validate_on_submit():  
        old_name=session.get('name')                             #从会话中提取name值
        if old_name is not None and old_name != form.name.data:  #将提取的name与表单的name比较
            flash('name has been changed')     #不同则flash()
            return redirect(url_for('index'))  #返回view function自身的地址(在当前登陆页面提示一个消息)...
        session['name']=form.name.data  
        return render_template('index.html',form=form)  
    return render_template('index.html',form=form)  
    
    
