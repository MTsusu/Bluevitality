#### Hello.py
```python
from flask import Flask, render_template, session, redirect, url_for  
from flask.ext.script import Manager  
from flask.ext.bootstrap import Bootstrap  
from flask.ext.moment import Moment  
from flask.ext.wtf import Form  
from wtforms import StringField, SubmitField  
from wtforms.validators import Required  
  
app = Flask(__name__)  
app.config['SECRET_KEY'] = 'hard to guess string'  
  
manager = Manager(app)  
bootstrap = Bootstrap(app)  
moment = Moment(app)  
  
class NameForm(Form):  
    name = StringField('What is your name?', validators=[Required()])  
    submit = SubmitField('Submit')  
 
@app.errorhandler(404)  
def page_not_found(e):  
    return render_template('404.html'), 404  
 
@app.errorhandler(500)  
def internal_server_error(e):  
    return render_template('500.html'), 500  
  
@app.route('/', methods=['GET', 'POST'])  
def index():  
    form = NameForm()                           #实例化表单类
    if form.validate_on_submit():               #若表单验证通过
        session['name'] = form.name.data        #存入会话给name
        return redirect(url_for('index'))       #重定向到特定视图的URL
    return render_template('index.html', form=form, name=session.get('name'))   #从会话获取name的值给模板的name变量
  
if __name__ == '__main__':  
    manager.run()  
```
#### templates\index.html 
```python
{% extends "base.html" %}  
{% import "bootstrap/wtf.html" as wtf %}  
  
{% block title %}Flasky{% endblock %}  
  
{% block page_content %}  
<div class="page-header">  
    <h1>Hello, {% if name %}{{ name }}{% else %}Stranger{% endif %}!</h1>  
</div>  
{{ wtf.quick_form(form) }}  
{% endblock %}  
```
#### templates\base.html  
```python
{% extends "bootstrap/base.html" %}  
  
{% block title %}Flasky{% endblock %}  
  
{% block head %}  
{{ super() }}  
<link rel="shortcut icon" href="{{ url_for('static', filename='favicon.ico') }}" type="image/x-icon">  
<link rel="icon" href="{{ url_for('static', filename='favicon.ico') }}" type="image/x-icon">  
{% endblock %}  
  
{% block navbar %}  
<div class="navbar navbar-inverse" role="navigation">  
    <div class="container">  
        <div class="navbar-header">  
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">  
                <span class="sr-only">Toggle navigation</span>  
                <span class="icon-bar"></span>  
                <span class="icon-bar"></span>  
                <span class="icon-bar"></span>  
            </button>  
            <a class="navbar-brand" href="/">Flasky</a>  
        </div>  
        <div class="navbar-collapse collapse">  
            <ul class="nav navbar-nav">  
                <li><a href="/">Home</a></li>  
            </ul>  
        </div>  
    </div>  
</div>  
{% endblock %}  
  
{% block content %}  
<div class="container">  
    {% block page_content %}{% endblock %}  
</div>  
{% endblock %}  
  
{% block scripts %}  
{{ super() }}  
{{ moment.include_moment() }}  
{% endblock %}  
```

