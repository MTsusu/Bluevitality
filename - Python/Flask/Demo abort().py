from flask import Flask,render_template,abort

app = Flask(__name__)
 
@app.route('/error')
def error():
    abort(404)                              #使用”abort()”函数可以直接退出请求，返回错误代码

#上例会显示浏览器的404错误页面。有时候，我们想要在遇到特定错误代码时做些事情，或者重写错误页面，可以用下面的方法：


@app.errorhandler(404)
def page_not_found(error):
    return render_template('404.html'), 404
    
#此时，当再次遇到404错误时，即会调用”page_not_found()”函数，其返回”404.html”的模板页。第二个参数代表错误代码。

if __name__ == '__main__':
    app.debug = True
    app.run('0.0.0.0',80)
