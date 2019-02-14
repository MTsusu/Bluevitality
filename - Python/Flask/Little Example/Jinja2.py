# use Jinja2 
# coding=utf-8
from flask import Flask,render_template

app=Flask(__name__)

@app.route('/')
def index():
	return render_template('index.html')
	
@app.route('/user/<name>')
def user(name):
	# 将name变量传递给Jinja
	return render_template('user.html',name=name)

# 启动服务器
if __name__ =='__main__':
	app.run()
    

""" ---------------------------------------------------------
模板语法
    {{ 变量/表达式 }}
    {% 语法 %}
    {# 注释 #}

FOR:
    {% for color in colors: %}  
        color {{ loop.index }} : {{color}} <br>  
    {% endfor %}  

MACRO:
    {% macro render_color(color) -%}  
        <div>This is color: {{color}} {{ caller() }}</div>  
    {%- endmacro %}  
  
    {% for color in colors: %}  
        {% call render_color(color) %} render_color_demo  {% endcall %}  
    {% endfor %} 

    #定义
    {% macro input(name, value='', type='text', size=20) -%}
    <input type="{{ type }}" name="{{ name }}" value="{{ value|e }}" size="{{ size }}">
    {%- endmacro %}
    
    #调用
    <p>{{ input('username') }}</p>
    <p>{{ input('password', type='password') }}</p>
    
    
"""