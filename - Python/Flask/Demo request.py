#request 就是 request context。当 HTTP 请求过来的时候进入这个上下文

#Example 1
from flask import Flask
from flask import render_template, redirect,url_for
from flask import request

app = Flask(__name__)

@app.route('/login', methods=['POST','GET'])
def login():
    error = None
    if request.method == 'POST':                                                #判断请求方法
        if request.form['username']=='admin':                                   #比较提交的表单数据
            return redirect(url_for('home',username=request.form['username']))  #返回视图函数的URL（?username=value的形式或/xxx/username）
        else:
            error = 'Invalid username/password'
    return render_template('login.html', error=error)

@app.route('/home')
def home():
    return render_template('home.html', username=request.args.get('username'))  #在返回的模板中获取GET的参数传给变量username

if __name__ == '__main__':
    app.debug = True
    app.run('0.0.0.0',80)

#Example 2
#下面的示例在访问首页 / 时设置cookie，并在访问 /page2 时读取cookie：
@app.route('/')
def index():
   rsp = make_response('go <a href="%s">page2</a>' % '/page2')
   rsp.set_cookie('user','JJJJJohnny')      #设置cookie
   return rsp

@app.route('/page2')
def page2():
   user = request.cookies['user']           #获取cookie
   return 'you are %s' % user
