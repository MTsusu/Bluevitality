> Macro类似常规编程语言中的函数，用于把常用行为作为可重用的函数来取代重复的工作
#### demo1
```python
#定义
{% macro input(name, value='', type='text', size=20) -%}
<input type="{{ type }}" name="{{ name }}" value="{{ value|e }}" size="{{ size }}">
{%- endmacro %}

#调用
<p>{{ input('username') }}</p>
<p>{{ input('password', type='password') }}</p>
```

#### demo2
```python
#定义
{% macro render_posts(posts) %}
    {% for post in posts %}
        <div class="post">
            <div class="title">
                <a href="{{ url_for('post', uid=post.id) }}">{{ post.title }}</a>
            </div>
            <div class="abstract">{{ post.content|truncate(50, true) }}</div>
        </div>
    {% endfor %}
{% endmacro %}

#调用
{% from "macros/posts.html" import render_posts %}

{{ render_posts(posts) }}
```
