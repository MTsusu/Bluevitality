from flask import Flask, request, url_for, render_template,flash,abort
from model import User

app = Flask(__name__)
# flash key
app.secret_key = '123'


# 路由
@app.route('/')
def hello_world():
    content = 'Hello World!'
    # 参数传递
    return render_template('index.html', content=content)


@app.route('/login', methods=['GET', 'POST'])
def login():
    form = request.form
    username = form.get('username')
    password = form.get('password')

    if not username:
        # 消息提示
        flash('please input username')
    if not password:
        flash('please input password')
    if username != 'jike' or password != '123456':
        flash('username or password not correct')
    else:
        flash('login success')
    return render_template('login.html')


@app.route('/user')
def hello_user():
    user = User(1, 'jikexueyuan')
    # 对象传递
    return render_template('user_index.html', user=user)


@app.route('/user/<id>')
def user_index(id):
    user = None
    if int(id) == 1:
        user = User(1, 'jikexueyuan')
    else:
        # 抛出异常
        abort(404)
    # 选择语句
    return render_template('user_select.html', user=user)


@app.route('/query_all')
def user_iter():
    users = []
    for i in range(4):
        user = User(i, 'jike' + str(i))
        users.append(user)
    # 循环语句
    return render_template('user_iter.html', users=users)


@app.route('/page/<id>')
def one_html(id):
    # 页面继承，避免代码重复
    return render_template(id+'_base.html')


@app.route('/query_user')
def query_user():
    name = request.args.get('name')
    # params解析
    return 'Hello ' + name


# 反向路由,通过处理函数反推url
@app.route('/query_url')
def query_url():
    return 'query url:' + url_for('query_user')


# 捕获异常处理
@app.errorhandler(404)
def not_found(e):
    return render_template('404.html')

if __name__ == '__main__':
    app.run()
