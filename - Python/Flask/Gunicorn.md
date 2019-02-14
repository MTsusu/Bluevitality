#### This is all!...
```bash
#安装
pip install gunicorn

#运行（启动4个worker进程，工作在8080端口，入口py文件名为：wsgi，执行此文件内的application对象...）
gunicorn -w 4 -b 127.0.0.1:8080 wsgi:application
```
#### 入口文件"wsgi"的例子
```python
from flask import Flask

def create_app():
  app = Flask(__name__)   # 这个工厂方法可以从你的原有的 `__init__.py` 或者其它地方引入。
  return app

application = create_app()

if __name__ == '__main__':
    application.run()
```
