#### 定义基础模板
```python
#在这个Base.html中，定义了简单的 HTML 骨架，可将它用作简单的双栏页面。而子模板负责将空白的块填充
#在这个例子中，使用 {% block %} 标签定义了四个子模板可以重载的块。 
#block 标签所做的的所有事情就是告诉模板引擎: 一个子模板可能会重写父模板的这个部分。

<!doctype html>
<html>
  <head>
    {% block head %}
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
    <title>{% block title %}{% endblock %} - My Webpage</title>
    {% endblock %}
  </head>
<body>
  <div id="content">{% block content %}{% endblock %}</div>
  <div id="footer">
    {% block footer %}
    &copy; Copyright 2010 by <a href="http://domain.invalid/">you</a>.
    {% endblock %}
  </div>
</body>
```

#### 子模板继承基础模板
```python
#{% extends %} 标签是这里的关键，它通知模板引擎这个模板继承了另外的模板，
#当模板系统解析模板时首先找到父模板。extends 标签必须是模板中的第一个标签。
#为了在一个中块显示父模板中定义的对应块的内容，使用 {{ super() }} 。
{% extends "Base.html" %}
{% block title %}Index{% endblock %}
{% block head %}
  {{ super() }}
  <style type="text/css">
    .important { color: #336699; }
  </style>
{% endblock %}
{% block content %}
  <h1>Index</h1>
  <p class="important">
    Welcome on my awesome homepage.
{% endblock %}
```
